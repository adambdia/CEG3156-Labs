library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topLevelMultiplier_tb is
end topLevelMultiplier_tb;

architecture tb of topLevelMultiplier_tb is

    -- Constants
    constant exponent_bits : positive := 7;
    constant mantissa_bits : positive := 8;

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Signals
    signal i_rstBAR              : std_logic := '0';
    signal i_clk                 : std_logic := '0';

    signal i_signA, i_signB      : std_logic := '0';
    signal i_exponentA           : std_logic_vector(exponent_bits-1 downto 0) := std_logic_vector(to_unsigned(92, exponent_bits));
    signal i_exponentB           : std_logic_vector(exponent_bits-1 downto 0) := std_logic_vector(to_unsigned(12, exponent_bits));
    signal i_mantissaA           : std_logic_vector(mantissa_bits-1 downto 0) := "00000000";
    signal i_mantissaB           : std_logic_vector(mantissa_bits-1 downto 0) := "10000000";

    signal o_signOutput          : std_logic;
    signal o_exponentOutput      : std_logic_vector(exponent_bits-1 downto 0);
    signal o_mantissaOutput      : std_logic_vector(mantissa_bits-1 downto 0);

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period/2;
            i_clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Instantiate DUT
    uut: entity work.topLevelMultiplier
        generic map (
            exponent_bits => exponent_bits,
            mantissa_bits => mantissa_bits
        )
        port map (
            i_rstBAR           => i_rstBAR,
            i_clk              => i_clk,
            i_signA            => i_signA,
            i_signB            => i_signB,
            i_exponentA        => i_exponentA,
            i_exponentB        => i_exponentB,
            i_mantissaA        => i_mantissaA,
            i_mantissaB        => i_mantissaB,
            o_signOutput       => o_signOutput,
            o_exponentOutput   => o_exponentOutput,
            o_mantissaOutput   => o_mantissaOutput
        );

    -- Stimulus process
    stim_proc: process
    begin
        ------------------------------------------------------------------
        -- TEST CASE 3: A * B = 3.125
        -- A   =  +1.25  = 0 0111111 01000000
        -- B   =  +2.5   = 0 1000000 01000000
        -- Out =  +3.125 = 0 1000000 10010000
        ------------------------------------------------------------------
        i_signA <= '0';
        i_exponentA <= "0111111";
        i_mantissaA <= "01000000";  -- 1.00000000

        i_signB <= '0';
        i_exponentB <= "1000000";
        i_mantissaB <= "01000000";  -- 1.10000000

        -- Apply reset
        i_rstBAR <= '0';
        wait for 20 ns;
        i_rstBAR <= '1';
        wait for 20 ns;




        

        -- Wait for operation to complete
        wait for 500 ns;

        -- Stop simulation
        wait;

    end process;

end tb;
