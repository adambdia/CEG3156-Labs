library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentMultiplier_tb is
end exponentMultiplier_tb;

architecture tb of exponentMultiplier_tb is


-- Constants
constant exponent_bits : positive := 7;
constant clk_period    : time := 10 ns;

-- DUT Signals
signal i_rstBAR           : std_logic := '0';
signal i_clk              : std_logic := '0';
signal i_sum              : std_logic_vector(exponent_bits-1 downto 0) := (others => '0');
signal i_ld               : std_logic := '0';
signal i_clr              : std_logic := '0';
signal o_exponentOutput   : std_logic_vector(exponent_bits-1 downto 0);


begin


--------------------------------------------------------------------
-- DUT Instantiation
--------------------------------------------------------------------
DUT: entity work.exponentMultiplier
    generic map (
        exponent_bits => exponent_bits
    )
    port map (
        i_rstBAR         => i_rstBAR,
        i_clk            => i_clk,
        i_sum            => i_sum,
        i_ld             => i_ld,
        i_clr            => i_clr,
        o_exponentOutput => o_exponentOutput
    );

--------------------------------------------------------------------
-- Clock Generation
--------------------------------------------------------------------
clk_process : process
begin
    while true loop
        i_clk <= '0';
        wait for clk_period/2;
        i_clk <= '1';
        wait for clk_period/2;
    end loop;
end process;

--------------------------------------------------------------------
-- Stimulus Process
--------------------------------------------------------------------
stim_proc: process
begin

    ----------------------------------------------------------------
    -- Reset
    ----------------------------------------------------------------
    i_rstBAR <= '0';
    wait for 20 ns;
    i_rstBAR <= '1';
    wait for clk_period;

    ----------------------------------------------------------------
    -- 1) Load value (ld = 1)
    ----------------------------------------------------------------
    i_sum <= "0001010";  -- Example value = 10
    i_ld  <= '1';
    i_clr <= '0';
    wait for clk_period;

    i_ld <= '0';
    wait for clk_period;

    ----------------------------------------------------------------
    -- 2) Clear (ld = 1 and clr = 1 simultaneously)
    ----------------------------------------------------------------
    i_sum <= "1111111";  -- Should be ignored due to clr
    i_ld  <= '1';
    i_clr <= '1';
    wait for clk_period;

    i_ld  <= '0';
    i_clr <= '0';
    wait for clk_period;

    ----------------------------------------------------------------
    -- 3) Load different value
    ----------------------------------------------------------------
    i_sum <= "0010101";  -- Example value = 21
    i_ld  <= '1';
    wait for clk_period;

    i_ld <= '0';
    wait for clk_period;

    ----------------------------------------------------------------
    -- Finish Simulation
    ----------------------------------------------------------------
    wait for 50 ns;

end process;

end tb;
