#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <linux/spi/spidev.h>

/*SPI 接收 、发送 缓冲区*/
unsigned char tx_buffer[100] = "hello the world !";
unsigned char rx_buffer[100];

int fd;                  // SPI 控制引脚的设备文件描述符
static  uint32_t mode=0;           //用于保存 SPI 工作模式
static  uint8_t bits = 8;        // 接收、发送数据位数
static  uint32_t speed = 500000; // 发送速度

/*
* 错误处理函数。
*/
void pabort(const char *s)
{
  perror(s);
  abort();
}

/*
* 初始化SPI ,初始化OLED 使用到的命令、数据控制引脚
*/
void spi_init(void)
{
    int ret = 0;

    /*打开 SPI 设备*/
    fd = open("/dev/spidev2.0", O_RDWR);
    if (fd < 0)
    {
    pabort("can't open /dev/spidev2.0 ");
    }

    /*
        * spi mode 设置SPI 工作模式
        */
    ret = ioctl(fd, SPI_IOC_WR_MODE32, &mode);
    if (ret == -1)
    pabort("can't set spi mode");

    ret = ioctl(fd, SPI_IOC_RD_MODE32, &mode);
    if (ret == -1)
    pabort("can't get spi mode");

    /*
        * bits per word  设置一个字节的位数
        */
    ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
    if (ret == -1)
    pabort("can't set bits per word");

    ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
    if (ret == -1)
    pabort("can't get bits per word");

    /*
        * max speed hz  设置SPI 最高工作频率
        */
    ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
    if (ret == -1)
    pabort("can't set max speed hz");

    ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
    if (ret == -1)
    pabort("can't get max speed hz");

    printf("spi mode: 0x%x\n", mode);
    printf("bits per word: %d\n", bits);
    printf("max speed: %d Hz (%d KHz)\n", speed, speed / 1000);
}

void transfer(int fd, uint8_t const *tx, uint8_t const *rx, size_t len)
{
  int ret;
  int out_fd;
  struct spi_ioc_transfer tr = {
      .tx_buf = (unsigned long)tx,
      .rx_buf = (unsigned long)rx,
      .len = len,
  };

  ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
  if (ret < 1)
  {
    pabort("can't send spi message");
  }
}

int main(int argc, char *argv[])
{
    int ret;
	/*初始化SPI */
	spi_init();

    /*执行发送*/
	transfer(fd, tx_buffer, rx_buffer, sizeof(tx_buffer));

	/*打印 tx_buffer 和 rx_buffer*/
	printf("tx_buffer: \n %s\n ", tx_buffer);
	printf("rx_buffer: \n %s\n ", rx_buffer);
    

	close(fd);

	return 0;
}
