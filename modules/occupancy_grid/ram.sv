`include "../packages.sv"

module ram
    import fixed_pkg::fixed_t,
           ram_pkg::*;
(
    input logic clock,
    input logic write_enable,
    input address_t address,
    input word_t input_data,
    output word_t output_data
);

    memory_t memory;

    always_ff @( posedge(clock) ) begin : Ram
        if (write_enable)
            memory[address] = input_data;
    end
    assign output_data = memory[address];

endmodule: ram
