`include "../packages.sv"

module ram_2d
    import fixed_pkg::fixed_t,
           ram_pkg::*;
#(
    localparam RAM_HEIGHT = ram_pkg::HEIGHT,
    localparam RAM_WIDTH = ram_pkg::WIDTH
)
(
    input logic clock,
    input logic reset,
    input logic write_enable,
    input width_index_t x,
    input height_index_t y,
    input word_t input_data,
    output word_t output_data
);

    memory_t memory;

    always_ff @( posedge(clock), posedge(reset) ) begin : RAM
        if (reset)
            memory = '{default:'0};
            // for (int i = 0; i < RAM_HEIGHT; i++)
            //     for (int j = 0; j < RAM_WIDTH; j++)
            //         memory[i][j] = WORD_SIZE'(0);
        else if (write_enable)
            memory[y][x] = input_data;
    end
    assign output_data = memory[y][x];

endmodule: ram_2d
