#include  "interrupt.h"

/*中断服务函数表*/
static sys_irq_handle_t irqTable[NUMBER_OF_INT_VECTORS];

/*注册中断服务函数*/
void system_register_irqhandler(IRQn_Type irq, system_irq_handler_t handler, void *userParam) 
{
	irqTable[irq].irqHandler = handler;
  	irqTable[irq].userParam = userParam;
}

/*中断初始化*/
void irq_init()
{
    GIC_Init();
   
    for(int i = 0; i < NUMBER_OF_INT_VECTORS; i++)
	{
		system_register_irqhandler((IRQn_Type)i, NULL, NULL);
	}

     __set_VBAR((uint32_t)0x80002000);
}

 void SystemIrqHandler(uint32_t giccIar)
{

  uint32_t intNum = giccIar & 0x3FFUL;

 
  /* j检查中断号是否合法 */
  if ((intNum == 1023) || (intNum >= NUMBER_OF_INT_VECTORS))
  {
    return;
  }

  /*如果对应的中断函数不为空，则调用该中断函数*/
  if(NULL != irqTable[intNum].irqHandler)
      irqTable[intNum].irqHandler(giccIar, irqTable[intNum].userParam);

  return;
}