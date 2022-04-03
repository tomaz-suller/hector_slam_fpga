`include "../packages.sv"
`include "index_to_address.sv"
`include "ram.sv"

module occupancy_df
    import fixed_pkg::fixed_t,
           ram_pkg::*;
#(
    localparam word_t ONE = WORD_SIZE'(1),
    localparam word_t ZERO = WORD_SIZE'(0)
)
(
    input logic clock,
    input logic zero_cell, write_enable, cell_is_free,
                reset_counter, enable_counter,
    input width_index_t x,
    input height_index_t y,
    output word_t data_out,
    output logic count_done
);
    word_t memory_input;
    width_index_t x_count, x_memory;
    height_index_t y_count, y_memory;
    address_t address;

    always_ff @( posedge(clock) ) begin : IndexCounter
        if (reset_counter) begin
            x_count = 0;
            y_count = 0;
        end
        if (enable_counter) begin
            x_count += 1;
            if (&x_count) begin
                x_count = 0;
                y_count += 1;
            end
            if (&y_count) y_count = 0;
        end
    end
    assign count_done = (&x) & (&y);

    always_comb begin : cellIsFreeMux
        if (zero_cell) memory_input = ZERO;
        else
            if (cell_is_free)
                memory_input = data_out - ONE;
            else
                memory_input = data_out + ONE;
    end

    always_comb begin : MemoryIndexMux
        if (zero_cell) begin
            x_memory = x_count;
            y_memory = y_count;
        end
        else begin
            x_memory = x;
            y_memory = y;
        end
    end

    index_to_address index_conversion (
        .x_index(x_memory),
        .y_index(y_memory),
        .*
    );

    ram memory (.clock(clock),
                .input_data(memory_input),
                .output_data(data_out),
                .*);

endmodule: occupancy_df
