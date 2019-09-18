#include "obj_dir/Vturn_transform.h"
#include "../include/sm4_encryptor.hpp"
#include <verilated.h>
#include <cstdio>

int main(int argc, char** argv){

    Verilated::commandArgs(argc, argv);

    Vturn_transform *dut = new Vturn_transform{};

    dut->rkey_i = 0X00070E15;
    dut->is_key_i = 1;
    dut->i[0] = 0x01234567;
    dut->i[1] = 0x89ABCDEF;
    dut->i[2] = 0xFEDCBA98;
    dut->i[3] = 0x76543210;
    dut->testing_clk_i = 0;
    dut->eval();

    dut->testing_clk_i = 1;
    dut->eval();

    unsigned int res = dut->o;

    QWord w;
    w[0] = 0x01234567;
    w[1] = 0x89ABCDEF;
    w[2] = 0xFEDCBA98;
    w[3] = 0x76543210;

    unsigned int res_expected = turnFunction(w, 0X00070E15, {0, 13, 23});

    std::printf("res=%x, expected=%x\n",res, res_expected);

    return 0;
}