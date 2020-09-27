## SPI主控制器驱动和核心函数

#### spi_imx_probe()函数

- 获取设备树节点信息，初始化spi时钟、dma...
- 保存spi寄存器起始地址，填充spi控制器回调函数

drivers/spi/spi-imx.c

```
static int spi_imx_probe(struct platform_device *pdev)
{
	struct device_node *np = pdev->dev.of_node;
	const struct of_device_id *of_id =
			of_match_device(spi_imx_dt_ids, &pdev->dev);
	struct spi_imx_master *mxc_platform_info =
			dev_get_platdata(&pdev->dev);
	struct spi_master *master;
	struct spi_imx_data *spi_imx;
	struct resource *res;
	const struct spi_imx_devtype_data *devtype_data = of_id ? of_id->data :
		(struct spi_imx_devtype_data *)pdev->id_entry->driver_data;
	bool slave_mode;
	...
	slave_mode = devtype_data->has_slavemode &&
			of_property_read_bool(np, "spi-slave");
	if (slave_mode)
		master = spi_alloc_slave(&pdev->dev,
					 sizeof(struct spi_imx_data));
	else
		master = spi_alloc_master(&pdev->dev,
					  sizeof(struct spi_imx_data));
	if (!master)
		return -ENOMEM;
	...
		ret = of_property_read_u32(np, "fsl,spi-num-chipselects", &num_cs);
        if (ret < 0) {
            if (mxc_platform_info) {
                num_cs = mxc_platform_info->num_chipselect;
                master->num_chipselect = num_cs;
            }
        } else {
            master->num_chipselect = num_cs;
        }
	
	spi_imx = spi_master_get_devdata(master);
	spi_imx->bitbang.master = master;
	spi_imx->dev = &pdev->dev;
	spi_imx->slave_mode = slave_mode;

	spi_imx->devtype_data = devtype_data;

	master->cs_gpios = devm_kzalloc(&master->dev,
			sizeof(int) * master->num_chipselect, GFP_KERNEL);
	
	spi_imx->bitbang.chipselect = spi_imx_chipselect;
	spi_imx->bitbang.setup_transfer = spi_imx_setupxfer;
	spi_imx->bitbang.txrx_bufs = spi_imx_transfer;
	spi_imx->bitbang.master->setup = spi_imx_setup;
	spi_imx->bitbang.master->cleanup = spi_imx_cleanup;
	spi_imx->bitbang.master->prepare_message = spi_imx_prepare_message;
	spi_imx->bitbang.master->unprepare_message = spi_imx_unprepare_message;
	spi_imx->bitbang.master->slave_abort = spi_imx_slave_abort;
	spi_imx->bitbang.master->mode_bits = SPI_CPOL | SPI_CPHA | SPI_CS_HIGH \
	...
	init_completion(&spi_imx->xfer_done);

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	spi_imx->base = devm_ioremap_resource(&pdev->dev, res);
	...
	ret = spi_bitbang_start(&spi_imx->bitbang);
	...
}
```

##### spi_bitbang_start()函数

drivers/spi/spi-bitbang.c

```
int spi_bitbang_start(struct spi_bitbang *bitbang)
{
	struct spi_master *master = bitbang->master;
	int ret;

	if (!master || !bitbang->chipselect)
		return -EINVAL;

	mutex_init(&bitbang->lock);

	if (!master->mode_bits)
		master->mode_bits = SPI_CPOL | SPI_CPHA | bitbang->flags;

	if (master->transfer || master->transfer_one_message)
		return -EINVAL;

	master->prepare_transfer_hardware = spi_bitbang_prepare_hardware;
	master->unprepare_transfer_hardware = spi_bitbang_unprepare_hardware;
	master->transfer_one = spi_bitbang_transfer_one;
	master->set_cs = spi_bitbang_set_cs;

	if (!bitbang->txrx_bufs) {
		bitbang->use_dma = 0;
		bitbang->txrx_bufs = spi_bitbang_bufs;
		if (!master->setup) {
			if (!bitbang->setup_transfer)
				bitbang->setup_transfer =
					 spi_bitbang_setup_transfer;
			master->setup = spi_bitbang_setup;
			master->cleanup = spi_bitbang_cleanup;
		}
	}

	/* driver may get busy before register() returns, especially
	 * if someone registered boardinfo for devices
	 */
	ret = spi_register_master(spi_master_get(master));
	if (ret)
		spi_master_put(master);

	return ret;
}
EXPORT_SYMBOL_GPL(spi_bitbang_start);
```

