module world_to_grid
(
    input logic [31:0] world,
    output logic [31:0] grid
);

    assign grid = world;

endmodule: world_to_grid
