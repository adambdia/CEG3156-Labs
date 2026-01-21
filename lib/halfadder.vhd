----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: halfadder.vhd
-- Description: 1bit halfadder 
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity halfadder is
    port(
        i_a : in std_logic;
        i_b : in std_logic;
        o_sum : out std_logic;
        o_carry : out std_logic);
end halfadder;

architecture rtl of halfadder is
-- Signals
    begin
    
    o_sum <= i_a xor i_b;
    o_carry <= i_a and i_b;

end rtl;