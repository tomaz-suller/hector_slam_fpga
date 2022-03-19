`include "defines.vh"

// tan operator
module op_tan (
  input [`VSIZE-1:0] a,
  output [`VSIZE-1:0] r
);
  assign r = $shortrealtobits($tan($bitstoshortreal(a)));
endmodule
