`include "../packages.sv"

module fixed_mul
    import fixed_pkg::*;
    (
        input fixed_t a,
        input fixed_t b,
        output fixed_t r
    );
    logic [WIDTH*2-1:0] r_long = a * b;
    assign r = r_long >> FRACTION_WIDTH;
endmodule

