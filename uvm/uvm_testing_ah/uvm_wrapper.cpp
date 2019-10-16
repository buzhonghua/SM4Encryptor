#include "../../include/sm4_encryptor.hpp"
#include "svdpi.h"

QWord parseBitVector(const svBitVecVal *key){
    QWord res;
    for(int i = 0; i < 4; ++i){
        res[i] = key[i];
    }
    return res;
}

void encrypt_cpp(const svBitVecVal *key, const svBitVecVal* value, const svBitVecVal decode, svBitVecVal* result){
    // First, convert svBitVecVal to QWord
    QWord key_q = parseBitVector(key);
    QWord value_q = parseBitVector(value);
    QWord res = encryption(value_q, key_q, decode != 0);

    for(int i = 0; i < 4; ++i){
        result[i] = res[i];
    }
}


extern "C" void encryption(const svBitVecVal *key, const svBitVecVal* value, const svBitVecVal decode, svBitVecVal* result){
    encrypt_cpp(key, value, decode, result);   
}