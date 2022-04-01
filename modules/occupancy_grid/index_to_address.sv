`include "../packages.sv"

module index_to_address
    import ram_pkg::index_t,
           ram_pkg::address_t;
(
    input index_t x_index, y_index,
    output address_t address
);

    assign address = x_index + (y_index * ram_pkg::WIDTH);

endmodule: index_to_address
