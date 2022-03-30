`include "../packages.sv"
`include "ram.sv"

module occupancy_grid
    import fixed_pkg::fixed_t,
           ram_pkg::*;
#(
    localparam word_t ONE = WORD_SIZE'(1)
)
(
    input logic clock,
    input logic reset, write_enable, cell_is_free,
    input width_index_t x,
    input height_index_t y,
    output word_t value
);
    word_t memory_input;
    always_comb begin : cellIsFreeMux
        if (cell_is_free)
            memory_input = value - ONE;
        else
            memory_input = value + ONE;
    end

    ram_2d memory (.input_data(memory_input),
                   .output_data(value),
                   .*);

endmodule: occupancy_grid
