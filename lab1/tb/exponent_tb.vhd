LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;

entity exponent_tb is
end exponent_tb;

architecture sim of exponent_tb is

    constant bits : positive := 8;
    constant clk_period : time := 10 ns;

    signal i_rstBAR     : STD_LOGIC := '0';
    signal i_clk        : STD_LOGIC := '0';
    signal i_exponent  : STD_LOGIC_VECTOR(bits-1 downto 0) := (others => '0');
    signal i_exponentSwap  : STD_LOGIC_VECTOR(bits-1 downto 0) := (others => '0');
    signal i_swap       : STD_LOGIC := '0';
    signal i_ld         : STD_LOGIC := '0';
    signal o_exponent  : STD_LOGIC_VECTOR(bits-1 downto 0);

begin

    ------------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------------
    DUT : entity work.exponent
        generic map (
            bits => bits
        )
        port map (
            i_rstBAR     => i_rstBAR,
            i_clk        => i_clk,
            i_exponent  => i_exponent,
            i_exponentSwap  => i_exponentSwap,
            i_mux_select       => i_swap,
            i_ld         => i_ld,
            o_exponent  => o_exponent
        );

    ------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period / 2;
            i_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Stimulus
    ------------------------------------------------------------------
    stim_proc : process
    begin
        ------------------------------------------------------------------
        -- Reset
        ------------------------------------------------------------------
        i_rstBAR <= '0';
        wait for 2 * clk_period;
        i_rstBAR <= '1';
        wait for clk_period;

        ------------------------------------------------------------------
        -- Test 1: Load exponentB (i_swap = 0, i_ld = 1)
        ------------------------------------------------------------------
        i_exponent <= "00101010"; -- 7 bits
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- Expected:
        -- o_exponentB = 0 & "0101010" = "00101010"
        wait for clk_period;

        i_rstBAR <= '0';
        wait for clk_period;
        i_rstBAR <= '1';
        ------------------------------------------------------------------
        -- Test 2: Swap = 1 -> load '1' & exponentA
        ------------------------------------------------------------------
        i_exponentSwap <= "00110011";
        i_swap <= '1';
        wait for clk_period;
        i_swap <= '0';

        -- Expected:
        -- o_exponentB = "1" & "00110011" = "100110011" (9 bits if unchecked)
        --  Only valid if mux2x1 truncates or exponentA is bits-1 wide intentionally
        wait for 2 * clk_period;

        ------------------------------------------------------------------
        -- Test 3: Hold value (no load)
        ------------------------------------------------------------------
        i_exponentSwap <= "11111111";
        i_exponent <= "11111110";
        i_ld <= '0';
        i_swap <= '0';
        wait for 2 * clk_period;

        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        wait for 2 * clk_period;
        i_swap <= '1';
        wait for clk_period;
        i_swap <= '0';

        -- Expected:
        -- o_exponentB remains unchanged

        ------------------------------------------------------------------
        -- End simulation
        ------------------------------------------------------------------
        wait;
    end process;

end sim;
