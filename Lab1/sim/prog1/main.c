///+++++++++++++++++++++++++++++++++++++++++++++
//=============================================
//   Topic      : Sort algorithm
//   Author     : Hsin-Hang Wu
//   E-mail     : N26124395@gs.ncku.edu.tw
//+++++++++++++++++++++++++++++++++++++++++++++
//   File Name        : main.c
//   Module Name      : Bubble
//   Earliest start   : 2023/09/25
//   The last updated : 2023/09/25
//+++++++++++++++++++++++++++++++++++++++++++++
//=============================================

void bubbleSort(int* arr, int n) {
    int temp;
    int swapped; 

    for (int i = 0; i < n - 1; i++) {
        swapped = 0; 

        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
                swapped = 1;
            }
        }
        if (swapped == 0) {
            break;
        }
    }
}

int main(void) {
    extern int array_size;
    extern int array_addr;
    extern int _test_start;

    bubbleSort(&array_addr, array_size);

    for (int i = 0; i < array_size ; i++){
        *((&_test_start)+i)=*((&array_addr)+i);
    }
return 0;
}





