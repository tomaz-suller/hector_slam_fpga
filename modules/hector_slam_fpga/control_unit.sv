module control_unit
(
    input logic clock, reset,
    input logic start,
    output logic use_bresenham_indices,
    input logic scan_done,
                simulation_done,
    // Bresenham
    output logic address_enable, address_reset,
                 position_enable,
                 bresenham_start,
    input logic bresenham_busy,
    // Occupancy grid
    output logic zero_occupancy_grid,
    input logic occupancy_busy,
    // VGA
    input logic vga_busy
);

    typedef enum {
        RESET,
        DRAW,
        WAIT_MEMORY_1, READ_POSITION,
        GET_NEXT_SCAN, WAIT_MEMORY_2,
        START_ALGORITHM,
        WAIT_ALGORITMH
    } state_t;

    state_t current, next;

    always_ff @( posedge(clock), posedge(reset) ) begin : StateTransition
        if (reset) current = RESET;
        else current = next;
    end
    
    logic [1:0] start_history;
    always_ff @( posedge(clock)) begin : BordDetector
        start_history = {start_history[0], start};
    end
    logic start_edge = start_history == 2'b01;

    always_comb begin : NextState
        case (current)
            RESET:
                next = DRAW;
            DRAW:
                if (start_edge && !occupancy_busy)
                    next = WAIT_MEMORY_1;
                else next = DRAW;
            WAIT_MEMORY_1:
                next = READ_POSITION;
            READ_POSITION:
                next = GET_NEXT_SCAN;
            GET_NEXT_SCAN:
                next = WAIT_MEMORY_2;
            WAIT_MEMORY_2:
                if (scan_done || simulation_done) next = DRAW;
                else next = START_ALGORITHM;
            START_ALGORITHM:
                next = WAIT_ALGORITMH;
            WAIT_ALGORITMH: begin
                if (!bresenham_busy && !occupancy_busy)
                    next = GET_NEXT_SCAN;
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
            // DRAW
            // WAIT_MEMORY_1
            READ_POSITION:
                position_enable = 1;
            GET_NEXT_SCAN:
                address_enable = 1;
            // WAIT_MEMORY_2
            START_ALGORITHM:
                bresenham_start = 1;
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