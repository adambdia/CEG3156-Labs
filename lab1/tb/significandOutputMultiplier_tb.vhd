library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity significandOutputMultiplier_tb is
end significandOutputMultiplier_tb;

architecture behavior of significandOutputMultiplier_tb is

    -- Constants
    constant exponent_bits : positive := 7;
    constant product_bits  : positive := 18;

    -- DUT Signals
    signal i_rstBAR  : std_logic := '0';
    signal i_clk     : std_logic := '0';
    signal i_product : std_logic_vector(product_bits-1 downto 0) := (others => '0');
    signal i_ld      : std_logic := '0';
    signal i_clr     : std_logic := '0';
    signal i_shift   : std_logic := '0';
    signal o_significandOutput : std_logic_vector(product_bits-1 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------------------
    uut: entity work.significandOutputMultiplier
        generic map (
            product_bits  => product_bits
        )
        port map (
            i_rstBAR  => i_rstBAR,
            i_clk     => i_clk,
            i_product => i_product,
            i_ld      => i_ld,
            i_clr     => i_clr,
            i_shift   => i_shift,
            o_significandOutput => o_significandOutput
        );

    --------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------
    clk_process : process
    begin
        while now < 300 ns loop
            i_clk <= '0';
            wait for clk_period/2;
            i_clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    --------------------------------------------------------------------
    -- Stimulus process
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
        -- Test 1: ld only (no shift, no clr)
        ----------------------------------------------------------------
        i_product <= "101010101010101010";
        i_ld      <= '1';
        i_clr     <= '0';
        i_shift   <= '0';
        wait for clk_period;

        i_ld  <= '0';
        i_clr <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Test 2: shift = 1 and ld = 1 (clr = 0)
        ----------------------------------------------------------------
        i_product <= "111100001111000011";
        i_ld      <= '1';
        i_shift   <= '1';
        i_clr     <= '0';
        wait for 3 * clk_period;

        i_ld    <= '0';
        i_shift <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Test 3: ld only (no shift, no clr)
        ----------------------------------------------------------------
        i_product <= "000011110000111100";
        i_ld      <= '1';
        i_shift   <= '0';
        i_clr     <= '0';
        wait for clk_period;

        i_ld <= '0';
        wait for 40 ns;

        ----------------------------------------------------------------
        -- Test 4: clr = 1 and ld = 1 (shift = 0)
        ----------------------------------------------------------------
        i_ld      <= '1';
        i_clr     <= '1';
        i_shift   <= '0';
        wait for clk_period;
        
        i_ld <= '0';
        i_clr <= '0';

        ----------------------------------------------------------------
        -- End simulation
        ----------------------------------------------------------------
        wait;
    end process;

end behavior;
