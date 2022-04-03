`include "../packages.sv"

module flip_indices
    import ram_pkg::index_t;
(
    input logic flip_x, flip_y, flip_identity,
    input index_t x_in, y_in,
    output index_t x, y
);

    index_t flipped_x, flipped_y;

    assign flipped_x = -x_in;
    assign flipped_y = -y_in;

    always_comb begin : ChooseIndices
        if (flip_identity) begin
            if (flip_x) y = flipped_x;
            else        y = x_in;
            if (flip_y) x = flipped_y;
            else        x = y_in;
        end
        else begin
            if (flip_x) x = flipped_x;
            else        x = x_in;
            if (flip_y) y = flipped_y;
            else        y = y_in;
        end
    end

endmodule: flip_indices
