# include  "common.h"

int main()
{
    int i = 0;

    /*初始化led灯和按键*/
    rgb_led_init();
    button_init();

    while(1)
    {
        /*按键按下*/
        if(get_button_status())
        {
            /*翻转红灯状态*/
            if(i == 0)
            {
                red_led_on;
                i = 1;
            }
            else
            {
                red_led_off;
                i = 0;
            }
            while(get_button_status());//等待按键松开
        }
    }

    return 0;    
}