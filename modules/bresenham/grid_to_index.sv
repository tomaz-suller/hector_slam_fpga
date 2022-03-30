`include "../packages.sv"

module grid_to_index
    import fixed_pkg::fixed_t;
#(
    parameter INDEX_WIDTH = 5
)
(
    input fixed_t grid,
    output logic [INDEX_WIDTH-1:0] index
);

    assign index = INDEX_WIDTH'(grid.integer_);

endmodule: grid_to_index
