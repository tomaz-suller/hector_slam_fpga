module grid_to_index
#(
    parameter INDEX_WIDTH = 4
)
(
    input logic [31:0] grid,
    output logic [INDEX_WIDTH-1:0] index
);

    assign index = INDEX_WIDTH'(grid[31:18]);

endmodule: grid_to_index
