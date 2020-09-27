## SPI数据传输剖析：同步、异步

#### spi_register_master()函数

include/linux/spi/spi.h

```
#define spi_register_master(_ctlr)	spi_register_controller(_ctlr)
```

##### spi_register_controller()函数

drivers/spi/spi.c

```
int spi_register_controller(struct spi_controller *ctlr)
{
	struct device		*dev = ctlr->dev.parent;
	struct boardinfo	*bi;
	int			status = -ENODEV;
	int			id, first_dynamic;
	...
	dev_set_name(&ctlr->dev, "spi%u", ctlr->bus_num);
	status = device_add(&ctlr->dev);
    ...
    if (ctlr->transfer) {
		dev_info(dev, "controller is unqueued, this is deprecated\n");
	} else if (ctlr->transfer_one || ctlr->transfer_one_message) {
		status = spi_controller_initialize_queue(ctlr);
		...
	}
	...
	list_add_tail(&ctlr->list, &spi_controller_list);
	...
}
```

##### spi_controller_initialize_queue()函数

drivers/spi/spi.c

```
static int spi_controller_initialize_queue(struct spi_controller *ctlr)
{
	int ret;

	ctlr->transfer = spi_queued_transfer;
	if (!ctlr->transfer_one_message)
		ctlr->transfer_one_message = spi_transfer_one_message;

	/* Initialize and start queue */
	ret = spi_init_queue(ctlr);
	if (ret) {
		dev_err(&ctlr->dev, "problem initializing queue\n");
		goto err_init_queue;
	}
	ctlr->queued = true;
	ret = spi_start_queue(ctlr);
	if (ret) {
		dev_err(&ctlr->dev, "problem starting queue\n");
		goto err_start_queue;
	}

	return 0;

err_start_queue:
	spi_destroy_queue(ctlr);
err_init_queue:
	return ret;
}
```

##### spi_init_queue()函数

- 初始化内核线程工人
- 初始化内核具体工作

drivers/spi/spi.c

```
static int spi_init_queue(struct spi_controller *ctlr)
{
	struct sched_param param = { .sched_priority = MAX_RT_PRIO - 1 };

	ctlr->running = false;
	ctlr->busy = false;

	kthread_init_worker(&ctlr->kworker);
	ctlr->kworker_task = kthread_run(kthread_worker_fn, &ctlr->kworker,
					 "%s", dev_name(&ctlr->dev));
	if (IS_ERR(ctlr->kworker_task)) {
		dev_err(&ctlr->dev, "failed to create message pump task\n");
		return PTR_ERR(ctlr->kworker_task);
	}
	kthread_init_work(&ctlr->pump_messages, spi_pump_messages);

	...

	return 0;
}
```

##### spi_start_queue()函数

启动内核具体工作

drivers/spi/spi.c

```
static int spi_start_queue(struct spi_controller *ctlr)
{
	unsigned long flags;

	spin_lock_irqsave(&ctlr->queue_lock, flags);

	if (ctlr->running || ctlr->busy) {
		spin_unlock_irqrestore(&ctlr->queue_lock, flags);
		return -EBUSY;
	}

	ctlr->running = true;
	ctlr->cur_msg = NULL;
	spin_unlock_irqrestore(&ctlr->queue_lock, flags);

	kthread_queue_work(&ctlr->kworker, &ctlr->pump_messages);

	return 0;
}
```

##### spi_pump_messages()函数

内核工作具体处理

drivers/spi/spi.c

```
static void spi_pump_messages(struct kthread_work *work)
{
	struct spi_controller *ctlr =
		container_of(work, struct spi_controller, pump_messages);

	__spi_pump_messages(ctlr, true);
}
```

##### __spi_pump_messages()函数

drivers/spi/spi.c

```
static void __spi_pump_messages(struct spi_controller *ctlr, bool in_kthread)
{
	unsigned long flags;
	bool was_busy = false;
	int ret;
	...
	ctlr->cur_msg =
		list_first_entry(&ctlr->queue, struct spi_message, queue);

	list_del_init(&ctlr->cur_msg->queue);
	...
	if (ctlr->prepare_message) {
		ret = ctlr->prepare_message(ctlr, ctlr->cur_msg);
		...
		ctlr->cur_msg_prepared = true;
	}
	...
	ret = ctlr->transfer_one_message(ctlr, ctlr->cur_msg);
	...
}
	
```



#### spi_sync()函数

同步传输数据

drivers/spi/spi.c

```
int spi_sync(struct spi_device *spi, struct spi_message *message)
{
	int ret;

	mutex_lock(&spi->controller->bus_lock_mutex);
	ret = __spi_sync(spi, message);
	mutex_unlock(&spi->controller->bus_lock_mutex);

	return ret;
}
```

##### __spi_sync()函数

drivers/spi/spi.c

