#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
int main(int argc, char *argv[])
{
    /*判断输入的命令是否合法*/
    if(argc != 2)
    {
        printf(" commend error ! \n");
        return -1;
    }

    /*打开文件*/
    int fd = open("/dev/rgb_led", O_RDWR);
    if(fd < 0)
    {
		printf("\n open file : /dev/rgb_led failed !!!\n");
		return -1;
	}


    /*写入命令*/
    int error = write(fd,argv[1],sizeof(argv[1]));
    if(error < 0)
    {
        printf("write file error! \n");
        close(fd);
        /*判断是否关闭成功*/
    }


    //sleep(10);  //休眠10秒

    /*关闭文件*/
    error = close(fd);
    if(error < 0)
    {
        printf("close file error! \n");
    }
    return 0;
}