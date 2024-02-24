#include <stdint.h>
#include <stdio.h>

int main() {
	extern int mul1; //32-bit
	extern int mul2; //32-bit
	extern unsigned int u_mul1; //32-bit
	extern unsigned int u_mul2; //32-bit
	extern long long _test_start; //64-bit

	*(&_test_start) = ((long long)mul1 * (long long)mul2);
	*(&_test_start + 1) = ((long long)u_mul1 * (long long)u_mul2);

	return 0;
}
