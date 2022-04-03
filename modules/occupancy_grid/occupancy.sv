`include "../packages.sv"
`include "occupancy_cu.sv"
`include "occupancy_df.sv"

module occupancy
    import ram_pkg::width_index_t,
           ram_pkg::height_index_t,
           ram_pkg::word_t;
(
    input logic clock, reset,
    input logic zero_memory, bresenham_we,
    input width_index_t x,
    input height_index_t y,
    input logic cell_is_free,
    output word_t data_out,
    output logic busy
);

    logic count_done,
          write_enable, zero_cell,
          reset_counter, enable_counter;

    occupancy_cu control_unit (.*);
    occupancy_df data_flow (.*);

endmodule: occupancy
