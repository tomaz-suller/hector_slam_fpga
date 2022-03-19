library ieee;
use ieee.numeric_std.std_match;
use ieee.std_logic_1164.all;

package utils is
    function to_string(b : bit) return string;
    function to_string(bv : bit_vector) return string;
    function to_string(sl : std_logic) return string;
    function to_string(slv : std_logic_vector) return string;

    procedure assert_equals(expected: std_logic_vector; received: std_logic_vector);
    procedure assert_equals(expected: bit_vector; received: bit_vector);
    procedure assert_equals(expected: bit_vector; received: std_logic_vector);
    procedure assert_equals(expected: std_logic_vector; received: bit_vector);

    procedure assert_equals(expected: std_logic_vector; received: std_logic_vector; index: integer);
    procedure assert_equals(expected: bit_vector; received: bit_vector; index: integer);
    procedure assert_equals(expected: bit_vector; received: std_logic_vector; index: integer);
    procedure assert_equals(expected: std_logic_vector; received: bit_vector; index: integer);
end utils;

package body utils is

    function to_string(b : bit) return string is
        variable b_str_v : string(1 to 3);  -- bit image with quotes around
    begin
        b_str_v := bit'image(b);
        return "" & b_str_v(2);  -- "" & character to get string
    end function;

    function to_string(bv : bit_vector) return string is
        alias    bv_norm : bit_vector(1 to bv'length) is bv;
        variable b_str_v : string(1 to 1);  -- String of bit
        variable res_v   : string(1 to bv'length);
    begin
        for idx in bv_norm'range loop
            b_str_v := to_string(bv_norm(idx));
            res_v(idx) := b_str_v(1);
        end loop;
        return res_v;
    end function;

    function to_string(sl : std_logic) return string is
        variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
      begin
        sl_str_v := std_logic'image(sl);
        return "" & sl_str_v(2);  -- "" & character to get string
      end function;

    function to_string(slv : std_logic_vector) return string is
        alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
        variable sl_str_v : string(1 to 1);  -- String of std_logic
        variable res_v    : string(1 to slv'length);
    begin
        for idx in slv_norm'range loop
            sl_str_v := to_string(slv_norm(idx));
            res_v(idx) := sl_str_v(1);
        end loop;
        return res_v;
    end function;

    ---------------------------------------------------------------

    procedure assert_equals(expected: std_logic_vector; received: std_logic_vector) is
    begin
        assert std_match(expected, received)
            report "Assertion failed. "&
                "Expected "& to_string(expected) &" "&
                "but got "& to_string(received)
            severity warning;
    end procedure;

    procedure assert_equals(expected: bit_vector; received: bit_vector) is
    begin
        assert_equals(to_stdlogicvector(expected), to_stdlogicvector(received));
    end procedure;

    procedure assert_equals(expected: bit_vector; received: std_logic_vector) is
    begin
        assert_equals(to_stdlogicvector(expected), received);
    end procedure;

    procedure assert_equals(expected: std_logic_vector; received: bit_vector) is
    begin
        assert_equals(expected, to_stdlogicvector(received));
    end procedure;

    ---------------------------------------------------------------

    procedure assert_equals(
        expected: std_logic_vector;
        received: std_logic_vector;
        index: integer
    ) is
    begin
        assert std_match(expected, received)
            report "Assertion "& integer'image(index) &"failed. "&
                "Expected "& to_string(expected) &" "&
                "but got "& to_string(received)
            severity warning;
    end procedure;

    procedure assert_equals(
        expected: bit_vector;
        received: bit_vector;
        index: integer
    ) is
    begin
        assert_equals(
            to_stdlogicvector(expected),
            to_stdlogicvector(received),
            index
        );
    end procedure;

    procedure assert_equals(
        expected: bit_vector;
        received: std_logic_vector;
        index: integer
    ) is
    begin
        assert_equals(
            to_stdlogicvector(expected),
            received,
            index
        );
    end procedure;

    procedure assert_equals(
        expected: std_logic_vector;
        received: bit_vector;
        index: integer
    ) is
    begin
        assert_equals(
            expected,
            to_stdlogicvector(received),
            index
        );
    end procedure;

end utils;
