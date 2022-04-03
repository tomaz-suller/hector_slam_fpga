`include "../packages.sv"
`include "reduce_angle.sv"
`include "cossine_lut.sv"
`include "tangent_lut.sv"
`include "world_to_grid.sv"
`include "grid_to_index.sv"
`include "flip_indices.sv"

module bresenham_df
    import fixed_pkg::fixed_t,
           ram_pkg::index_t;
(
    input logic clock,
    input fixed_t magnitude, angle,
                  sensor_x, sensor_y,
    input logic x_source, x_we,
    output fixed_t current_x,
    output index_t x_index, y_index
);

    logic flip_x, flip_y, flip_identity;
    fixed_t reduced_angle,
            cos_value, tan_value,
            x_world, y_world,
            x_grid, y_grid;
    fixed_t x_grid_reg;
    index_t x_raw, y_raw,
            x_relative, y_relative;

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

    grid_to_index x_grid_to_index (
        .grid(x_grid_reg),
        .index(x_raw)
    );
    assign current_x = x_raw;
    grid_to_index y_grid_to_index (
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
    grid_to_index sensor_x_grid_to_index (
        .grid(sensor_x_grid),
        .index(sensor_x_index)
    );
    world_to_grid sensor_y_world_to_grid (
        .world(sensor_y),
        .grid(sensor_y_grid)
    );
    grid_to_index sensor_y_grid_to_index (
        .grid(sensor_y_grid),
        .index(sensor_y_index)
    );

    assign x_index = sensor_x_index + x_relative;
    assign y_index = sensor_y_index + y_relative;

endmodule: bresenham_df
