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