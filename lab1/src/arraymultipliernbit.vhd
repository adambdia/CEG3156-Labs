----------------------------------------------------------------------
-- arraymultiplier.vhd
-- Generic NxN Array Multiplier
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity arraymultiplier is
    generic(
        bits : positive := 9
    );
    port(
        i_M       : in  std_logic_vector(bits-1 downto 0);
        i_Q       : in  std_logic_vector(bits-1 downto 0);
        o_product : out std_logic_vector(2*bits-1 downto 0)
    );
end arraymultiplier;

architecture rtl of arraymultiplier is

    -- Store intermediate partial sums
    type sum_array is array (0 to bits-1) of std_logic_vector(bits-1 downto 0);
    signal int_sum   : sum_array;

    -- Carry chain between lines
    signal int_carry : std_logic_vector(bits downto 0);

begin

    ------------------------------------------------------------------
    -- First line (special case)
    ------------------------------------------------------------------
    line0: entity work.arraymultiplierline8bit
        generic map(bits => bits)
        port map(
            i_M => i_M,
            i_Qi => i_Q(0),
            i_prevSum => (others => '0'),
            o_partialProduct => int_sum(0),
            o_carry => int_carry(1)
        );

    o_product(0) <= int_sum(0)(0);

    ------------------------------------------------------------------
    -- Middle lines
    ------------------------------------------------------------------
    gen_lines: for i in 1 to bits-1 generate

    signal shifted_prev : std_logic_vector(bits-1 downto 0);

    begin

        -- Build next line input safely
        shifted_prev(bits-2 downto 0) <= int_sum(i-1)(bits-1 downto 1);
        shifted_prev(bits-1)          <= int_carry(i);

        lineN: entity work.arraymultiplierline8bit
            generic map(bits => bits)
            port map(
                i_M       => i_M,
                i_Qi      => i_Q(i),
                i_prevSum => shifted_prev,
                o_partialProduct => int_sum(i),
                o_carry   => int_carry(i+1)
            );

    o_product(i) <= int_sum(i)(0);

end generate;


    ------------------------------------------------------------------
    -- Final product upper bits
    ------------------------------------------------------------------
    o_product(2*bits-1 downto bits) <= 
        int_carry(bits) & int_sum(bits-1)(bits-1 downto 1);

end rtl;
