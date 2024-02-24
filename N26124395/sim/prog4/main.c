int fac(int unsigned m) {
	int i = 1;
	int r = 1;
    while(i  <= m) { 
	    if(i == 1) 
			r = i;
		else 
			r = r *i;
        i=i+1;
    } 
    return r;
}
int main(void){
	
	extern int _test_start;
	*(&_test_start)=fac(10);
	
	
	asm("li t2, 32768");
	asm("rdinstreth t0");
	asm("rdinstret  t1");
    asm("sw	t0,4(t2)");
	asm("sw	t1,8(t2)");
	
	asm("rdcycleh   t0");
	asm("rdcycle    t1");
	asm("sw	t0,12(t2)");
	asm("sw	t1,16(t2)");
	return 0;
}