#include "obj_dir/Vsbox.h"
#include <verilated.h>
#include <stdio.h>

int main(int argc, char *argv[]){

    Verilated::commandArgs(argc, argv);
    Vsbox *dut = new Vsbox{};

    int b = 0x84;

    for(int i = 0; i < 16; ++i){
        for(int j = 0; j < 16; ++j){
            dut->i = (i*16 + j) ^ b;
            dut->m = b;
            dut->test_clk_i = 0;
            dut->eval();

            printf("%x ",dut->o ^ dut->m_o);
        }
        printf("\n");
    }


    for(int i = 0; i < 16; ++i){
        for(int j = 0; j < 16; ++j){
            dut->i = (i*16 + j) ^ 0;
            dut->m = 0;
            dut->test_clk_i = 0;
            dut->eval();

            printf("%x ",dut->o ^ dut->m_o);
        }
        printf("\n");
    }

    return 0;
}