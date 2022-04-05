`timescale 1ns/1ps

module hector_slam_fpga_tb;
    localparam CLOCK_PERIOD = 10;

    logic clock = 1;
    always #( CLOCK_PERIOD/2 ) clock = ~clock;

    logic reset, start;

    hector_slam_fpga dut (.*);

    initial begin
        start = 0;
        reset = 1;
        #(1*CLOCK_PERIOD)
        reset = 0;
        #(33000*CLOCK_PERIOD)
        start = 1;
        #(1*CLOCK_PERIOD)
        start = 0;
        #(10000*CLOCK_PERIOD)
        $stop;
    end


endmodule: hector_slam_fpga_tb
