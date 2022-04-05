module fixed_multiplication
    (
        input logic [31:0] a,
        input logic [31:0] b,
        output logic [31:0] r
    );
    logic [63:0] r_long = a * b;
    assign r = r_long >> 18;
endmodule: fixed_multiplication

