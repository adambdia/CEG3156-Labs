----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: mux2x1.vhd
-- Description: 1 bit 2x1 mux
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux2x1 is
    port(
        i_a : in std_logic;
        i_b : in std_logic;
        i_sel : in std_logic;
        o_out : out std_logic);
end mux2x1;

architecture rtl of mux2x1 is
-- Signals
    signal int_a : std_logic;
    signal int_b : std_logic;
    begin
    
    int_a <= i_a and ( not(i_sel));
    int_b <= i_b and i_sel;

    o_out <= int_a or int_b;

end rtl;