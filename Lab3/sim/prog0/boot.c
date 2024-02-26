void boot() {
    extern unsigned int _dram_i_start;
    extern unsigned int _dram_i_end;
    extern unsigned int _imem_start;

    extern unsigned int __sdata_start;
    extern unsigned int __sdata_end;
    extern unsigned int __sdata_paddr_start;

    extern unsigned int __data_start;
    extern unsigned int __data_end;
    extern unsigned int __data_paddr_start;

    int *ptr1, *ptr2;

    // IM
    ptr1 = &_imem_start;
    ptr2 = &_dram_i_start;
    while (ptr2 <= &_dram_i_end) {
        *ptr1++ = *ptr2++;
    }

    // DM (sdata)
    ptr1 = &__sdata_start;
    ptr2 = &__sdata_paddr_start;
    while (ptr1 <= &__sdata_end) {
        *ptr1++ = *ptr2++;
    }

    // DM (data)
    ptr1 = &__data_start;
    ptr2 = &__data_paddr_start;
    while (ptr1 <= &__data_end) {
        *ptr1++ = *ptr2++;
    }
}
