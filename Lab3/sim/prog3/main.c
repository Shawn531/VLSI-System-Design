unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;
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
			int temp;
			temp = arr[i];
			arr[i] = arr[j];
			arr[j] = temp;
		}
	}
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
	quickSort(array, 0, size - 1);
	return;
}

int main(void) {
  extern unsigned int _test_start;
  int *sort_addr = &_test_start;
  int sort_count = 0;
  copy_addr = &_test_start;

  // Enable Global Interrupt
  asm("csrsi mstatus, 0x8"); // MIE of mstatus

  // Enable Local Interrupt
  asm("li t6, 0x800");
  asm("csrs mie, t6"); // MEIE of mie 

  // Enable Sensor Controller
  sensor_addr[0x40] = 1; // Enable sctrl_en

  while (sort_count != 2) {
	while (copy_count < 8) {
      // Wait for interrupt of sensor controller
      asm("wfi");
      // Because there is only one interrupt source, we don't need to poll interrupt source
    }

    // Start sorting
    sort(sort_addr, sensor_size * 4);
    sort_addr += sensor_size * 4;
    sort_count++;
  }

  return 0;
}
