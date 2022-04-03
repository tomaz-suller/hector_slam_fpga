`include "../packages.sv"

module reduce_angle
    import fixed_pkg::fixed_t;
#(
    localparam fixed_t PI = 'b00000000000011001001000011111101
)
(
    input fixed_t angle,
    output fixed_t reduced_angle,
    output logic flip_y, flip_x, flip_identity
);

    fixed_t first_stage_result,
            second_stage_result,
            third_stage_result;

    always_comb begin : YStage
        if (angle >= PI) begin
            first_stage_result = (PI<<1) - angle;
            flip_y = 1;
        end
        else begin
            first_stage_result = angle;
            flip_y = 0;
        end
    end

    always_comb begin : XStage
        if (first_stage_result >= PI>>1) begin
            second_stage_result = PI - first_stage_result;
            flip_x = 1;
        end
        else begin
            second_stage_result = first_stage_result;
            flip_x = 0;
        end
    end

    always_comb begin : IdentityStage
        if (second_stage_result >= PI>>2) begin
            reduced_angle = (PI>>1) - second_stage_result;
            flip_identity = 1;
        end
        else begin
            reduced_angle = second_stage_result;
            flip_identity = 0;
        end
    end

endmodule: reduce_angle