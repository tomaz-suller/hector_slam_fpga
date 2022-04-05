
module bresenham
(
    input logic clock, reset,
                start,
    input logic [31:0] magnitude, angle,
                  sensor_x, sensor_y,
    input logic occupancy_busy,
    output logic [4:0] x_index,
    output logic [3:0] y_index,
    output logic cell_is_free, write_enable,
    output logic busy
);

    logic x_source, x_we;
    logic [4:0] current_x;

    bresenham_cu control_unit (.*);
    bresenham_df data_flow (.*);

endmodule: bresenham
