module control_unit
(
    input logic clock, reset,
    input logic start,
    output logic use_bresenham_indices,
    input logic scan_done,
    // Bresenham
    output logic address_enable, address_reset,
                 position_enable,
                 bresenham_start,
    input logic bresenham_busy,
    // Occupancy grid
    output logic zero_occupancy_grid,
    input logic occupancy_busy
);

    typedef enum {
        RESET, WAIT, READ_POSITION, READ_SCAN, WAIT_ALGORITMH
    } state_t;

    state_t current, next;

    always_ff @( posedge(clock), posedge(reset) ) begin : StateTransition
        if (reset) current = RESET;
        else current = next;
    end

    always_comb begin : NextState
        case (current)
            RESET:
                next = WAIT;
            WAIT:
                if (start && !occupancy_busy) next = READ_POSITION;
                else next = WAIT;
            READ_POSITION:
                next = READ_SCAN;
            READ_SCAN:
                next = WAIT_ALGORITMH;
            WAIT_ALGORITMH: begin
                if (!bresenham_busy && !occupancy_busy)
                    if (scan_done) next = READ_POSITION;
                    else next = READ_SCAN;
                else next = WAIT_ALGORITMH;
            end
            default:
                next = RESET;
        endcase
    end

    always_comb begin : OutputVariables
        use_bresenham_indices = 0;
        address_enable = 0;
        address_reset = 0;
        position_enable = 0;
        bresenham_start = 0;
        zero_occupancy_grid = 0;

        case (current)
            RESET: begin
                address_reset = 1;
                zero_occupancy_grid = 1;
            end
            // WAIT
            READ_POSITION: begin
                address_enable = 1;
                position_enable = 1;
            end
            READ_SCAN: begin
                address_enable = 1;
                bresenham_start = 1;
            end
            WAIT_ALGORITMH:
                use_bresenham_indices = 1;
            default: begin
                address_enable = 0;
                address_reset = 0;
                position_enable = 0;
                bresenham_start = 0;
                zero_occupancy_grid = 0;
            end
        endcase
    end


endmodule: control_unit
