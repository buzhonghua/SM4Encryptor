#include <stdio.h>
#include <stdlib.h>
#include <time.h>
int iteration(int i){
    return ((i << 7) + (i << 3) + i + 127) % 512;
}

int main(){
    srand(time(NULL));
    for(int k = 0; k < 256; ++k){
        int tmp = k;
        int cyc[32] = {-1};
        bool will_break = false;
        for(int i = 0; i < 32; ++i){
            tmp = iteration(tmp);
            for(int j = 0; j < 32; ++j){
                if(cyc[j] == (tmp % 256)){
                    printf("(%d: Cycle = %d)\n", k, i);
                    will_break = true;
                    break;
                }
            }
            if(will_break)
                break;
            cyc[i] = tmp % 256;
            printf("%d ", cyc[i]);
        }
        printf("\n");
    }
    
    return 0;
}

