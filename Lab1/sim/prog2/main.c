int main() {
	extern int mul1, mul2; //32-bit
	extern long long _test_start; //64-bit

	*(&_test_start) = ((long long)mul1 * (long long)mul2);

	return 0;
}
