----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: comparatornbit.vhd
-- Description: n bit comparator that also outputs an equal signal, p suffix denotes previous
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity comparatornbit is
    generic (bits : positive := 8);
    port(
        i_A : in std_logic_vector(bits-1 downto 0);
        i_B : in std_logic_vector(bits-1 downto 0);
        i_GTp : in std_logic;
        i_LTp : in std_logic;
        o_GT : out std_logic;
        o_LT : out std_logic;
        o_EQ : out std_logic);
end comparatornbit;

architecture rtl of comparatornbit is
-- Signals
    signal int_GT : std_logic_vector(bits downto 0);
    signal int_LT : std_logic_vector(bits downto 0);
    begin
    
    comparators: for i in bits-1 downto 0  generate -- we can daisy chain the 1 bit comparator provided by the prof
        comparator: entity work.comparator1bit
            port map(
                i_GTPrevious => int_GT(i+1),
                i_LTPrevious => int_LT(i+1),
                i_Ai => i_A(i),
                i_Bi => i_B(i),
                o_GT => int_GT(i),
                o_LT => int_LT(i) 
            );
        end generate;
    
    -- output driver
    o_GT <= int_GT(0);
    o_LT <= int_LT(0);
    o_EQ <= int_GT(0) NOR int_LT(0); -- as taught in digital systems ii

end rtl;