```
static int __spi_sync(struct spi_device *spi, struct spi_message *message)
{
	int status;
	struct spi_controller *ctlr = spi->controller;
	unsigned long flags;

	status = __spi_validate(spi, message);
	if (status != 0)
		return status;

	message->complete = spi_complete;
	message->context = &done;
	message->spi = spi;
	...
	if (ctlr->transfer == spi_queued_transfer) {
		spin_lock_irqsave(&ctlr->bus_lock_spinlock, flags);

		trace_spi_message_submit(message);

		status = __spi_queued_transfer(spi, message, false);

		spin_unlock_irqrestore(&ctlr->bus_lock_spinlock, flags);
	} else {
		status = spi_async_locked(spi, message);
	}
	
	
	if (status == 0) {
		...
		wait_for_completion(&done);
		status = message->status;
	}
	message->context = NULL;
	return status;
}
```

##### __spi_queued_transfer()函数

drivers/spi/spi.c

```
static int __spi_queued_transfer(struct spi_device *spi,
				 struct spi_message *msg,
				 bool need_pump)
{
	struct spi_controller *ctlr = spi->controller;
	unsigned long flags;

	spin_lock_irqsave(&ctlr->queue_lock, flags);

	if (!ctlr->running) {
		spin_unlock_irqrestore(&ctlr->queue_lock, flags);
		return -ESHUTDOWN;
	}
	msg->actual_length = 0;
	msg->status = -EINPROGRESS;

	list_add_tail(&msg->queue, &ctlr->queue);
	if (!ctlr->busy && need_pump)
		kthread_queue_work(&ctlr->kworker, &ctlr->pump_messages);

	spin_unlock_irqrestore(&ctlr->queue_lock, flags);
	return 0;
}
```



##### spi_transfer_one_message()函数

drivers/spi/spi.c

```
static int spi_transfer_one_message(struct spi_controller *ctlr,
				    struct spi_message *msg)
{
	struct spi_transfer *xfer;
	bool keep_cs = false;
	int ret = 0;
	unsigned long long ms = 1;
	struct spi_statistics *statm = &ctlr->statistics;
	struct spi_statistics *stats = &msg->spi->statistics;
	...
	list_for_each_entry(xfer, &msg->transfers, transfer_list) {
		...
		if (xfer->tx_buf || xfer->rx_buf) {
			reinit_completion(&ctlr->xfer_completion);
			ret = ctlr->transfer_one(ctlr, msg->spi, xfer);
			...
			if (ret > 0) {
				ret = 0;
				ms = 8LL * 1000LL * xfer->len;
				do_div(ms, xfer->speed_hz);
				ms += ms + 200; /* some tolerance */

				if (ms > UINT_MAX)
					ms = UINT_MAX;

				ms = wait_for_completion_timeout(&ctlr->xfer_completion,
								 msecs_to_jiffies(ms));
			}
		
   	 	}
   	...
   	spi_finalize_current_message(ctlr);
   	...
}
```

##### spi_finalize_current_message()函数

drivers/spi/spi.c

```
void spi_finalize_current_message(struct spi_controller *ctlr)
{
	struct spi_message *mesg;
	unsigned long flags;
	int ret;
	
	...
	ctlr->cur_msg = NULL;
	ctlr->cur_msg_prepared = false;
	kthread_queue_work(&ctlr->kworker, &ctlr->pump_messages);
	...
	mesg->state = NULL;
	if (mesg->complete)
		mesg->complete(mesg->context);
}
```



#### spi_async()函数

异步传输数据

drivers/spi/spi.c

```
int spi_async(struct spi_device *spi, struct spi_message *message)
{
	...
	ret = __spi_async(spi, message);
	...
}
```

##### __spi_async()函数

drivers/spi/spi.c

```
static int __spi_async(struct spi_device *spi, struct spi_message *message)
{
	struct spi_controller *ctlr = spi->controller;
	...
	return ctlr->transfer(spi, message);
}
```

##### spi_queued_transfer()函数

drivers/spi/spi.c

```
static int spi_queued_transfer(struct spi_device *spi, struct spi_message *msg)
{
	return __spi_queued_transfer(spi, msg, true);
}
```

##### __spi_queued_transfer()函数

drivers/spi/spi.c

```
static int __spi_queued_transfer(struct spi_device *spi,
				 struct spi_message *msg,
				 bool need_pump)
{
	struct spi_controller *ctlr = spi->controller;
	unsigned long flags;

	spin_lock_irqsave(&ctlr->queue_lock, flags);

	if (!ctlr->running) {
		spin_unlock_irqrestore(&ctlr->queue_lock, flags);
		return -ESHUTDOWN;
	}
	msg->actual_length = 0;
	msg->status = -EINPROGRESS;

	list_add_tail(&msg->queue, &ctlr->queue);
	if (!ctlr->busy && need_pump)
		kthread_queue_work(&ctlr->kworker, &ctlr->pump_messages);

	spin_unlock_irqrestore(&ctlr->queue_lock, flags);
	return 0;
}
```

