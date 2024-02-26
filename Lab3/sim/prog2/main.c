#include <stdint.h>

extern char _test_start;
extern char _binary_image_bmp_start;
extern char _binary_image_bmp_end;
extern unsigned int _binary_image_bmp_size;

int main(void) {
    char* test_start = &_test_start;
    char* bmp_start = &_binary_image_bmp_start;
    unsigned int size = (unsigned int)(&_binary_image_bmp_size);

    // Copy the first 54 bytes directly
    for (int i = 0; i < 54; i++) {
        test_start[i] = bmp_start[i];
    }

    for (int i = 54; i < size; i += 3) {
        char* a0 = &test_start[i];
        char* a1 = a0 + 1;
        char* a2 = a0 + 2;
        char* now_data_address = &bmp_start[i];

        if (*now_data_address == *(now_data_address + 1) &&
            *now_data_address == *(now_data_address + 2)) {
            // If all three components are equal, set all components to that value
            *a0 = *now_data_address;
            *a1 = *now_data_address;
            *a2 = *now_data_address;
        } else {
            // Apply a weighted average to the three components
            char temp = ((*now_data_address) * 11 +
                         (*(now_data_address + 1)) * 59 +
                         (*(now_data_address + 2)) * 30) / 100;

            *a0 = temp;
            *a1 = temp;
            *a2 = temp;
        }
    }

    return 0;
}
