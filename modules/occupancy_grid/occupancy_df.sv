
module occupancy_df
#(
    ONE = 8'(1),
    ZERO = 8'(0)
)
(
    input logic clock,
    input logic zero_cell, write_enable, cell_is_free,
                reset_counter, enable_counter,
    input logic [4:0] x,
    input logic [3:0] y,
    output logic [7:0] data_out,
    output logic count_done
);
    logic [7:0] memory_input;
    logic [4:0] x_count, x_memory;
    logic [3:0] y_count, y_memory;
    logic [8:0] address;

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
