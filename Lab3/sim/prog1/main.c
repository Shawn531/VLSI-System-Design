///+++++++++++++++++++++++++++++++++++++++++++++
//=============================================
//   Topic      : Sort algorithm
//   Author     : Hsin-Hang Wu
//   E-mail     : N26124395@gs.ncku.edu.tw
//+++++++++++++++++++++++++++++++++++++++++++++
//   File Name        : main.c
//   Module Name      : Bubble
//   Earliest start   : 2023/09/25
//   The last updated : 2023/10/25
//+++++++++++++++++++++++++++++++++++++++++++++
//=============================================

#include <stdint.h>
extern unsigned int array_size;
extern short array_addr;
const short* array = &array_addr;
extern short _test_start;
short* dest = &_test_start;

void bubbleSort(int16_t arr[], uint32_t size) {
    for (uint32_t i = 0; i < size - 1; i++) {
        for (uint32_t j = 0; j < size - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // Swap arr[j] and arr[j+1]
                int16_t temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

int main() {
    // Copy the array to the destination
    for (uint32_t i = 0; i < array_size; i++) {
        dest[i] = array[i];
    }

    // Perform bubble sort on the dest array
    bubbleSort(dest, array_size);

    return 0;
}
