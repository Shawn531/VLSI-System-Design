unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;
volatile unsigned int *WDT_addr = (int *) 0x10010000;
volatile unsigned int *ITRP_addr = (int *) 0x10020000;
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {
  int i;
  for (i = 0; i < sensor_size; i++) { // Copy data from sensor controller to DM
    *(copy_addr + i) = sensor_addr[i];
  }
  copy_addr += sensor_size; // Update copy address
  copy_count++;    // Increase copy count
  sensor_addr[0x80] = 1; // Enable sctrl_clear
  sensor_addr[0x80] = 0; // Disable sctrl_clear
  if (copy_count == 8) {
    asm("li t6, 0x80");
    asm("csrc mstatus, t6"); // Disable MPIE of mstatus
  }
  return;
}

int partition(int arr[], int low, int high)
{
	int pivot = arr[high]; // pivot 
	int i = (low - 1); // Index of smaller element and indicates the right position of pivot found so far

	for (int j = low; j <= high - 1; j++)
	{
		// If current element is smaller than the pivot 
		if (arr[j] < pivot)
		{
			i++; // increment index of smaller element 
			// swap(&arr[i], &arr[j]);
			int temp;
			temp = arr[i];
			arr[i] = arr[j];
			arr[j] = temp;
		}
	}
	// swap(&arr[i + 1], &arr[high]);
	int temp2;
	temp2 = arr[i + 1];
	arr[i + 1] = arr[high];
	arr[high] = temp2;
			
	return (i + 1);
}

void quickSort(int arr[], int low, int high)
{
	if (low < high)
	{
		// pi is partitioning index, arr[p] is now
		// at right place 
		int pi = partition(arr, low, high);

		// Separately sort elements before 
		// partition and after partition 
		quickSort(arr, low, pi - 1);
		quickSort(arr, pi + 1, high);
	}
}


/*****************************************************************
 * Function: void sort(int *, unsigned int)                                    *
 * Description: Sorting data                                     *
 *****************************************************************/
void sort(int *array, unsigned int size) {
  /*
  int i, j;
  int temp;
  for (i = 0; i < size - 1; i++) {
    for (j = i + 1; j < size; j++) {
      if (array[i] > array[j]) {
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
      }
    }
  }
  */
  quickSort(array, 0, size - 1);

  return;
}

void wdt_interrupt () {
  asm("csrsi mstatus, 0x0"); // MIE of mstatus
  WDT_addr[0x40] = 0; // WDT_en
  asm("j _start");
}


void interrupt_sel () {
	asm("csrr t5, mip");	
	asm("lui t6, 0x1");
	asm("addi t6, t6, -2048");
	asm("and t6, t5, t6");	
	asm("j wdt_interrupt");	
	asm("beqz t6,12");
	//asm("jal ra, copy");
	asm("beqz x0, 24");
	asm("andi t5, t5, 128");
	asm("beqz t5, 12");
	asm("jal ra, wdt_interrupt");
	asm("beqz x0, 8");	
	asm("jal ra,copy");
	asm("li t6, 0x1500");

}


int for_param() {
	int a;
	a = 100; 
	return a;
};



int main(void) {
  extern unsigned int _test_start;
  int *sort_addr = &_test_start;
  int sort_count = 0;
  copy_addr = &_test_start;
  
  *(copy_addr) = 0;
  *(copy_addr) = -1;
  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x80");
  asm("csrs mie, t6"); // MEIE of mie 
 

  WDT_addr[0xc0] = 10000; // tonet
  WDT_addr[0x40] = 1; // WDT_en
  
  int a = 1;
  int b = 2;
  int c = 0;

  int for_count = 0;
	  for_count = for_param();
	  for(int i = 0; i < 100; i++){
		for(int j = 0; j < for_count; j++){ 
		  c = c + j;
		}
		  WDT_addr[0x80] = 1; // live_en
          WDT_addr[0x80] = 0; // live_en 
	  }
	  *(copy_addr + 1) = c;

  return 0;
}
