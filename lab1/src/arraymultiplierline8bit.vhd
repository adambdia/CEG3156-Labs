----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: arraymultiplierline8bit.vhd
-- Description: template file
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity arraymultiplierline8bit is
    generic(bits : positive := 9);
    port(
        i_M : in std_logic_vector(bits-1 downto 0);
        i_Qi: in std_logic;
        i_prevSum : std_logic_vector(bits-1 downto 0);
        o_partialProduct : out std_logic_vector(bits-1 downto 0);
        o_carry : out std_logic);
end arraymultiplierline8bit;

architecture rtl of arraymultiplierline8bit is
-- Signals
    signal int_carry : std_logic_vector(bits downto 0);
    begin

        line: for i in 0 to bits-1 generate
            unit: entity work.arraymultiplierunit
                port map(
                    i_Mi => i_M(i),
                    i_Qi => i_Qi,
                    i_prevSum => i_prevSum(i),
                    i_carry => int_carry(i),
                    o_sum => o_partialProduct(i),
                    o_carry => int_carry(i+1)
                );
        end generate;
    
    int_carry(0) <= '0';
    o_carry <= int_carry(bits);
end rtl;