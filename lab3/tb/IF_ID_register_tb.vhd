----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: IF_ID_register_tb.vhd
-- Description: Testbench for IF/ID pipeline register
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_register_tb is
end IF_ID_register_tb;

architecture behavior of IF_ID_register_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk         : std_logic := '0';
    signal rstBAR      : std_logic := '0';
    signal stall       : std_logic := '0';
    signal flush       : std_logic := '0';
    signal PC_plus4    : std_logic_vector(7 downto 0)  := (others => '0');
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal o_PC_plus4    : std_logic_vector(7 downto 0);
    signal o_instruction : std_logic_vector(31 downto 0);

begin

    uut: entity work.IF_ID_register
        port map(
            i_clk         => clk,
            i_rstBAR      => rstBAR,
            i_stall       => stall,
            i_flush       => flush,
            i_PC_plus4    => PC_plus4,
            i_instruction => instruction,
            o_PC_plus4    => o_PC_plus4,
            o_instruction => o_instruction
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_process: process
    begin
        -- Reset
        rstBAR <= '0';
        wait for CLK_PERIOD;
        -- Outputs should be all zeros after reset
        assert o_PC_plus4 = x"00" report "FAIL: PC+4 not zero after reset" severity error;
        assert o_instruction = x"00000000" report "FAIL: instruction not zero after reset" severity error;

        -- Release reset, load first values
        rstBAR <= '1';
        PC_plus4    <= x"04";
        instruction <= x"8C220000";
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"04" report "FAIL: PC+4 load 1" severity error;
        assert o_instruction = x"8C220000" report "FAIL: instruction load 1" severity error;

        -- Load second values
        PC_plus4    <= x"08";
        instruction <= x"01284820";
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"08" report "FAIL: PC+4 load 2" severity error;
        assert o_instruction = x"01284820" report "FAIL: instruction load 2" severity error;

        -- Stall: inputs change but outputs should hold
        stall       <= '1';
        PC_plus4    <= x"0C";
        instruction <= x"DEADBEEF";
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"08" report "FAIL: PC+4 not held during stall" severity error;
        assert o_instruction = x"01284820" report "FAIL: instruction not held during stall" severity error;

        -- Release stall: new values should load
        stall <= '0';
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"0C" report "FAIL: PC+4 after stall release" severity error;
        assert o_instruction = x"DEADBEEF" report "FAIL: instruction after stall release" severity error;

        -- Flush: outputs should go to zero
        flush       <= '1';
        PC_plus4    <= x"10";
        instruction <= x"FFFFFFFF";
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"00" report "FAIL: PC+4 not zero after flush" severity error;
        assert o_instruction = x"00000000" report "FAIL: instruction not zero after flush" severity error;

        -- Release flush, load again
        flush    <= '0';
        PC_plus4    <= x"14";
        instruction <= x"AC430000";
        wait for CLK_PERIOD;
        assert o_PC_plus4 = x"14" report "FAIL: PC+4 after flush release" severity error;
        assert o_instruction = x"AC430000" report "FAIL: instruction after flush release" severity error;

        report "IF_ID_register_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
