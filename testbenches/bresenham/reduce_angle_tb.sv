`timescale 1ns/1ps

module reduce_angle_tb;
    logic [31:0] angle = 32'b00000000000001001011011001011111;
    logic [31:0] reduced_angle;
    logic flip_x, flip_y, flip_identity;

    typedef struct packed {
        logic [31:0] input_angle;
        logic [31:0] output_angle;
    } test_t;

    test_t TEST_CASES [0:7] = '{
        //  1 PI/8
        '{32'b00000000000000011001001000011111, 32'b00000000000000011001001000011111},
        //  3 PI/8
        '{32'b00000000000001001011011001011111, 32'b00000000000000011001001000011111},
        //  5 PI/8
        '{32'b00000000000001111101101010011110, 32'b00000000000000011001001000011111},
        //  7 PI/8
        '{32'b00000000000010101111111011011101, 32'b00000000000000011001001000011111}, //
        //  9 PI/8
        '{32'b00000000000011100010001100011101, 32'b00000000000000011001001000011111}, //
        // 11 PI/8
        '{32'b00000000000100010100011101011100, 32'b00000000000000011001001000011111},
        // 13 PI/8
        '{32'b00000000000101000110101110011100, 32'b00000000000000011001001000011111}, //
        // 15 PI/8
        '{32'b00000000000101111000111111011011, 32'b00000000000000011001001000011111}
    };

    reduce_angle dut (.*);

    initial begin
        for (int i = 0; i < 8; i++) begin
            angle = TEST_CASES[i].input_angle;
            #1
            assert (reduced_angle == TEST_CASES[i].output_angle)
            else   $display ("Reduction %d failed. Expected %b but got %b",
                             i,
                             TEST_CASES[i].output_angle,
                             reduced_angle);
        end
        $stop;
    end

endmodule: reduce_angle_tb
