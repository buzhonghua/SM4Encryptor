#include "obj_dir/Vsbox_backup.h"
#include <verilated.h>
#include <stdio.h>

int main(int argc, char *argv[]){

    Verilated::commandArgs(argc, argv);
    Vsbox_backup *dut = new Vsbox_backup{};

    int a = 0x85;
    int b = 0x84;

    dut->i = a;
    dut->m = b;
    dut->test_clk_i = 0;
    dut->eval();

    dut->test_clk_i = 1;
    dut->eval();

    dut->test_clk_i = 0;
    dut->eval();

    printf("dut->o = %x, dut->m_o = %x, combined: %x\n", dut->o, dut->m_o, dut->o ^ dut->m_o);

    dut->i = a ^ b;
    dut->m = 0x0;
    dut->test_clk_i = 0;
    dut->eval();
    
    dut->test_clk_i = 1;
    dut->eval();

    printf("dut->o = %x, dut->m_o = %x, combined: %x\n", dut->o, dut->m_o, dut->o ^ dut->m_o);

    return 0;
}