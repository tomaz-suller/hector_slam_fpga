`include "../packages.sv"

module bresenham_cu
    import ram_pkg::index_t;
(
    input logic clock, reset,
    input logic start,
    output logic x_source, x_we,
                 cell_is_free, write_enable,
    input index_t current_x,
    output logic busy
);
    typedef enum {
        WAIT,
        SET_UP,
        UPDATE_OCCUPIED,
        UPDATE_FREE
     } state_t;

    state_t current, next;

    always_ff @( posedge(clock) ) begin : StateTransition
        if (reset) current = WAIT;
        else current = next;
    end

    always_comb begin : NextState
        case (current)
            WAIT:
                if (start) next = SET_UP;
                else next = SET_UP;
            SET_UP:
                next = UPDATE_OCCUPIED;
            UPDATE_OCCUPIED:
                next =  UPDATE_FREE;
            UPDATE_FREE:
                if (current_x == 0) next = WAIT;
                else next = UPDATE_FREE;
            default:
                next = WAIT;
        endcase
    end

    always_comb begin : OutputVariables
        cell_is_free = 0;
        x_source = 0;
        x_we = 0;
        write_enable = 0;
        busy = 1;

        case (current)
            WAIT: begin
                x_we = 0;
                write_enable = 0;
                busy = 0;
            end
            SET_UP: begin
                x_source = 0;
                x_we = 1;
                busy = 1;
            end
            UPDATE_OCCUPIED: begin
                cell_is_free = 0;
                x_source = 1;
                x_we = 1;
                write_enable = 1;
                busy = 1;
            end
            UPDATE_FREE: begin
                cell_is_free = 1;
                x_source = 1;
                x_we = 1;
                write_enable = 1;
                busy = 1;
            end
            default: begin
                cell_is_free = 0;
                x_source = 0;
                x_we = 0;
                write_enable = 0;
                busy = 1;
            end
        endcase
    end

endmodule: bresenham_cu
