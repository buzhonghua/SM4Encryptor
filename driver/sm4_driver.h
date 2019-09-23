#ifndef SM4_DRIVER_H
#define SM4_DRIVER_H

#include <stdint.h>

struct QWord{
    int value[4];
};

struct QWord encrypt(void *device, struct QWord content, struct QWord key, int is_decrypt);

void ecb_encrypt(void *device, char *input, unsigned N, struct QWord key, char *output);
void ecb_decrypt(void *device, char *input, unsigned N, struct QWord key, char *output);

void cbc_encrypt(void *device, char *input, unsigned N, struct QWord key, char *output);
void cbc_decrypt(void *device, char *input, unsigned N, struct QWord key, char *output);


#endif
