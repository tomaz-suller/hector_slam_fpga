`include "../packages.sv"
`include "cossine_lut.sv"
`include "tangent_lut.sv"
`include "world_to_grid.sv"
`include "grid_to_index.sv"

module bresenham_df
    import fixed_pkg::fixed_t,
           ram_pkg::index_t;
(
    input logic clock,
    input fixed_t magnitude, reduced_angle,
    input logic x_source, x_we, x_clr,
    output index_t x_index, y_index
);

    fixed_t cos_value, tan_value,
            x_world, y_world,
            x_grid, y_grid;
    fixed_t x_grid_reg;

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

    always_ff @( posedge(clock), posedge(x_clr) ) begin : XGridReg
        if (x_clr) x_grid_reg = 0;
        else if (x_we)
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
        .index(x_index)
    );
    grid_to_index y_grid_to_index (
        .grid(y_grid),
        .index(y_index)
    );

endmodule: bresenham_df
