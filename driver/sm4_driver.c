#include "sm4_driver.h"

/*
    address         Write           Read
    0x0-0x3         content         content
    0x4-0x7         key             key
    0x8-0xB                         result
    0xC             start           ready
    0xD             decode          
    0xE             clear cache
    0xF             shuffle_seed
*/

struct QWord encrypt(void *device, struct QWord content, struct QWord key, int is_decrypt){
    struct QWord res = {0, 0, 0, 0};
    volatile char *base_device = (volatile char *)device;
    for(int i = 0; i <4; i++) {
        base_device[i] = content.value[i];
        base_device[i+4] = key.value[i];
    }
    base_device[0xD] = is_decrypt;
    base_device[0xC] = 1; // Start
    while(!base_device[0xC]);
    for(int i = 0; i <4; i++){
        res.value[i] = base_device[i+8];
    }

    return res;
}

void ecb_encrypt (void *device, char *input, unsigned N, struct QWord key, char *output){
    unsigned extend_n;
    if(N % 3){
        extend_n = (N >> 2) + 1;
    } else {
        extend_n = (N >> 2);
    }
    for(int i = 0; i < extend_n; i++){
        struct QWord word;
        for(int j = 0; j < 4; ++j){
            if(4*i + j < N)
                word.value[j] = input[4*i+j];
            else
                word.value[j] = 0;
        }
        struct QWord res = encrypt(device, word, key, 0);
        for(int j = 0; j < 4; j++){
            output[4*i + j] = res.value[j];
        }
    }
}

void cbc_encrypt(void *device, char *input, unsigned N, struct QWord key, char *output){
    unsigned extend_n;
    if(N % 3){
        extend_n = (N >> 2) + 1;
    } else {
        extend_n = (N >> 2);
    }
    struct QWord last = {0, 0, 0, 0};
    for(int i = 0; i <4; i++){
        struct QWord word = {0, 0, 0, 0};
        for(int j = 0; j <4; j++){
            if(4*i + j < N)
                word.value[j] = input[4*i+j] ^ last.value[j];
            else
                word.value[j] = last.value[j];
        }
        struct QWord res = encrypt(device, word, key, 0);
        for(int j = 0; j < 4; j++){
            last.value[j] = res.value[j];
            output[4*i + j] = res.value[j];
        }
    }
}

void ecb_decrypt (void *device, char *input, unsigned N, struct QWord key, char *output){
    unsigned extend_n;
    if(N % 3){
        extend_n = (N >> 2) + 1;
    } else {
        extend_n = (N >> 2);
    }
    for(int i = 0; i < extend_n; i++){
        struct QWord word;
        for(int j = 0; j < 4; ++j){
            if(4*i + j < N)
                word.value[j] = input[4*i+j];
            else
                word.value[j] = 0;
        }
        struct QWord res = encrypt(device, word, key, 1);
        for(int j = 0; j < 4; j++){
            output[4*i + j] = res.value[j];
        }
    }
}

void cbc_decrypt(void *device, char *input, unsigned N, struct QWord key, char *output){
    unsigned extend_n;
    if(N % 3){
        extend_n = (N >> 2) + 1;
    } else {
        extend_n = (N >> 2);
    }
    struct QWord last = {0, 0, 0, 0};
    for(int i = 0; i <4; i++){
        struct QWord word = {0, 0, 0, 0};
        for(int j = 0; j <4; j++){
            if(4*i + j < N)
                word.value[j] = input[4*i+j];
            else
                word.value[j] = last.value[j];
        }
        struct QWord res = encrypt(device, word, key, 1);
        for(int j = 0; j < 4; j++){
            output[4*i + j] = res.value[j] ^ last.value[j];
            last.value[j] = res.value[j];
        }
    }
}
