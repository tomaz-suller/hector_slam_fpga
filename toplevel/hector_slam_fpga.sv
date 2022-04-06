module hector_slam_fpga
(
    input logic clock, reset,
    input logic start
);

    logic use_bresenham_indices,
          scan_done, simulation_done,
          address_enable, address_reset,
          position_enable,
          bresenham_start,
          bresenham_busy,
          zero_occupancy_grid,
          occupancy_busy,
          vga_busy;

    control_unit cu (.*);
    data_flow df (.*);

endmodule: hector_slam_fpga
