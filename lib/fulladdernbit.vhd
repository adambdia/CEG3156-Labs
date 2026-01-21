----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: fulladdernbit.vhd
-- Description: n bit ripple carry full adder that also supports subtraction, 
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity fulladdernbit is
    generic (bits: positive:= 8);
    port(
        i_a : in std_logic_vector(bits-1 downto 0);
        i_b : in std_logic_vector(bits-1 downto 0);
        i_subtract : in std_logic;
        o_sum : in std_logic_vector(bits-1 downto 0);
        o_carry : out std_logic);
end fulladdernbit;

architecture rtl of fulladdernbit is
-- Signals
    -- so we can propagate the carries
    signal int_carry : std_logic_vector(bits downto 0);    

    begin
    
    gen_adders: for i in 0 to bits-1 generate
        adder: entity work.fulladder1bit
                port map(
                    i_a => i_a(i),
                    i_b => i_b(i),
                    i_subtract => i_subtract,
                    i_carry => int_carry(i),
                    o_sum => o_sum(i),
                    o_carry => int_carry(i+1)
                );
        
        end generate;

    o_carry <= int_carry(bits);

end rtl;