unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;

volatile unsigned int *WDT_addr = (int *) 0x10010000;
volatile unsigned int *ITRP_addr = (int *) 0x10020000;
unsigned int *DMA_src_addr  = (unsigned int*)0x50001000;
unsigned int *DMA_dest_addr = (unsigned int*)0x50002000;
unsigned int *DMA_len_addr  = (unsigned int*)0x50003000;
unsigned int *DMA_ctrl_addr = (unsigned int*)0x50004000;
/*****************************************************************
 * Function: void copy()                                         *
 * Description: Part of interrupt service routine (ISR).         *
 *              Copy data from sensor controller to data memory. *
 *****************************************************************/
void copy () {
  unsigned int *sensor_addr = (int *) 0x10000000;
  int i;
  // Enable Global Interrupt
  // asm("csrsi mstatus, 0x8"); // MIE of mstatus
  // // Enable Local Interrupt
  // asm("li t6, 0x800");
  // asm("csrs mie, t6"); // MEIE of mie 
  // *DMA_src_addr  = (unsigned int)sensor_addr;
  // *DMA_dest_addr = (unsigned int)copy_addr;
  // *DMA_len_addr  = sensor_size;
  // *DMA_ctrl_addr = 1;
  // asm("wfi");
  for (i = 0; i < sensor_size; i++) { // Copy data from sensor controller to DM
    *(copy_addr + i) = sensor_addr[i];
  }
  copy_addr += sensor_size; // Update copy address
  copy_count++;    // Increase copy count
  sensor_addr[0x2400] = 1; // Enable sctrl_clear
  sensor_addr[0x2400] = 0; // Disable sctrl_clear
  // if (copy_count == 8) {
  //   asm("li t6, 0x80");
  //   asm("csrc mstatus, t6"); // Disable MPIE of mstatus
  // }
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
};

int main(void) {
  unsigned int *sensor_addr = (int *) 0x10000000;
  extern unsigned int _test_start;
  int *sort_addr = &_test_start;
  int sort_count = 0;
  copy_addr = &_test_start;

  // Enable Sensor Controller
  sensor_addr[0x2000] = 1; // Enable sctrl_en

  while (sort_count != 2) {
    //while (sort_count == copy_count / 4) { // Sensor controller isn't ready
	  while (copy_count < 8) {
      // Wait for interrupt of sensor controller
      if (sensor_addr[0x2401] == 1)
      {
        copy();
      }
      // Because there is only one interrupt source, we don't need to poll interrupt source
    }

    // Start sorting
    sort(sort_addr, sensor_size * 4);
    sort_addr += sensor_size * 4;
    sort_count++;
  }

  return 0;
}
