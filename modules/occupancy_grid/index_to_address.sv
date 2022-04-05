module index_to_address
(
    input logic [7:0] x_index,
    input logic [6:0] y_index,
    output logic [14:0] address
);

    assign address = x_index + (y_index * 256);

endmodule: index_to_address
