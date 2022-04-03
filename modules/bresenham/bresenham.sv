`include "../packages.sv"
`include "bresenham_df.sv"
`include "bresenham_cu.sv"

module bresenham
    import fixed_pkg::fixed_t,
           ram_pkg::index_t;
(
    input logic clock, reset,
                start,
    input fixed_t magnitude, angle,
                  sensor_x, sensor_y,
    output index_t x_index, y_index,
    output logic cell_is_free, write_enable,
    output logic busy
);

    logic x_source, x_we;
    index_t current_x;

    bresenham_cu control_unit (.*);
    bresenham_df data_flow (.*);

endmodule: bresenham
