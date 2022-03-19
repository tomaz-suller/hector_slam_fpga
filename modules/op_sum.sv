`include "defines.vh"

// + operator
module op_sum (
  input [`VSIZE-1:0] a,
  input [`VSIZE-1:0] b,
  output [`VSIZE-1:0] r
);
  assign r = $shortrealtobits($bitstoshortreal(a) + $bitstoshortreal(b));
endmodule
