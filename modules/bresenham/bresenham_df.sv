
module bresenham_df
(
    input logic clock,
    input logic [31:0] magnitude, angle,
                       sensor_x, sensor_y,
    input logic x_source, x_we,
    output logic [4:0] current_x,
    output logic [4:0] x_index,
    output logic [3:0] y_index
);

    logic flip_x, flip_y, flip_identity;
    logic [31:0] reduced_angle,
                 cos_value, tan_value,
                 x_world, y_world,
                 x_grid, y_grid;
    logic [31:0] x_grid_reg;
    logic [4:0] x_raw, x_relative;
    logic [3:0] y_raw, y_relative;

    reduce_angle angle_to_first_octant (.*);

    cossine_lut cossine (
        .in(reduced_angle),
        .out(cos_value)
    );
    tangent_lut tangent (
        .in(reduced_angle),
        .out(tan_value)
    );

    assign x_world = magnitude * cos_value;

    world_to_grid x_world_to_grid (
        .world(x_world),
        .grid(x_grid)
    );

    always_ff @( posedge(clock) ) begin : XGridReg
        if (x_we)
            if (x_source) x_grid_reg = x_grid-1;
            else x_grid_reg = x_grid;
    end

    assign y_world = x_grid_reg * tan_value;
    world_to_grid y_world_to_grid (
        .world(y_world),
        .grid(y_grid)
    );

    grid_to_index #( 5 ) x_grid_to_index (
        .grid(x_grid_reg),
        .index(x_raw)
    );
    assign current_x = x_raw;
    grid_to_index #( 4 ) y_grid_to_index (
        .grid(y_grid),
        .index(y_raw)
    );

    flip_indices index_flip (
        .x_in(x_raw),
        .y_in(y_raw),
        .x(x_relative),
        .y(y_relative),
        .*
    );

    world_to_grid sensor_x_world_to_grid (
        .world(sensor_x),
        .grid(sensor_x_grid)
    );
    grid_to_index #( 5 ) sensor_x_grid_to_index (
        .grid(sensor_x_grid),
        .index(sensor_x_index)
    );
    world_to_grid sensor_y_world_to_grid (
        .world(sensor_y),
        .grid(sensor_y_grid)
    );
    grid_to_index #( 4 ) sensor_y_grid_to_index (
        .grid(sensor_y_grid),
        .index(sensor_y_index)
    );

    assign x_index = sensor_x_index + x_relative;
    assign y_index = sensor_y_index + y_relative;

endmodule: bresenham_df
