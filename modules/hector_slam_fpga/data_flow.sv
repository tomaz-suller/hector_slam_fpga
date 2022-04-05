module data_flow
(
    input logic clock, reset,
    input logic use_bresenham_indices,
    output logic scan_done,
    // Bresenham
    input logic address_enable, address_reset,
                position_enable,
                bresenham_start,
    output logic bresenham_busy,
    // Occupancy grid
    input logic zero_occupancy_grid,
    output logic occupancy_busy
);

    logic [63:0] scan_data;
    logic [63:0] lidar_position;
    logic [7:0] x_bresenham, x_display, x;
    logic [6:0] y_bresenham, y_display, y;
    logic cell_is_free, bresenham_we;

    logic [7:0] occupancy_data;

    logic [12:0] scan_address;
    always_ff @( posedge(clock), posedge(address_reset) ) begin : ScanAddress
        if (address_reset) scan_address = 0;
        else if (address_enable) scan_address += 1;
    end
    assign scan_done = (scan_address == 720);

    scan_memory scans (
        .address(scan_address),
        .data(scan_data),
        .*
    );

    always_ff @( posedge(clock) ) begin : ScanPositionRegister
        if (position_enable) lidar_position = scan_data;
    end

    bresenham bresenham_module (
        .start(bresenham_start),
        .magnitude(scan_data[63:32]),
        .angle(scan_data[31:0]),
        .sensor_x(lidar_position[63:32]),
        .sensor_y(lidar_position[31:0]),
        .occupancy_busy(occupancy_busy),
        .x_index(x_bresenham),
        .y_index(y_bresenham),
        .cell_is_free(cell_is_free),
        .write_enable(bresenham_we),
        .busy(bresenham_busy),
        .*
    );

    // TODO Fix
    assign x_display = x_bresenham;
    assign y_display = y_bresenham;
    //

    always_comb begin : IndicesMux
        if (use_bresenham_indices) begin
            x = x_bresenham;
            y = y_bresenham;
        end
        else begin
            x = x_display;
            y = y_display;
        end
    end

    occupancy occupancy_module (
        .zero_memory(zero_occupancy_grid),
        .bresenham_we(bresenham_we),
        .x(x),
        .y(y),
        .cell_is_free(cell_is_free),
        .data_out(occupancy_data),
        .busy(occupancy_busy),
        .*
    );

endmodule: data_flow