KERNEL_DIR=/home/pi/build

ARCH=arm
CROSS_COMPILE=arm-linux-gnueabihf-
export  ARCH  CROSS_COMPILE

obj-m :=i2c_mpu6050.o

all:app
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) modules

app:	
	arm-linux-gnueabihf-gcc app.c -o App

.PHONE:clean copy 

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) clean	
	sudo rm /home/embedfire/workdir/*.ko App

copy:
	sudo  cp  *.ko  App /home/embedfire/workdir