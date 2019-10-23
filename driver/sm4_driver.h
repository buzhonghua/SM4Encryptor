#ifndef SM4_DRIVER_H
#define SM4_DRIVER_H

struct QWord{
    int value[4];
};
// Uncoment this macro to enable AXI Timer profiling.
//#define SM4_PROFILE

void config(volatile void *device, int enable_protection, int enable_interrupt);
void handle_irq(volatile void *device);

struct QWord encrypt(volatile void *device, struct QWord content, struct QWord key, int is_decrypt, int mask);

void invalid_cache(volatile void *device);


int ecb_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, char *output, int is_decrypt,  int mask, char *time_recording);

int cbc_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, struct QWord initial, char *output, int is_decrypt,  int mask, char *time_recording);


#endif
