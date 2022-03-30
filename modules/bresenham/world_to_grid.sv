`include "../packages.sv"

module world_to_grid
    import fixed_pkg::fixed_t;
(
    input fixed_t world,
    output fixed_t grid
);

    assign grid = world;

endmodule: world_to_grid
