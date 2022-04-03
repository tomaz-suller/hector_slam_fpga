`ifndef FIXED_PKG_COMPILED
`define FIXED_PKG_COMPILED
package fixed_pkg;
    localparam WIDTH = 32;
    localparam INTEGER_WIDTH = 14;
    localparam FRACTION_WIDTH = 18;

    typedef struct packed {
        logic [INTEGER_WIDTH-1:0]  integer_;
        logic [FRACTION_WIDTH-1:0] fraction;
    } fixed_t;
endpackage: fixed_pkg
`endif

`ifndef RAM_PKG_COMPILED
`define RAM_PKG_COMPILED
package ram_pkg;
    localparam WORD_SIZE = 8;
    localparam WIDTH = 128;
    localparam HEIGHT = 32;
    localparam WIDTH_INDEX_WIDTH = $clog2(WIDTH);
    localparam HEIGHT_INDEX_WIDTH = $clog2(HEIGHT);
    localparam NUMBER_CELLS = WIDTH*HEIGHT;
    localparam ADDRESS_WIDTH = $clog2(NUMBER_CELLS);

    typedef logic [WORD_SIZE-1:0] word_t;
    typedef word_t memory_t [0:NUMBER_CELLS-1];
    typedef logic [WIDTH_INDEX_WIDTH-1:0] width_index_t;
    typedef logic [HEIGHT_INDEX_WIDTH-1:0] height_index_t;
    typedef logic [ADDRESS_WIDTH-1:0] address_t;
endpackage: ram_pkg
`endif
