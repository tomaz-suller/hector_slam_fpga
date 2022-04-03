module index_to_address
(
    input logic [4:0] x_index,
    input logic [3:0] y_index,
    output logic [8:0] address
);

    assign address = x_index + (y_index * 32);

endmodule: index_to_address
