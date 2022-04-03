`include "../packages.sv"
`include "bresenham_df.sv"
`include "bresenham_cu.sv"

module bresenham
    import fixed_pkg::fixed_t,
           ram_pkg::width_index_t,
           ram_pkg::height_index_t;
(
    input logic clock, reset,
                start,
    input fixed_t magnitude, angle,
                  sensor_x, sensor_y,
    output width_index_t x_index,
    output height_index_t y_index,
    output logic cell_is_free, write_enable,
    output logic busy
);

    logic x_source, x_we;
    width_index_t current_x;

    bresenham_cu control_unit (.*);
    bresenham_df data_flow (.*);

endmodule: bresenham
