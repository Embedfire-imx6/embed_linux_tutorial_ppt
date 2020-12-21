ARCH ?= x86

ifeq ($(ARCH),x86)
		CC = gcc
else
		CC = arm-linux-gnueabihf-gcc
endif

CC=gcc
TARGET=mp3
OBJS=main.o mp3.o

$(TARGET):$(OBJS)

#main.o:
#	gcc -c main.c -o main.o

#mp3.o:
#	gcc -c mp3.c -o mp3.o

#%.o:%.c
#	$(cc) -c $< -o $@
.PHONY:clean

clean:
		rm mp3 *.o
