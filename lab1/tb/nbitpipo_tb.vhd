----------------------------------------------------------------------
-- Name: nbitpipo_tb.vhd
-- Description: VHDL-93 testbench for n-bit parallel-in parallel-out register
--              Fixed: Direct entity instantiation for GHDL -fexplicit binding
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nbitpipo_tb IS
END nbitpipo_tb;

ARCHITECTURE behavior OF nbitpipo_tb IS

    -- Testbench signals
    CONSTANT bits       : positive := 8;
    CONSTANT clk_period : time     := 10 ns;

    SIGNAL i_in_tb     : std_logic_vector(bits-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_rstBAR_tb : std_logic                        := '0';
    SIGNAL i_clk_tb    : std_logic                        := '0';
    SIGNAL i_ld_tb     : std_logic                        := '0';
    SIGNAL o_out_tb    : std_logic_vector(bits-1 DOWNTO 0);

BEGIN

    -- Direct entity instantiation (fixes -fexplicit binding warning)
    uut: ENTITY work.piponbit(rtl)
        GENERIC MAP (bits => bits)
        PORT MAP (
            i_in     => i_in_tb,
            i_rstBAR => i_rstBAR_tb,
            i_clk    => i_clk_tb,
            i_ld     => i_ld_tb,
            o_out    => o_out_tb
        );

    -- Clock process definition
    clk_process: PROCESS
    BEGIN
        i_clk_tb <= '0';
        WAIT FOR clk_period/2;
        i_clk_tb <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Initialize inputs
        i_rstBAR_tb <= '0';  -- Active low reset
        i_ld_tb     <= '0';
        i_in_tb     <= (OTHERS => '0');
        WAIT FOR 2*clk_period;

        -- Release reset
        i_rstBAR_tb <= '1';
        WAIT FOR clk_period;

        -- Test case 1: Load all zeros
        i_ld_tb  <= '1';
        i_in_tb  <= (OTHERS => '0');
        WAIT FOR clk_period;
        i_ld_tb  <= '0';
        WAIT FOR clk_period;

        -- Test case 2: Load all ones
        i_ld_tb  <= '1';
        i_in_tb  <= (OTHERS => '1');
        WAIT FOR clk_period;
        i_ld_tb  <= '0';
        WAIT FOR 2*clk_period;

        -- Test case 3: Load alternating pattern 10101010
        i_ld_tb  <= '1';
        i_in_tb  <= "10101010";
        WAIT FOR clk_period;
        i_ld_tb  <= '0';
        WAIT FOR 2*clk_period;

        -- Test case 4: Load hex pattern AA (10101010)
        i_ld_tb  <= '1';
        i_in_tb  <= x"AA";
        WAIT FOR clk_period;
        i_ld_tb  <= '0';
        WAIT FOR 3*clk_period;

        -- Test reset while loaded
        i_rstBAR_tb <= '0';
        WAIT FOR clk_period;
        i_rstBAR_tb <= '1';
        WAIT FOR clk_period;

        -- End simulation
        WAIT;
    END PROCESS;

END behavior;
