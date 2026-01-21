----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: fulladder1bit.vhd
-- Description: fulladder1bit, supports 2s complement subtraction
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity fulladder1bit is
    port(
        i_a : in std_logic;
        i_b : in std_logic;
        i_subtract : in std_logic;
        i_carry : in std_logic;
        o_sum : out std_logic;
        o_carry : out std_logic);
end fulladder1bit;

architecture rtl of fulladder1bit is
-- Signals
    signal int_b : std_logic;
    signal int_sum : std_logic;
    signal int_carry : std_logic;
    signal int_carry2 : std_logic;

    begin
    
    int_b <= i_b xor i_subtract;

    ha1: entity work.halfadder
            port map(
                i_a => i_a,
                i_b => i_b,
                o_sum => int_sum,
                o_carry => int_carry
            );
        
    ha2: entity work.halfadder
            port map(
                i_a => int_sum,
                i_b => i_carry,
                o_sum => o_sum,
                o_carry => int_carry2
            );
    
    o_carry <= int_carry or int_carry2;

end rtl;