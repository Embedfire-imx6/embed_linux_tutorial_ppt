# include  "common.h"

/*简单延时函数*/
void delay(uint32_t count)
  {
      int  i = 0;
      for (i = 0; i < count; ++i)
      {
          __asm("NOP"); /* 调用nop空指令 */
      }
  }