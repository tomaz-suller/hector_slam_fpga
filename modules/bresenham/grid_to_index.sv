`include "../packages.sv"

module grid_to_index
    import fixed_pkg::fixed_t,
           ram_pkg::index_t;
(
    input fixed_t grid,
    output index_t index
);

    assign index = ram_pkg::INDEX_WIDTH'(grid.integer_);

endmodule: grid_to_index
