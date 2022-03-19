`include "defines.vh"

// sin operator
module op_sum (
  input [`VSIZE-1:0] a,
  output [`VSIZE-1:0] r
);
  assign r = $shortrealtobits($sin($bitstoshortreal(a)));
endmodule
