----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: arraymultiplierunit.vhd
-- Description: multiplier unit that will be tiled to create the needed 8bit array multiplier
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity arraymultiplierunit is
    port(
        i_Mi : in std_logic;
        i_Qi : in std_logic;
        i_prevSum : in std_logic;
        i_carry : in std_logic;
        o_sum : out std_logic;
        o_carry : out std_logic);
end arraymultiplierunit;

architecture rtl of arraymultiplierunit is
-- Signals
    signal int_product : std_logic;
    begin

    int_product <= i_Mi and i_Qi;

    adder: entity work.fulladder1bit
            port map(
                i_a => i_prevSum,
                i_b => int_product,
                i_subtract => '0',
                i_carry => i_carry,
                o_sum => o_sum,
                o_carry => o_carry
            );


end rtl;