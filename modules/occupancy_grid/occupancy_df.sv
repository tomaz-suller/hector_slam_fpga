
module occupancy_df
(
    input logic clock,
    input logic zero_cell, write_enable, cell_is_free,
                reset_counter, enable_counter,
    input logic [7:0] x,
    input logic [6:0] y,
    output logic [7:0] data_out,
    output logic count_done
);
    logic [7:0] memory_input;
    logic [7:0] x_count, x_memory;
    logic [6:0] y_count, y_memory;
    logic [14:0] address;

    always_ff @( posedge(clock) ) begin : IndexCounter
        if (reset_counter) begin
            x_count = 0;
            y_count = 0;
        end
        if (enable_counter) begin
            if (&x_count) y_count += 1;
            x_count += 1;
        end
    end
    assign count_done = (&x_count) & (&y_count);

    always_comb begin : MemoryInputMux
        if (zero_cell) memory_input = 0;
        else
            if (cell_is_free)
                // Do not allow overflow when memory contains 126
                if ( (~data_out[7]) & (&data_out[6:0]) )
                    memory_input = data_out;
                else memory_input = data_out - 1;
            else
                // Do not allow underflow when memory contains -127
                if ( (data_out[7]) & (~|data_out[6:0]) )
                    memory_input = data_out;
                else memory_input = data_out + 1;    end

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
