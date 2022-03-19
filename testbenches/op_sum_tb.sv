`include "defines.vh"

// $shortrealtobits
// $bitstoshortreal
module op_sum_tb;
  shortreal a_r;
  shortreal b_r;
  shortreal r_r;
  wire [`VSIZE-1:0] a, b, r;

  assign a   = $shortrealtobits(a_r);
  assign b   = $shortrealtobits(b_r);
  assign r_r = $bitstoshortreal(r);

  op_sum UUT (.a(a), .b(b), .r(r));

  initial begin
    a_r <= 1.5;
    b_r <= 2.3;
    #1;
    basic_sum:
    assert (r_r == 3.8)
    else
        $error("%m checker failed");
  end
endmodule

