 SECTIONS{
        . = 0x80000000;

        .text ALIGN(4) :
        {
            build/start.o
            *(.text)
        }

        .rodata ALIGN(4) :
        {
            *(.rodata)
        }

        .data ALIGN(4) : 
        { 
            *(.data) 
        }

        __bss_start = .;
        .bss ALIGN(4) : 
        { 
            *(.bss) 
            *(COMMON) 
        }
        __bss_end = .;
 }

 cd /home/embedfire/bare_mental/part_1/download_tool
 cp base.bin /home/embedfire/bare_mental/part_1/download_tool
 ./mkimage.sh base.bin