///+++++++++++++++++++++++++++++++++++++++++++++
//=============================================
//   Topic      : Greatest common divisor
//   Author     : Hsin-Hang Wu
//   E-mail     : N26124395@gs.ncku.edu.tw
//+++++++++++++++++++++++++++++++++++++++++++++
//   File Name        : main.c
//   Module Name      : GCD
//   Earliest start   : 2023/09/25
//   The last updated : 2023/09/25
//+++++++++++++++++++++++++++++++++++++++++++++
//=============================================
int GCD(int m,int n) {
    while (m!=n)
    {
        if(m>n){
            m-=n;
        }
        else{
            n-=m;
        }
    }
    return m;
}
int main(void){
	extern int div1;
    extern int div2;
	extern int _test_start;

    int r= GCD(div1,div2);
	*(&_test_start)=r;
	return 0;
}