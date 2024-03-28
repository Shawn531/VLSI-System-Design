int main(void){
  extern int array_size_i;
  extern int array_size_j;
  extern int array_size_k;
  extern short array_addr;
  extern int _test_start;

  int* result = &_test_start;
  short* data_a = &array_addr;
  short* data_b = (&array_addr + array_size_i*array_size_k);

  int a;
  int counter = 0;
  
  
  
  for(int i = 0; i < array_size_i; i++) {
	  for(int j = 0; j < array_size_j; j++) {
		  
		  a = 0;
		  for(int k =0 ; k<array_size_k; k++){
			a += data_a[k]*data_b[k*array_size_j];
		  }
		  result[counter] = a;
		  
		  counter  = counter+1;
		  data_b = data_b + 1;
	  }
	  data_b = (&array_addr + array_size_i*array_size_k);
	  data_a = data_a + array_size_k;
  }
  
  
 /*
 for(int k =0 ; k<array_size_k; k++){
	 a += data_a[k]*data_b[k*array_size_j];
 }
  result[0] = a;
  
  a =0;
  data_b = data_b + 1;
  for(int k =0 ; k<array_size_k; k++){
	 a += data_a[k]*data_b[k*array_size_j];
 }
  result[1] = a;
  
  a =0;
  data_b = data_b + 1;
  for(int k =0 ; k<array_size_k; k++){
	 a += data_a[k]*data_b[k*array_size_j];
 }
 
  result[2] = a
  
  /*
  a =0;
  data_b = data_b + 3;
  for(int k =0 ; k<array_size_k; k++){
	 a += data_a[k]*data_b[k*array_size_j];
 }
  result[3] = a;
 */
  //result[0] = data_a[0];
	
  return 0;
}
