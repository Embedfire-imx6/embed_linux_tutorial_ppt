 SECTIONS{
        . = 0x80002000;

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