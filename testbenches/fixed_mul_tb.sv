`include "../modules/packages.sv"

module op_mul_tb
    import fixed_pkg::*;
  ();
  fixed_t a          = 32'b00000000000000100000000000000000; // 0.5
  fixed_t b          = 32'b00000000000010000000000000000000; // 2
  fixed_t r_expected = 32'b00000000000001000000000000000000; // 1
  fixed_t r;

  fixed_mul UUT (.a(a), .b(b), .r(r));

  initial begin
    basic_mul:
    assert (r == r_expected)
    else
        $error("%m checker failed");
  end
endmodule

