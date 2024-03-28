
volatile unsigned int *WDT_addr = (int *) 0x10010000;
volatile unsigned int *ITRP_addr = (int *) 0x10020000;
void DMA_copy(unsigned int* src_addr, unsigned int* dest_addr, unsigned int length)
{
    int *sensor_addr = (int *) 0x10000000;
    // Enable Global Interrupt
    asm("csrsi mstatus, 0x8"); // MIE of mstatus
    // Enable Local Interrupt
    asm("li t6, 0x800");
    asm("csrs mie, t6"); // MEIE of mie 

    unsigned int *DMA_src_addr  = (unsigned int*)0x50001000;
    unsigned int *DMA_dest_addr = (unsigned int*)0x50002000;
    unsigned int *DMA_len_addr  = (unsigned int*)0x50003000;
    unsigned int *DMA_ctrl_addr = (unsigned int*)0x50004000;
    *DMA_src_addr  = (unsigned int)src_addr;
    *DMA_dest_addr = (unsigned int)dest_addr;
    *DMA_len_addr  = length;
    *DMA_ctrl_addr = 1;

    sensor_addr[0x2400] = 1; // Enable sctrl_clear
    sensor_addr[0x2400] = 0; // Disable sctrl_clear

    asm("wfi");
    // Disable Global Interrupt
    asm("csrwi mstatus, 0x0"); // MIE of mstatus
    // Disable Local Interrupt
    asm("li t6, 0x000");
    asm("csrw mie, t6"); // MEIE of mie 

    return;
}

void wdt_interrupt () {
  asm("csrsi mstatus, 0x0"); // MIE of mstatus
  WDT_addr[0x40] = 0; // WDT_en
  asm("j _start");
};

int main()
{
    extern unsigned int _test_start;
    unsigned int *JPEG_output_addr = &_test_start;
    const unsigned int sensor_size = 4096;
    int *sensor_addr = (int *) 0x10000000;
    sensor_addr[0x2000] = 1; // Enable sctrl_en
    while (1)
    {
        if (sensor_addr[0x2401] == 1)
        {
            DMA_copy((unsigned int*)sensor_addr, JPEG_output_addr, sensor_size);
            break;
        }
    }
    return 0;
}