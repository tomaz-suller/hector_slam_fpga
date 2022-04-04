module ram
(
    input logic clock,
    input logic write_enable,
    input logic [8:0] address,
    input logic [7:0] input_data,
    output logic [7:0] output_data
);

    logic [7:0] memory [0:(16*32)-1];

    always_ff @( posedge(clock) ) begin : Ram
        output_data = memory[address];
        if (write_enable)
            memory[address] = input_data;
    end

endmodule: ram
