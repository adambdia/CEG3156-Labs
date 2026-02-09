----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: arraymultiplier8bit.vhd
-- Description: full 8bit array multiplier using the arraymultiplierline8bit
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity arraymultiplier8bit is
    port(
        i_M : in std_logic_vector(7 downto 0);
        i_Q : in std_logic_vector(7 downto 0);
        o_product : out std_logic_vector(15 downto 0));
end arraymultiplier8bit;

architecture rtl of arraymultiplier8bit is
-- Signals
    signal int_prevSum : std_logic_vector(55 downto 0); -- biggest number we'll need is 6+7*(6+1) = 55
    signal int_carry : std_logic_vector(8 downto 1); -- to propagate the carries down and diagonally
    begin
    
    -- first line is a special case

    line0: entity work.arraymultiplierline8bit
        port map(
            i_M => i_M,
            i_Qi => i_Q(0),
            i_prevSum => "00000000", -- no previous sum
            o_partialProduct(7 downto 1) => int_prevSum(6 downto 0), -- ignore lsb and shift to the right by one, the layer below doesnt need the msb
            o_partialProduct(0) => o_product(0),
            o_carry => int_carry(1)
        );

    multiplier: for i in 1 to 6 generate -- middle lines can be handled generally
        lineN: entity work.arraymultiplierline8bit
            port map(
                i_M => i_M,
                i_Qi => i_Q(i),
                i_prevSum(6 downto 0) => int_prevSum(6+7*(i-1) downto 7*(i-1)), -- msb in needs to be carry from partial product of the line above 
                i_prevSum(7) => int_carry(i),
                o_partialProduct(7 downto 1) => int_prevSum(6+7*(i) downto 7*(i)),
                o_partialProduct(0) => o_product(i), -- lsb is the ith bit of the product
                o_carry => int_carry(i+1)
            );
    end generate;

    -- last line is a special case
    line7: entity work.arraymultiplierline8bit
        port map(
            i_M => i_M,
            i_Qi => i_Q(7),
            i_prevSum(6 downto 0) => int_prevSum(48 downto 42),
            i_prevSum(7) => int_carry(7),
            o_partialProduct => o_product(14 downto 7),
            o_carry => o_product(15)
        );

end rtl;