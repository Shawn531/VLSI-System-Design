// void Interrupt_Service(){
//     // asm("csrr t5, mip");	
// 	// asm("lui t6, 0x1");
// 	// asm("addi t6, t6, -2048");
// 	// asm("and t6, t5, t6");	
// 	// asm("j wdt_interrupt");	
// 	// asm("beqz t6,12");
// 	// //asm("jal ra, copy");
// 	// asm("beqz x0, 24");
// 	// asm("andi t5, t5, 128");
// 	// asm("beqz t5, 12");
// 	// asm("jal ra, wdt_interrupt");
// 	// asm("beqz x0, 8");	
// 	asm("addi sp,sp,-4");
//     asm("sw   ra,0(sp)");
//  	asm("jal  ra,DMA_off");
//     asm("lw   ra,0(sp)");
//     asm("addi sp,sp,4");
//  	asm("li t6, 0x1500");
// };

void DMA_off(){
    int *DMA_ctrl_addr = (int*)0x50004000;
    *DMA_ctrl_addr = 0;
	return;
};

void Interrupt_Service(){
	DMA_off();
	return;
};
