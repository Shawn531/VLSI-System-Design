extern unsigned int _dram_i_start;
extern unsigned int _dram_i_end;
extern unsigned int _imem_start;

extern unsigned int __sdata_start;
extern unsigned int __sdata_end;
extern unsigned int __sdata_paddr_start;

extern unsigned int __data_start;
extern unsigned int __data_end;
extern unsigned int __data_paddr_start;
void boot() {
  // extern unsigned int _dram_i_start;
  // extern unsigned int _dram_i_end;
  // extern unsigned int _imem_start;

  // extern unsigned int __sdata_start;
  // extern unsigned int __sdata_end;
  // extern unsigned int __sdata_paddr_start;

  // extern unsigned int __data_start;
  // extern unsigned int __data_end;
  // extern unsigned int __data_paddr_start;

  unsigned int *DMA_src_addr  = (unsigned int*)0x50001000;
  unsigned int *DMA_dest_addr = (unsigned int*)0x50002000;
  unsigned int *DMA_len_addr  = (unsigned int*)0x50003000;
  unsigned int *DMA_ctrl_addr = (unsigned int*)0x50004000;



  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x800");
  asm("csrs mie, t6"); // MEIE of mie 
  int len;


  len = &_dram_i_end + 1 - &_dram_i_start;

  *DMA_src_addr  = (unsigned int)&_dram_i_start;
  *DMA_dest_addr = (unsigned int)&_imem_start;
  *DMA_len_addr  = len;
  *DMA_ctrl_addr = 1;
  asm("wfi");

  len = &__data_end + 1 - &__data_start;
  *DMA_src_addr  = (unsigned int)&__data_paddr_start;
  *DMA_dest_addr = (unsigned int)&__data_start;
  *DMA_len_addr  = len;
  *DMA_ctrl_addr = 1;
  asm("wfi");

  len = &__sdata_end + 1 - &__sdata_start;
  *DMA_src_addr  = (unsigned int)&__sdata_paddr_start;
  *DMA_dest_addr = (unsigned int)&__sdata_start;
  *DMA_len_addr  = len;
  *DMA_ctrl_addr = 1;
  asm("wfi");

  // Disable Global Interrupt
  asm("csrwi mstatus, 0x0"); // MIE of mstatus

  // Disable Local Interrupt
  asm("li t6, 0x000");
  asm("csrw mie, t6"); // MEIE of mie 

};
// void boot() {
//   extern unsigned int _dram_i_start;
//   extern unsigned int _dram_i_end;
//   extern unsigned int _imem_start;

//   extern unsigned int __sdata_start;
//   extern unsigned int __sdata_end;
//   extern unsigned int __sdata_paddr_start;

//   extern unsigned int __data_start;
//   extern unsigned int __data_end;
//   extern unsigned int __data_paddr_start;
  
//   int *dram_i_start = &_dram_i_start;
//   for(int i=0; i<=(&_dram_i_end-&_dram_i_start); i++)
//   {
//  *(&_imem_start+i) = dram_i_start[i];  
//   }
 

//   int *data_paddr_start = &__data_paddr_start;
//   for(int k=0; k<=(&__data_end-&__data_start); k++)
//   {
//  *(&__data_start+k) = data_paddr_start[k];
//   }  
 

//   int *sdata_paddr_start = &__sdata_paddr_start;
//   for(int j=0; j<=(&__sdata_end-&__sdata_start); j++)
//   {
//  *(&__sdata_start+j) = sdata_paddr_start[j];
//   }
  
  
// }