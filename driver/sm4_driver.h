#ifndef SM4_DRIVER_H
#define SM4_DRIVER_H

struct QWord{
    int value[4];
};
// Uncoment this macro to enable AXI Timer profiling.
//#define SM4_PROFILE

struct QWord encrypt(volatile void *device, struct QWord content, struct QWord key, int is_decrypt, int mask = 0);

void invalid_cache(volatile void *device);


int ecb_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, char *output, int is_decrypt,  int mask = 0);

int cbc_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, struct QWord initial, char *output, int is_decrypt,  int mask = 0);


#endif
