module hector_slam_fpga
(
    input logic clk, btnD,
    input logic btnC,
    // VGA
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output Hsync,
    output Vsync
);
 
    logic start = btnC;
    logic reset = btnD;
    logic clock;
    logic pxlClk;

    clk_wiz_1 mmclk (
      // Clock out ports
      .clk_out1(clock),
      .clk_out2(pxlClk),
      // Status and control signals
      .reset,
     // Clock in ports
      .clk_in1(clk)
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
