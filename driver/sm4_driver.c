#include "sm4_driver.h"
#include <stdio.h>
static volatile int *timer_base = (int *)0x42800000;

void setupTimer(){
	timer_base[0] = 0;
}

void startTimer(){
	timer_base[1] = 0;
	timer_base[0] = 0x20; // Load zero.
	timer_base[0] = 0x80; // Start Timer.
}

int stopTimer(){
	timer_base[0] = 0;
	return timer_base[2];
}

void config(volatile void *device, int enable_protection, int enable_interrupt){
    volatile int *base_device = (volatile int *)device;
    base_device[0xE] = (enable_protection) | (enable_interrupt << 1);
}

void handle_irq(volatile void *device){
    volatile int *base_device = (volatile int *)device;
    base_device[0xF] = 0x8;
}
struct QWord encrypt(volatile void *device, struct QWord content, struct QWord key, int is_decrypt, int mask){
    struct QWord res = {0, 0, 0, 0};
    volatile int *base_device = (volatile int *)device;
    for(int i = 0; i <4; i++) {
        base_device[i] = content.value[i];
        base_device[i+4] = key.value[i];
    }
    base_device[0xD] = mask;
    base_device[0xF] = 1 | (is_decrypt << 1); // Start
    while(!base_device[0xC]);
    handle_irq(device);
    for(int i = 0; i <4; i++){
        res.value[i] = base_device[i+8];
    }

    return res;
}

void invalid_cache(volatile void *device){
	volatile int *base_device = (volatile int *)device;
	base_device[0xF] = 0x4;
}

int ecb_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, char *output, int is_decrypt, int mask,char *time_recording){
    unsigned int expected_n = (N >> 4) + ((N % 16) != 0);
    unsigned int index = 0;
    volatile int *base_device = (volatile int *)device;
    for(int i = 0; i <4; i++){
        base_device[i+4] = key.value[i];
    }
    base_device[0xF] = mask;
    for(int i = 0; i < expected_n; i++){
        volatile char *buffer_target = (char *)(device);
        for(int i = 0; i < 16; ++i){
            if(index < N)
                buffer_target[i] = input[index];
            else
                buffer_target[i] = 0;
            ++index;
        }
    // Start encryption
    base_device[0xD] = mask;
    base_device[0xF] = 1 | (is_decrypt << 1); // Start
    startTimer();
    while(!base_device[0xC]);
    time_recording[expected_n] = stopTimer();
    handle_irq(device);
        for(int j = 0; j < 4; ++j){
            ((struct QWord *)output)[i].value[j] = base_device[j+8];
        }
    }
    return expected_n * 16;
}

int cbc_encrypt(volatile void *device, char *input, unsigned N, struct QWord key, struct QWord initial, char *output, int is_decrypt, int mask,char *time_recording){
    unsigned int expected_n = (N >> 4) + ((N % 16) != 0);
    unsigned int index = 0;
    unsigned int decrypt_index = 0;
    volatile int *base_device = (volatile int *)device;
    for(int i = 0; i <4; i++){
        base_device[i+4] = key.value[i];
    }
    base_device[0xF] = mask;
    for(int i = 0; i < expected_n; ++i){
        volatile char *buffer_target = (char *)(device);
        char *initial_buffer = (char *)(&initial);
        for(int i = 0; i < 16; ++i){
            if(index < N)
                if(!is_decrypt)
                    buffer_target[i] = input[index] ^ initial_buffer[i];
                else
                    buffer_target[i] = input[index];
            else
                if(!is_decrypt)
                    buffer_target[i] = initial_buffer[i];
                else
                    buffer_target[i] = 0;
            ++index;
        }
    base_device[0xD] = mask;
    base_device[0xF] = 1 | (is_decrypt << 1); // Start
    startTimer();
    while(!base_device[0xC]);
    time_recording[expected_n] = stopTimer();
    handle_irq(device);
        for(int j = 0; j < 4; ++j){
            if(!is_decrypt){ //encryption
                ((struct QWord *)output)[i].value[j] = base_device[j+8];
                initial.value[j] = base_device[j+8];
            } else { // decryption
                ((struct QWord *)output)[i].value[j] = base_device[j+8] ^ initial.value[j];
            }
        }
        if(is_decrypt){
            for(int j = 0; j < 16; ++j){ // replace the initial buffer with last encryption data.`
                if(decrypt_index < N)
                    initial_buffer[j] = input[decrypt_index];
                else
                    initial_buffer[j] = 0;
                ++decrypt_index;
            }
        }
            
    }
    return expected_n * 16;
}
