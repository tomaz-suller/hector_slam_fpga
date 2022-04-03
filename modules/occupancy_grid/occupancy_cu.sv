module occupancy_cu
(
    input logic clock, reset,
    input logic zero_memory, count_done,
                bresenham_we,
    output logic write_enable, zero_cell,
                 reset_counter, enable_counter,
    output logic busy
);

    typedef enum {
        WAIT,
        ZERO_CELL
    } state_t;

    state_t current, next;

    always_ff @( posedge(clock), posedge(reset) ) begin : StateTransition
        if (reset) current = WAIT;
        else current = next;
    end

    always_comb begin : NextState
        case (current)
            WAIT:
                if (zero_memory) next = ZERO_CELL;
                else next = WAIT;
            ZERO_CELL:
                if (count_done) next = WAIT;
                else next = ZERO_CELL;
            default:
                next = WAIT;
        endcase
    end

    always_comb begin : OutputVariables
        write_enable = 0;
        zero_cell = 0;
        reset_counter = 1;
        enable_counter = 0;
        busy = 1;

        case (current)
            WAIT: begin
                write_enable = bresenham_we;
                zero_cell = 0;
                reset_counter = 1;
                enable_counter = 0;
                busy = 0;
            end
            ZERO_CELL: begin
                write_enable = 1;
                zero_cell = 1;
                reset_counter = 0;
                enable_counter = 1;
                busy = 1;
            end
            default: begin
                write_enable = 0;
                zero_cell = 0;
                reset_counter = 1;
                enable_counter = 0;
                busy = 1;
            end
        endcase
    end

endmodule: occupancy_cu
