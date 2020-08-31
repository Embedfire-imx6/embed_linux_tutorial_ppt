ifeq ($(ARCH),x86)
CC = gcc
 else
##CC = arm-linux-gnueabihf-gcc
CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
endif

TARGET = button
#OBJS=main.o mp3.o
BUILD_DIR = build
SRC_DIR = sources
INC_DIR = include
CFLAGS = $(patsubst %, -I%, $(INC_DIR))
INCLUDES = $(foreach dir,$(INC_DIR),$(wildcard $(dir)/*.h))

#源文件要加上汇编文件
SOURCES_c= $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.c))
SOURCES_s= $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.s))
OBJS = $(patsubst %.c, $(BUILD_DIR)/%.o, $(notdir $(SOURCES_c)))
OBJS += $(patsubst %.s, $(BUILD_DIR)/%.o, $(notdir $(SOURCES_s)))
VPATH=$(SRC_DIR)

$(BUILD_DIR)/$(TARGET).bin: $(OBJS)
	$(LD) -Tscript.lds -o $(BUILD_DIR)/$(TARGET).elf $^
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(TARGET).elf $@

$(BUILD_DIR)/%.o : %.c  $(INCLUDES) |  create_build
	$(CC) -c $< -o $@  $(CFLAGS) 

#编译汇编文件
$(BUILD_DIR)/%.o : %.s  $(INCLUDES) |  create_build
	$(CC) -c $< -o $@  $(CFLAGS) 

.PHONY:clean create_build burn

clean:
	rm -r $(BUILD_DIR)

create_build:
	mkdir -p $(BUILD_DIR)

burn:
	cp  $(BUILD_DIR)/$(TARGET).bin /home/embedfire/bare_mental/part_1/download_tool
	cd /home/embedfire/bare_mental/part_1/download_tool && ./mkimage.sh  $(TARGET).bin
	


