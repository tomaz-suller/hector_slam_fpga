`timescale 1ns/1ps

module hector_slam_fpga_tb;
    localparam CLOCK_PERIOD = 10;
    localparam RAM_SIZE = 256*128;

    logic clock = 1;
    always #( CLOCK_PERIOD/2 ) clock = ~clock;

    logic reset, start;
    integer memory_dumpfile;
    
    logic btnD = reset;
    logic btnC = start;

    hector_slam_fpga dut (.clock(clock), .btnD(btnD), .btnC(btnC));

    initial begin
        memory_dumpfile = $fopen("/tmp/memory_dump.txt", "w");

        start = 0;
        reset = 1;
        #(1*CLOCK_PERIOD)
        reset = 0;
        #(33000*CLOCK_PERIOD)
        start = 1;
        #(1*CLOCK_PERIOD)
        start = 0;
        // # (45805*CLOCK_PERIOD)
        #(620000*CLOCK_PERIOD)

        for (int i = 0; i < RAM_SIZE; i++)
            $fwrite(memory_dumpfile, "%b\n", dut.df.occupancy_module.data_flow.memory.memory[i]);
        $fclose(memory_dumpfile);

        $stop;
    end

endmodule: hector_slam_fpga_tb
