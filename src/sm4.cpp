// SM4.cpp 
// This C++ file implements the SM4 encryption algorithm.
// And it serves for Verilator to verify the top design.

#include <cstdint>
#include <vector>
#include <cstdio>

constexpr unsigned char sbox[] = {
    214, 144, 233, 254, 204, 225, 61, 183, 22, 182, 20, 194, 40, 251, 44, 5, 43, 103, 154, 118, 42, 190, 4, 195, 170, 68, 19, 38, 73, 134, 6, 153, 156, 66, 80, 244, 145, 239, 152, 122, 51, 84, 11, 67, 237, 207, 172, 98, 228, 179, 28, 169, 201, 8, 232, 149, 128, 223, 148, 250, 117, 143, 63, 166, 71, 7, 167, 252, 243, 115, 23, 186, 131, 89, 60, 25, 230, 133, 79, 168, 104, 107, 129, 178, 113, 100, 218, 139, 248, 235, 15, 75, 112, 86, 157, 53, 30, 36, 14, 94, 99, 88, 209, 162, 37, 34, 124, 59, 1, 33, 120, 135, 212, 0, 70, 87, 159, 211, 39, 82, 76, 54, 2, 231, 160, 196, 200, 158, 234, 191, 138, 210, 64, 199, 56, 181, 163, 247, 242, 206, 249, 97, 21, 161, 224, 174, 93, 164, 155, 52, 26, 85, 173, 147, 50, 48, 245, 140, 177, 227, 29, 246, 226, 46, 130, 102, 202, 96, 192, 41, 35, 171, 13, 83, 78, 111, 213, 219, 55, 69, 222, 253, 142, 47, 3, 255, 106, 114, 109, 108, 91, 81, 141, 27, 175, 146, 187, 221, 188, 127, 17, 217, 92, 65, 31, 16, 90, 216, 10, 193, 49, 136, 165, 205, 123, 189, 45, 116, 208, 18, 184, 229, 180, 176, 137, 105, 151, 74, 12, 150, 119, 126, 101, 185, 241, 9, 197, 110, 198, 132, 24, 240, 125, 236, 58, 220, 77, 32, 121, 238, 95, 62, 215, 203, 57, 72
};

using std::uint32_t;

struct QWord {
    uint32_t v[4];
    QWord(){
        for(auto &p : this->v){
            p = 0;
        }
    }
    uint32_t &operator[](uint32_t i){
        return this->v[i];
    }

    const uint32_t &operator[](uint32_t i) const {
        return this->v[i];
    }

    QWord operator << (int32_t j) const {
        QWord result;
        for(int i = 0; i < 4-j; ++i){
            result[i] = this->operator[](i+j);
        }
        for(int i = 3; i >= 4-j; --i){
            result[i] = 0;
        }
        return result;
    }

    void reverseInPlace(){
        std::swap(this->v[0], this->v[3]);
        std::swap(this->v[1], this->v[2]);
    }
};

uint32_t lookupSBox(uint32_t v){
    uint32_t result = 0;
    unsigned char *x = reinterpret_cast<unsigned char *>(&v);
    unsigned char* y = reinterpret_cast<unsigned char *>(&result);
    for(int i = 0; i < 4; ++i){
        y[i] = sbox[x[i]];
    }
    return result;
}

inline uint32_t rol(uint32_t a, uint32_t sft){
    return a << sft | (a >> (32 - sft));
}

uint32_t turnFunction(const QWord &value, const uint32_t r_keys, std::initializer_list<uint32_t> xor_pos){
    uint32_t A = value.v[1] ^ value.v[2] ^ value.v[3] ^ r_keys;
    uint32_t B = lookupSBox(A);
    // SBox Transformation
    uint32_t res = value.v[0];
    for (uint32_t p : xor_pos){
        res ^= rol(B, p);
    }
    return res;
}

uint32_t FK[4] = {0XA3B1BAC6, 0X56AA3350, 0X677D9197, 0XB27022DC};
uint32_t CK[32] = {
    0X00070E15, 0X1C232A31, 0X383F464D, 0X545B6269,
    0X70777E85, 0X8C939AA1, 0XA8AFB6BD, 0XC4CBD2D9,
    0XE0E7EEF5, 0XFC030A11, 0X181F262D, 0X343B4249,
    0X50575E65, 0X6C737A81, 0X888F969D, 0XA4ABB2B9,
    0XC0C7CED5, 0XDCE3EAF1, 0XF8FF060D, 0X141B2229,
    0X30373E45, 0X4C535A61, 0X686F767D, 0X848B9299,
    0XA0A7AEB5, 0XBCC3CAD1, 0XD8DFE6ED, 0XF4FB0209,
    0X10171E25, 0X2C333A41, 0X484F565D, 0X646B7279
};


QWord encryption(const QWord &value, const QWord &key){
    // 1. Generate Extended Key
    QWord ext_key{};
    for(int i = 0; i < 4; i++) {
        ext_key[i] = key[i] ^ FK[i];
    }
    QWord position = value;
    // 2. Call Turn Function
    for(int i = 0; i < 32; ++i) {
        // generate rk
        uint32_t rk = turnFunction(ext_key, CK[i], {0, 13, 23});
        ext_key = ext_key << 1;
        ext_key[3] = rk;
        uint32_t new_ele = turnFunction(position, rk, {0, 2, 10, 18, 24});
        position = position << 1;
        position[3] = new_ele;
        std::printf("rk[%d] = %x\n", i, rk);
        std::printf("X[%d] = %x\n", i, new_ele);
    }
    position.reverseInPlace();
    return position;
}

int main(int argc, char *argv[]){
    QWord origin{};
    origin[0] = 0x681edf34 ^ 0x01234567;
    origin[1] = 0xd206965e ^ 0x89ABCDEF;
    origin[2] = 0x86b3e94f ^ 0xFEDCBA98;
    origin[3] = 0x536e4246 ^ 0x76543210;
    QWord key{};
    key[0] = 0x01234567;
    key[1] = 0x89ABCDEF;
    key[2] = 0xFEDCBA98;
    key[3] = 0x76543210;
    QWord encrypt = encryption(origin, key);
    std::printf("Final Result: \n");
    for(int i = 0; i < 4; ++i){
        std::printf("%x ", encrypt[i]);
    }
    std::puts("");
    return 0;
}
