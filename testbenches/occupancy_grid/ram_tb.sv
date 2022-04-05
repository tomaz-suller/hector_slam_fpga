`timescale 1ns/1ps

module ram_tb;
    localparam CLOCK_PERIOD = 10;

    logic clock = 1;
    always #( CLOCK_PERIOD/2 ) clock = ~clock;

    logic write_enable;
    logic [14:0] address;
    logic [7:0] input_data;
    logic [7:0] output_data;

    ram dut (.*);

    initial begin
        write_enable = 0;
        address = 9'b000000000;
        #(1*CLOCK_PERIOD)
        input_data = 8'b01010111;
        write_enable = 1;
        #(1*CLOCK_PERIOD)
        write_enable = 0;
        #(2*CLOCK_PERIOD)
        address = 9'b000000001;
        input_data = 8'b01010110;
        write_enable = 1;
        #(1*CLOCK_PERIOD)
        write_enable = 0;
        #(2*CLOCK_PERIOD)
        address = 9'b100000000;
        input_data = 8'b11111111;
        #(2*CLOCK_PERIOD)
        address = 9'b000000001;
        #(5*CLOCK_PERIOD)
        $stop;
    end

endmodule: ram_tb
