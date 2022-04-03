
module occupancy
(
    input logic clock, reset,
    input logic zero_memory, bresenham_we,
    input logic [4:0] x,
    input logic [3:0] y,
    input logic cell_is_free,
    output logic [7:0] data_out,
    output logic busy
);

    logic count_done,
          write_enable, zero_cell,
          reset_counter, enable_counter;

    occupancy_cu control_unit (.*);
    occupancy_df data_flow (.*);

endmodule: occupancy