#### 核心函数

##### spi_setup()函数

设置spi设备的片选信号、传输单位、最大传输速率...

drivers/spi/spi.c

```
int spi_setup(struct spi_device *spi)
{
	unsigned	bad_bits, ugly_bits;
	int		status;

	...
	status = __spi_validate_bits_per_word(spi->controller,
					      spi->bits_per_word);
	...
		spi->max_speed_hz = spi->controller->max_speed_hz;
	...
	if (spi->controller->setup)
		status = spi->controller->setup(spi);
	...
	return status;
}
```

###### spi_imx_setup()函数

drivers/spi/spi-imx.c

```
static int spi_imx_setup(struct spi_device *spi)
{
	dev_dbg(&spi->dev, "%s: mode %d, %u bpw, %d hz\n", __func__,
		 spi->mode, spi->bits_per_word, spi->max_speed_hz);

	if (spi->mode & SPI_NO_CS)
		return 0;

	if (gpio_is_valid(spi->cs_gpio))
		gpio_direction_output(spi->cs_gpio,
				      spi->mode & SPI_CS_HIGH ? 0 : 1);

	spi_imx_chipselect(spi, BITBANG_CS_INACTIVE);

	return 0;
}
```

###### spi_imx_chipselect()函数

drivers/spi/spi-imx.c

```
static void spi_imx_chipselect(struct spi_device *spi, int is_active)
{
	int active = is_active != BITBANG_CS_INACTIVE;
	int dev_is_lowactive = !(spi->mode & SPI_CS_HIGH);

	if (spi->mode & SPI_NO_CS)
		return;

	if (!gpio_is_valid(spi->cs_gpio))
		return;

	gpio_set_value(spi->cs_gpio, dev_is_lowactive ^ active);
}
```



##### spi_message_init()函数

include/linux/spi/spi.h

```
static inline void spi_message_init(struct spi_message *m)
{
	memset(m, 0, sizeof *m);
	spi_message_init_no_memset(m);
}

```

###### spi_message_init_no_memset()函数

```
static inline void spi_message_init_no_memset(struct spi_message *m)
{
	INIT_LIST_HEAD(&m->transfers);
	INIT_LIST_HEAD(&m->resources);
}
```

###### spi_message结构体

include/linux/spi/spi.h

```
struct spi_message {
	struct list_head	transfers;

	struct spi_device	*spi;
	...
	void			(*complete)(void *context);
	void			*context;
	unsigned		frame_length;
	unsigned		actual_length;
	int			status;
	...
	struct list_head	queue;
	void			*state;

	/* list of spi_res reources when the spi message is processed */
	struct list_head        resources;
};
```



##### spi_message_add_tail()函数

include/linux/spi/spi.h

```
spi_message_add_tail(struct spi_transfer *t, struct spi_message *m)
{
	list_add_tail(&t->transfer_list, &m->transfers);
}
```

###### spi_transfer结构体

include/linux/spi/spi.h

```
struct spi_transfer {

	const void	*tx_buf;
	void		*rx_buf;
	unsigned	len;
	...
	u32		speed_hz;
	struct list_head transfer_list;
};
```



##### spi_sync()函数

drivers/spi/spi.c

同步传输数据，阻塞当前线程

```
int spi_sync(struct spi_device *spi, struct spi_message *message)

```



##### spi_async()函数

drivers/spi/spi.c

异步传输数据，不会阻塞当前线程

```
int spi_async(struct spi_device *spi, struct spi_message *message)
```



