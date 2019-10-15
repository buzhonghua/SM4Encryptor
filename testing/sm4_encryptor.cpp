#include "obj_dir/Vsm4_encryptor.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


struct QWord {
    unsigned value[4];
    unsigned &operator[](int index){
        return value[index];
    }
    unsigned operator[](int index) const{
        return value[index];
    }
    void display() const{
        for(int i = 0; i <4; i++){
            printf("%x ", value[i]);
        }
        puts("");
    }

    void randomize(){
        for(int i = 0; i <4; ++i){
            value[i] = rand() & 0x1? - rand() : rand();
        }
    }
};

Vsm4_encryptor *dut;

QWord encrypt(const QWord &key, const QWord &content, bool decode = 1){
    QWord res = {0, 0, 0, 0};
    for(int i = 0; i < 4; ++i){
        dut->content_i[i] = content[i];
        dut->key_i[i] = key[i];
    }
    dut->v_i = 1;
    dut->encode_or_decode_i = decode;
    dut->eval();

    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    while(dut->v_o == 0){
        dut->clk_i = 1;
        dut->eval();
        dut->clk_i = 0;
        dut->eval();
    }

    for(int i = 0; i < 4; ++i){
        res[i] = dut->crypt_o[i];
    }

    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    dut->yumi_i = 1;
    dut->eval();

    dut->clk_i = 1;
    dut->eval();

    dut->clk_i = 0;
    dut->yumi_i = 0;
    dut->v_i = 0;
    dut->eval();

    return res;
}

void invalid_cache(){
    dut->invalid_cache_i = 1;
    dut->eval();
    dut->clk_i = 1;
    dut->eval();
    dut->invalid_cache_i = 0;
    dut->clk_i = 0;
    dut->eval();
}

void reset(){
    dut->reset_i = 1;
    dut->eval();

    dut->clk_i = 1;
    dut->eval();

    dut->reset_i = 0;
    dut->clk_i = 0;
    dut->eval();
}

int main(int argc, char ** argv){
    Verilated::commandArgs(argc, argv);

    srand(time(nullptr));

    dut = new Vsm4_encryptor{};

    dut->clk_i = 0;
    dut->reset_i = 0;
    for(int i = 0; i < 4; ++i){
        dut->content_i[i] = 0;
        dut->key_i[i] = 0;
    }

    dut->encode_or_decode_i = 0;
    dut->v_i = 0;
    dut->yumi_i = 0;

    dut->eval();

    reset();

    for(int i = 0; i < 32; ++i){
        QWord key1;
        key1.randomize();
        key1.display();
        QWord res1 = encrypt(key1, key1, 0);
        res1.display();
        QWord res2 = encrypt(key1, res1,1);
        res2.display();
        QWord keys[4];
        printf("\n");

        for(int i = 0; i < 4; ++i){
            keys[i].randomize();
            QWord tmp_content;
            tmp_content.randomize();
            encrypt(keys[i], tmp_content, rand() & 0x1);
        }

        for(int i = 3; i >>= 0; --i){
            QWord tmp_content;
            tmp_content.randomize();
            encrypt(keys[i], tmp_content, rand() & 0x1);
        }

        reset();
        

        for(int i = 0; i < 8; ++i){
            QWord tmp_content;
            tmp_content.randomize();
            int which = i % 5;
            if(which == 4){
                // Replace one of keys randomly.
                int random_index = rand() % 4;
                keys[random_index].randomize();
                encrypt(keys[i], tmp_content, rand() & 0x1);
            } else {
                encrypt(keys[which], tmp_content, rand() & 0x1);
            }
        }
        invalid_cache();
    }


    VerilatedCov::write("logs/coverage.dat");


    return 0;
}