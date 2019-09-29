#include "verilated.h"
#include "obj_dir/Vsm4_encryptor.h"

#include <stdlib.h>
#include <time.h>

int main(int argc, char ** argv){
    Verilated::commandArgs(argc, argv);
    Vsm4_encryptor *dut = new Vsm4_encryptor{};

    dut->clk_i = 0;
    dut->reset_i = 0;
    for(int i = 0; i < 4; ++i){
        dut->content_i[i] = 0;
        dut->key_i[i] = 0;
    }

    dut->encode_or_decode_i = 0;
    dut->v_i = 0;
    dut->yumi_i = 1;
    dut->mask_i = 0;

    dut->eval();

    dut->reset_i = 1;
    dut->clk_i = 1;
    dut->eval();

    dut->reset_i = 0;
    dut->clk_i = 0;
    dut->eval();

    // Set value.
    dut->content_i[0] = 0x01234567;
    dut->content_i[1] = 0x89ABCDEF;
    dut->content_i[2] = 0xFEDCBA98;
    dut->content_i[3] = 0x76543210;

    dut->key_i[0] = 0x01234567;
    dut->key_i[1] = 0x89ABCDEF;
    dut->key_i[2] = 0xFEDCBA98;
    dut->key_i[3] = 0x76543210;

    srand(time(nullptr));

    dut->v_i = 1;
    dut->encode_or_decode_i = 0;
    dut->mask_i = rand();

    dut->eval();

    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    int cyc1 = 0;

    while(dut->v_o == 0){
        dut->clk_i = 1;
        dut->eval();
        dut->clk_i = 0;
        dut->eval();
        ++cyc1;
        //std::getchar();
    }

    for(int i = 0; i < 4; ++i){
        std::printf("Cyc: %d, out[%d] = %x\n", cyc1, i, dut->crypt_o[i]);
    }

    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    for(int i = 0; i < 4; ++i){
        dut->content_i[i] = dut->crypt_o[i];
    }
    dut->encode_or_decode_i = 1;
    dut->v_i = 1;
    dut->mask_i = rand();
    dut->eval();

    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    cyc1 = 0;

    while(dut->v_o == 0){
        dut->clk_i = 1;
        dut->eval();
        dut->clk_i = 0;
        dut->eval();
        ++cyc1;
        //std::getchar();
    }

    for(int i = 0; i < 4; ++i){
        std::printf("Cyc: %d, out[%d] = %x\n", cyc1, i, dut->crypt_o[i]);
    }


    return 0;
}