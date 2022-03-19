`include "defines.vh"

// cos operator
module op_cos (
  input [`VSIZE-1:0] a,
  output [`VSIZE-1:0] r
);
  assign r = $shortrealtobits($cos($bitstoshortreal(a)));
endmodule
