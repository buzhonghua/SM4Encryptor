// -------------------------------------------------------
// -- sbox_memory.sv
// -------------------------------------------------------
// Implementation of Sbox based on composite field. 
// -------------------------------------------------------


module sbox_memory(
  input [7:0] i
  ,output logic [7:0] o
);
  wire [7:0] t1, t2;

  affine_8 aff1(.x(i),.d(t1));
  inversion_8 inv1(.x(t1),.d(t2));
  affine_8 aff2(.x(t2),.d(o));

endmodule

// The affine transformation (x*A+C)
module affine_8(
  input [7:0] x,
  output logic [7:0] d
);
  wire t1,t2,t3,t4;

  assign t1 = x[7] ^ x[6];
  assign t2 = x[5] ^ x[4];
  assign t3 = x[3] ^ x[2];
  assign t4 = x[1] ^ x[0];
  assign d[7] = ~(t1 ^ t4 ^ x[4]);
  assign d[6] = ~(t1 ^ x[5] ^ x[3] ^ x[0]);
  assign d[5] = t1 ^ t2 ^ x[2];
  assign d[4] = ~(t2 ^ x[6] ^ x[3] ^ x[1]);
  assign d[3] = t2 ^ t3 ^ x[0];
  assign d[2] = t3 ^ x[7] ^ x[4] ^ x[1];
  assign d[1] = ~(t3 ^ t4 ^ x[6]);
  assign d[0] = ~(t4 ^ x[7] ^ x[5] ^ x[2]);

endmodule

//Inversion on GF(2^8)
module inversion_8(
  input [7:0] x,
  output logic [7:0] d 
);
  wire[3:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;

  mapping_8 map1(.x(x),.d_h(t1),.d_l(t2));
  square_4 sqr1(.x(t1), .d(t4));
  mul_4 mul1(.x1(t3), .x2(t2), .d(t5));
  inversion_4 inv1(.x(t6), .d(t7));
  mul_4 mul2(.x1(t1), .x2(t7), .d(t8));
  mul_4 mul3(.x1(t3), .x2(t7), .d(t9));
  invmapping_8 imap1(.x1(t8), .x2(t9), .d(d));

  assign t3 = t1 ^ t2;
  assign t6 = t4 ^ t5;

endmodule

//The isomorphic mapping from GF(2^8)to GF((2^4)^2)
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
  output logic [3:0] d
);
  wire [1:0] t1, t2, t3, t4, t5;
  mapping_4 map1(.x(x), .d_h(t1), .d_l(t2));
  mul_2 mul1(.x1(t1), .x2(t1), .d(t4));
  invmapping_4 imap1(.x1(t5), .x2(t3), .d(d)); 

  assign t3 = {(t2[0] ^ t2[1]), t2[0]};
  assign t5 = t4 ^ t3;
endmodule

//The multiplier on GF(2^4)
module mul_4(
  input [3:0] x1,
  input [3:0] x2,
  output logic [3:0] d
);
  wire [1:0] t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, n;
  mapping_4 map1(.x(x1), .d_h(t1), .d_l(t2));
  mapping_4 map2(.x(x2), .d_h(t3), .d_l(t4));
  mul_2 mul1(.x1(t5), .x2(t6), .d(t7));
  mul_2 mul2(.x1(t1), .x2(t3), .d(t8));
  mul_2 mul3(.x1(t2), .x2(t4), .d(t9));
  mul_2 mul4(.x1(t8), .x2(n), .d(t10));
  invmapping_4 imap1(.x1(t11), .x2(t12), .d(d));

  assign t5 = t1 ^ t2;
  assign t6 = t3 ^ t4;
  assign n = 2'b10;
  assign t11 = t7 ^ t9;
  assign t12 = t10 ^ t9;

endmodule

//Inversion on GF(2^4)
module inversion_4(
  input [3:0] x,
  output logic [3:0] d
); 
  wire[1:0] t1, t2, t3, t4, t5, t6, t7, t8, t9;

  mapping_4 map1(.x(x),.d_h(t1),.d_l(t2));
  square_2 sqr1(.x(t1), .d(t4));
  mul_2 mul1(.x1(t3), .x2(t2), .d(t5));
  inversion_2 inv1(.x(t6), .d(t7));
  mul_2 mul2(.x1(t1), .x2(t7), .d(t8));
  mul_2 mul3(.x1(t3), .x2(t7), .d(t9));
  invmapping_4 imap1(.x1(t8), .x2(t9), .d(d));

  assign t3 = t1 ^ t2;
  assign t6 = t4 ^ t5;

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

//The multiplier on GF(2^2)
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