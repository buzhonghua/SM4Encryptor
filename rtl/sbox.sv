// -------------------------------------------------------
// -- sbox.sv
// -------------------------------------------------------
// Implementation of Sbox based on composite field. 
// We hope to design such a Sbox' that satisfies:
//    SBox(x) = SBox'(x ^ m) ^ m_o
// And the cost is around twice as much as the one without this feature.
// If area is considered as the main factor for the final products, you can set the m to '0 so that
// the design will be optimized without this feature.
// If you need a relative safer implements, please set the m dynamically. 
// -------------------------------------------------------


module sbox(
  input [7:0] i
  ,input [7:0] m_i
  ,output logic [7:0] o
  ,output logic [7:0] m_o
);
  wire [7:0] t1, t2, t3;
  wire [7:0] m1, m2;

  affine_8 aff1(.x(i), .d(t1));
  affine_8 affm1(.x(m_i), .d(m1));

  inversion_8 inv1(.x(t1 ^ 8'b11010011), .mask(m1), .d(t2), .d_masked(m2));

  affine_8 aff2(.x(t2),.d(t3));
  affine_8 affm2(.x(m2), .d(m_o));

  assign o = t3 ^ 8'b11010011;

endmodule

// The affine transformation (x*A+C) (Linear transformation)
module affine_8(
  input [7:0] x,
  output logic [7:0] d
);
  wire t1,t2,t3,t4;

  assign t1 = x[7] ^ x[6];
  assign t2 = x[5] ^ x[4];
  assign t3 = x[3] ^ x[2];
  assign t4 = x[1] ^ x[0];
  assign d[7] = (t1 ^ t4 ^ x[4]);
  assign d[6] = (t1 ^ x[5] ^ x[3] ^ x[0]);
  assign d[5] = t1 ^ t2 ^ x[2];
  assign d[4] = (t2 ^ x[6] ^ x[3] ^ x[1]);
  assign d[3] = t2 ^ t3 ^ x[0];
  assign d[2] = t3 ^ x[7] ^ x[4] ^ x[1];
  assign d[1] = (t3 ^ t4 ^ x[6]);
  assign d[0] = (t4 ^ x[7] ^ x[5] ^ x[2]);

endmodule

//Inversion on GF(2^8)
module inversion_8(
  input [7:0] x,
  input [7:0] mask,

  output logic [7:0] d,
  output logic [7:0] d_masked
);

  wire[3:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;
  wire[3:0] m1, m2, m3, m4, m5, m6, m7, m8, m9;

  mapping_8 map1(.x(x),.d_h(t1),.d_l(t2));
  mapping_8 map2(.x(mask),.d_h(m1), .d_l(m2));

  square_4 sqr1(.x(t1), .mask(m1), .d(t4), .d_masked(m4));
  mul_4 mul1(.x1(t3), .x2(t2), .mask1(m3), .mask2(m2), .d(t5), .d_masked(m5));

  inversion_4 inv1(.x(t6), .mask_i(m6), .d(t7), .mask_o(m7));

  mul_4 mul2(.x1(t1), .x2(t7), .mask1(m1), .mask2(m7), .d(t8), .d_masked(m8));
  mul_4 mul3(.x1(t3), .x2(t7), .mask1(m3), .mask2(m7), .d(t9), .d_masked(m9));

  invmapping_8 imap1(.x1(t8), .x2(t9), .d(d));
  invmapping_8 imap2(.x1(m8), .x2(m9), .d(d_masked));

  assign t3 = t1 ^ t2;
  assign m3 = m1 ^ m2;

  assign t6 = t4 ^ t5;
  assign m6 = m4 ^ m5;

endmodule

//The isomorphic mapping from GF(2^8)to GF((2^4)^2)(Linear Transformation)
module mapping_8(
  input [7:0] x,
  output logic [3:0] d_h,
  output logic [3:0] d_l  
);
  wire t1, t2;

  assign t1 = x[3] ^ x[2];
  assign t2 = x[6] ^ x[4];
  assign d_h[3] = t1 ^ t2 ^ x[1];
  assign d_h[2] = t1 ^ t2 ^ x[5];
  assign d_h[1] = t2 ^ x[7];
  assign d_h[0] = t2;
  assign d_l[3] = t1 ^ x[5] ^ x[1];
  assign d_l[2] = t1 ^ x[7] ^ x[6] ^ x[1];
  assign d_l[1] = x[3] ^ x[1];
  assign d_l[0] = t1 ^ x[5] ^ x[0];

endmodule

//The inverse isomorphic mapping from GF((2^4)^2)to GF(2^8)
module invmapping_8(
  input [3:0] x1,
  input [3:0] x2,
  output logic [7:0] d
);
  wire [7:0] x;
  wire t1, t2, t3;
  assign x = {x1, x2};
  assign t1 = x[7] ^ x[4];
  assign t2 = x[6] ^ x[4];
  assign t3 = x[5] ^ x[2];
  assign d[7] = x[5] ^ x[4];
  assign d[6] = t3 ^ x[7];
  assign d[5] = t1 ^ x[3];
  assign d[4] = t1 ^ t3;
  assign d[3] = t2 ^ x[3] ^ x[1];
  assign d[2] = t1 ^ x[1];
  assign d[1] = t2 ^ x[3];
  assign d[0] = t2 ^ x[0];

endmodule

//The self-involution on GF(2^4), v*(x^2), with v = {1001} 
module square_4(
  input [3:0] x,
  input [3:0] mask,

  output logic [3:0] d,
  output logic [3:0] d_masked
);
  wire [1:0] t1, t2, t3, t4, t5;
  wire [1:0] m1, m2, m3, m4, m5;

  mapping_4 map1(.x(x), .d_h(t1), .d_l(t2));
  mapping_4 map2(.x(mask), .d_h(m1), .d_l(m2));

  mul_2_with_masked mul1(.x1(t1), .x2(t1), .m1(m1), .m2(m1), .d(t4), .d_masked(m4));

  invmapping_4 imap1(.x1(t5), .x2(t3), .d(d)); 
  invmapping_4 imap2(.x1(m5), .x2(m3), .d(d_masked)); 

  assign t3 = {(t2[0] ^ t2[1]), t2[0]};
  assign m3 = {(m2[0] ^ m2[1]), m2[0]};

  assign t5 = t4 ^ t3;
  assign m5 = m4 ^ m3;
endmodule

//The multiplier on GF(2^4)
module mul_4(
  input [3:0] x1,
  input [3:0] x2,

  input [3:0] mask1,
  input [3:0] mask2,

  output logic [3:0] d,
  output [3:0] d_masked
);
  wire [1:0] t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, n;
  wire [1:0] m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12;

  mapping_4 map1(.x(x1), .d_h(t1), .d_l(t2));
  mapping_4 mapm1(.x(mask1), .d_h(m1), .d_l(m2));

  mapping_4 map2(.x(x2), .d_h(t3), .d_l(t4));
  mapping_4 mapm2(.x(mask2), .d_h(m3), .d_l(m4));

  mul_2_with_masked mul1(.x1(t5), .x2(t6), .m1(m5), .m2(m6), .d(t7), .d_masked(m7));
  mul_2_with_masked mul2(.x1(t1), .x2(t3), .m1(m1), .m2(m3), .d(t8), .d_masked(m8));
  mul_2_with_masked mul3(.x1(t2), .x2(t4), .m1(m2), .m2(m4), .d(t9), .d_masked(m9));
  mul_2_with_masked mul4(.x1(t8), .x2(n),  .m1(m8), .m2('0),  .d(t10), .d_masked(m10));

  invmapping_4 imap1(.x1(t11), .x2(t12), .d(d));
  invmapping_4 imap2(.x1(m11), .x2(m12), .d(d_masked));

  assign t5 = t1 ^ t2;
  assign m5 = m1 ^ m2;

  assign t6 = t3 ^ t4;
  assign m6 = m3 ^ m4;

  assign n = 2'b10;

  assign t11 = t7 ^ t9;
  assign m11 = m7 ^ m9;

  assign t12 = t10 ^ t9;
  assign m12 = m10 ^ m9;

endmodule

//Inversion on GF(2^4)
module inversion_4(
  input [3:0] x,
  input [3:0] mask_i,

  output logic [3:0] d,
  output logic [3:0] mask_o
); 
  wire[1:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;
  wire[1:0] m1, m2, m3, m4, m5, m6, m7, m8, m9;

  mapping_4 map1(.x(x),.d_h(t1),.d_l(t2));
  mapping_4 map2(.x(mask_i),.d_h(m1),.d_l(m2));

  square_2 sqr1(.x(t1), .d(t4));
  square_2 sqr2(.x(m1), .d(m4));

  mul_2_with_masked mul1(.x1(t3), .x2(t2), .m1(m3), .m2(m2), .d(t5), .d_masked(m5));

  inversion_2 inv1(.x(t6), .d(t7));
  inversion_2 inv2(.x(m6), .d(m7));
  // perform replacement.

  mul_2_with_masked mul2(.x1(t1), .x2(t7), .m1(m1), .m2(m7), .d(t8), .d_masked(m8));
  mul_2_with_masked mul3(.x1(t3), .x2(t7), .m1(m3), .m2(m7), .d(t9), .d_masked(m9));

  invmapping_4 imap1(.x1(t8), .x2(t9), .d(d));
  invmapping_4 imap2(.x1(m8), .x2(m9), .d(mask_o));

  assign t3 = t1 ^ t2;
  assign m3 = m1 ^ m2;
  assign t6 = t4 ^ t5;
  assign m6 = m4 ^ m5;

endmodule

//The isomorphic mapping from GF(2^4)to GF((2^2)^2)
module mapping_4(
  input [3:0] x,
  output logic [1:0] d_h,
  output logic [1:0] d_l
);
  assign d_h[1] = x[3];
  assign d_l[1] = x[3] ^ x[2];
  assign d_h[0] = d_l[1] ^ x[1];
  assign d_l[0] = x[0];

endmodule

//The inverse isomorphic mapping from GF((2^2)^2)to GF(2^4)
module invmapping_4(
  input [1:0] x1,
  input [1:0] x2,
  output logic [3:0] d
);
  assign d[3] = x1[1];
  assign d[2] = x1[1] ^ x2[1];
  assign d[1] = x1[0] ^ x2[1];
  assign d[0] = x2[0];
   
endmodule

//The self-involution on GF(2^2), N*(x^2), with N = {10} 
module square_2(
  input [1:0] x,
  output logic [1:0] d
);
  assign d[1] = x[0];
  assign d[0] = x[1];

endmodule

//Inversion on GF(2^2)
module inversion_2(
  input [1:0] x,
  output logic [1:0] d
);
  assign d[1] = x[1];
  assign d[0] = x[1] ^ x[0];

endmodule

/*
module mul_2(
  input [1:0] x1,
  input [1:0] x2,
  output logic [1:0] d
);
  wire t1, t2;
  assign t1 = (x1[1] ^ x1[0]) & (x2[1] ^ x2[0]);
  assign t2 = x1[0] & x2[0];
  assign d[1] = t1 ^ t2;
  assign d[0] = (x1[1] & x2[1]) ^ t2;

endmodule

*/

module mul_2_with_masked(
  input [1:0] x1,
  input [1:0] x2,

  input [1:0]  m1,
  input [1:0]  m2,

  output [1:0] d,
  output [1:0] d_masked
);
  wire t1, t2, t3;
  wire m11, m22, m33;


  and_linear_2 a1(
    .x1(x1[1] ^ x1[0]),
    .x2(x2[1] ^ x2[0]),

    .m1(m1[1] ^ m1[0]),
    .m2(m2[1] ^ m2[0]),

    .d_o(t1),
    .m_o(m11)
  );

  and_linear_2 a2(
    .x1(x1[0]),
    .x2(x2[0]),

    .m1(m1[0]),
    .m2(m2[0]),

    .d_o(t2),
    .m_o(m22)
  );

  and_linear_2 a3(
    .x1(x1[1]),
    .x2(x2[1]),
    
    .m1(m1[1]),
    .m2(m2[1]),

    .d_o(t3),
    .m_o(m33)
  );

  assign d[1] = t1 ^ t2;
  assign d_masked[1] = m11 ^ m22;

  assign d[0] = t3 ^ t2;
  assign d_masked[0] = m33 ^ m22;

endmodule

// a linear and operation for mul_2
// (a ^ m1) &' (c ^ m2) = (a & c) ^ (m1 & m2)

module and_linear_2(
  input x1,
  input x2,
  input m1,
  input m2,

  output d_o,
  output m_o
);
  
  assign d_o =  (~x1 & x2 & m1) | (x1 & ~x2 & m2) | (x1 & x2 & (m1 == m2));
  assign m_o = m1 & m2;

endmodule
