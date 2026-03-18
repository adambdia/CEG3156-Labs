----------------------------------------------------------------------
-- Testbench: processor_tb
-- Target: GHDL / VHDL-93
-- Description: Simple execution test for the single-cycle processor.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor_tb IS
END processor_tb;

ARCHITECTURE behavior OF processor_tb IS

    -- Constants
    CONSTANT clk_period : TIME := 10 ns;

    -- Stimulus Signals
    signal s_clk      : std_logic := '0';
    signal s_rstBAR   : std_logic := '0';

    -- Monitor Signals
    signal s_instruction : std_logic_vector(31 downto 0);
    signal s_zero        : std_logic;
    signal s_branch      : std_logic;
    signal s_memwrite    : std_logic;
    signal s_regwrite    : std_logic;

BEGIN

    -- Direct Entity Instantiation of the Processor
    uut: entity work.processor(structural)
        PORT MAP (
            i_clk             => s_clk,
            i_rstBAR          => s_rstBAR,
            o_instruction_tap => s_instruction,
            o_zero_flag       => s_zero,
            o_branch_tap      => s_branch,
            o_memwrite_tap    => s_memwrite,
            o_regwrite_tap    => s_regwrite
        );

    -- Clock Generation Process
    -- Toggles every 5ns to create a 10ns (100MHz) clock
    clk_process : process
    begin
        s_clk <= '0';
        wait for clk_period/2;
        s_clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Initial Hardware Reset
        s_rstBAR <= '0';
        wait for 25 ns;
        
        -- Release Reset to start execution
        s_rstBAR <= '1';

        -- Run for approximately 50 clock cycles
        wait for 500 ns;

        -- End of simulation
        wait;
    end process;

END behavior;