----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: pipelined_processor_tb.vhd
-- Description: Testbench for top-level pipelined MIPS processor.
--              Uses behavioral instruction_memory and data_memory stubs.
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pipelined_processor_tb is
end pipelined_processor_tb;

architecture behavior of pipelined_processor_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal GClock         : std_logic := '0';
    signal GReset         : std_logic := '0';
    signal ValueSelect    : std_logic_vector(2 downto 0) := "000";
    signal InstrSelect    : std_logic_vector(2 downto 0) := "000";
    signal MuxOut         : std_logic_vector(7 downto 0);
    signal InstructionOut : std_logic_vector(31 downto 0);
    signal BranchOut      : std_logic;
    signal ZeroOut        : std_logic;
    signal MemWriteOut    : std_logic;
    signal RegWriteOut    : std_logic;

begin

    uut: entity work.pipelinedProc
        port map(
            GClock         => GClock,
            GReset         => GReset,
            ValueSelect    => ValueSelect,
            InstrSelect    => InstrSelect,
            MuxOut         => MuxOut,
            InstructionOut => InstructionOut,
            BranchOut      => BranchOut,
            ZeroOut        => ZeroOut,
            MemWriteOut    => MemWriteOut,
            RegWriteOut    => RegWriteOut
        );

    clk_process: process
    begin
        GClock <= '0'; wait for CLK_PERIOD / 2;
        GClock <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_process: process
    begin
        -- Hold reset for 2 cycles
        GReset <= '0';
        wait for CLK_PERIOD * 2;
        GReset <= '1';

        -- Let the pipeline execute the test program
        -- Bootstrap (2x lw + 2x nop) + test (add, sub, lw, add, sw) + drain
        wait for CLK_PERIOD * 25;

        -- Probe PC via ValueSelect="000"
        ValueSelect <= "000";
        wait for CLK_PERIOD;

        -- Probe ALU result via ValueSelect="001"
        ValueSelect <= "001";
        wait for CLK_PERIOD;

        -- Probe ReadData1 via ValueSelect="010"
        ValueSelect <= "010";
        wait for CLK_PERIOD;

        -- Probe ReadData2 via ValueSelect="011"
        ValueSelect <= "011";
        wait for CLK_PERIOD;

        -- Probe WB data via ValueSelect="100"
        ValueSelect <= "100";
        wait for CLK_PERIOD;

        -- Probe control signals via ValueSelect="101"
        ValueSelect <= "101";
        wait for CLK_PERIOD;

        -- Probe IF instruction via InstrSelect="000"
        InstrSelect <= "000";
        wait for CLK_PERIOD;

        -- Probe ID instruction via InstrSelect="001"
        InstrSelect <= "001";
        wait for CLK_PERIOD;

        report "pipelined_processor_tb: SIMULATION COMPLETE - check waveform for detailed verification" severity note;
        wait;
    end process;

end behavior;
