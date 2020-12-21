ARCH ?= x86

ifeq ($(ARCH),x86)
		CC=gcc
else
		CC=arm-linux-gnueabihf-gcc
endif

TARGET=mp3
#OBJS=main.o mp3.o
BUILD_DIR=build
SRC_DIR=module1 module2

SOURCES=$(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.c))
OBJS=$(patsubst %.c,$(BUILD_DIR)/%.o,$(notdir $(SOURCES)))
VPATH=$(SRC_DIR)

$(BUILD_DIR)/$(TARGET):$(OBJS)
		$(CC) $^ -o $@

#main.o:
#	gcc -c main.c -o main.o

#mp3.o:
#	gcc -c mp3.c -o mp3.o

$(BUILD_DIR)/%.o:%.c | create_build
		$(CC) -c $< -o $@

.PHONY:clean create_build

clean:
	rm -r $(BUILD_DIR)

create_build:
	mkdir -p $(BUILD_DIR)
