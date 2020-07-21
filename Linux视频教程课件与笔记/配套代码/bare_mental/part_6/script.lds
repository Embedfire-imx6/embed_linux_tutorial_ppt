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

        data_load_addr = . ;
        . =ALIGN(4) ;
        .data 0x85000000 : AT(data_load_addr) 
        { 
            data_start = . ;
            *(.data) 
            data_end = . ;
        }

        __bss_start = .;
        .bss ALIGN(4) : 
        { 
            *(.bss) 
            *(COMMON) 
        }
        __bss_end = .;
 }