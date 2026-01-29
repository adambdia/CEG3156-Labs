library ieee;
use ieee.std_logic_1164.all;

entity significandA_tb is
end significandA_tb;

architecture tb of significandA_tb is

    constant bits : positive := 9;
    constant clk_period : time := 10 ns;

    -- DUT signals
    signal i_rstBAR        : std_logic := '1';
    signal i_clk           : std_logic := '0';
    signal i_mantissaA     : std_logic_vector(bits-2 downto 0);
    signal i_significandB  : std_logic_vector(bits-1 downto 0);
    signal i_ld            : std_logic;
    signal i_mux_select    : std_logic;
    signal o_significandA  : std_logic_vector(bits-1 downto 0);

begin

    -- DUT instantiation
    dut: entity work.significandA
        generic map (
            bits => bits
        )
        port map (
            i_rstBAR        => i_rstBAR,
            i_clk           => i_clk,
            i_mantissaA     => i_mantissaA,
            i_significandB  => i_significandB,
            i_ld            => i_ld,
            i_mux_select    => i_mux_select,
            o_significandA  => o_significandA
        );

    -- Clock generator
    clk_proc : process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period / 2;
            i_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initial values
        i_ld <= '0';
        i_mux_select <= '0';
        i_mantissaA <= (others => '0');
        i_significandB <= (others => '0');

        -- Apply reset
        i_rstBAR <= '0';
        wait for 20 ns;
        i_rstBAR <= '1';

        -- ==============================
        -- Test 1: Load Mantissa Path
        -- ==============================
        wait for 10 ns;
        i_mux_select <= '0'; -- select mantissa path
        i_mantissaA <= "10101010";  -- 8-bit mantissa
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==============================
        -- Test 2: Load SignificandB Path
        -- ==============================
        wait for 20 ns;
        i_mux_select <= '1';
        i_significandB <= "110011001"; -- full 9-bit value
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==============================
        -- Test 3: Change Mantissa Again
        -- ==============================
        wait for 20 ns;
        i_mux_select <= '0';
        i_mantissaA <= "01010101";
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==============================
        -- End Simulation
        -- ==============================
        wait for 50 ns;
        report "Simulation finished successfully";
        wait;

    end process;

end tb;
