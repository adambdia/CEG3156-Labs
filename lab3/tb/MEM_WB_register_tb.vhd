----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: MEM_WB_register_tb.vhd
-- Description: Testbench for MEM/WB pipeline register
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_register_tb is
end MEM_WB_register_tb;

architecture behavior of MEM_WB_register_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk       : std_logic := '0';
    signal rstBAR    : std_logic := '0';
    signal stall     : std_logic := '0';
    signal flush     : std_logic := '0';

    -- Control inputs
    signal RegWrite  : std_logic := '0';
    signal MemToReg  : std_logic := '0';

    -- Data inputs
    signal ReadData  : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUResult : std_logic_vector(31 downto 0) := (others => '0');
    signal WriteReg  : std_logic_vector(4 downto 0)  := (others => '0');

    -- Control outputs
    signal o_RegWrite : std_logic;
    signal o_MemToReg : std_logic;

    -- Data outputs
    signal o_ReadData  : std_logic_vector(31 downto 0);
    signal o_ALUResult : std_logic_vector(31 downto 0);
    signal o_WriteReg  : std_logic_vector(4 downto 0);

begin

    uut: entity work.MEM_WB_register
        port map(
            i_clk       => clk,
            i_rstBAR    => rstBAR,
            i_stall     => stall,
            i_flush     => flush,
            i_RegWrite  => RegWrite,
            i_MemToReg  => MemToReg,
            i_ReadData  => ReadData,
            i_ALUResult => ALUResult,
            i_WriteReg  => WriteReg,
            o_RegWrite  => o_RegWrite,
            o_MemToReg  => o_MemToReg,
            o_ReadData  => o_ReadData,
            o_ALUResult => o_ALUResult,
            o_WriteReg  => o_WriteReg
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    stim_process: process
    begin
        -------- RESET --------
        rstBAR <= '0';
        wait for CLK_PERIOD;
        assert o_RegWrite  = '0'         report "FAIL: RegWrite not zero after reset"  severity error;
        assert o_MemToReg  = '0'         report "FAIL: MemToReg not zero after reset"  severity error;
        assert o_ReadData  = x"00000000" report "FAIL: ReadData not zero after reset"   severity error;
        assert o_ALUResult = x"00000000" report "FAIL: ALUResult not zero after reset"  severity error;
        assert o_WriteReg  = "00000"     report "FAIL: WriteReg not zero after reset"   severity error;

        -------- NORMAL LOAD (lw writeback) --------
        rstBAR    <= '1';
        RegWrite  <= '1';
        MemToReg  <= '1';
        ReadData  <= x"AABBCCDD";
        ALUResult <= x"00000040";
        WriteReg  <= "00101";
        wait for CLK_PERIOD;

        assert o_RegWrite  = '1'         report "FAIL: RegWrite load 1"  severity error;
        assert o_MemToReg  = '1'         report "FAIL: MemToReg load 1"  severity error;
        assert o_ReadData  = x"AABBCCDD" report "FAIL: ReadData load 1"  severity error;
        assert o_ALUResult = x"00000040" report "FAIL: ALUResult load 1" severity error;
        assert o_WriteReg  = "00101"     report "FAIL: WriteReg load 1"  severity error;

        -------- SECOND LOAD (R-type writeback) --------
        RegWrite  <= '1';
        MemToReg  <= '0';
        ReadData  <= x"00000000";
        ALUResult <= x"00000008";
        WriteReg  <= "01001";
        wait for CLK_PERIOD;

        assert o_RegWrite  = '1'         report "FAIL: RegWrite load 2"  severity error;
        assert o_MemToReg  = '0'         report "FAIL: MemToReg load 2"  severity error;
        assert o_ReadData  = x"00000000" report "FAIL: ReadData load 2"  severity error;
        assert o_ALUResult = x"00000008" report "FAIL: ALUResult load 2" severity error;
        assert o_WriteReg  = "01001"     report "FAIL: WriteReg load 2"  severity error;

        -------- STALL: outputs must hold --------
        stall     <= '1';
        RegWrite  <= '0';
        MemToReg  <= '1';
        ReadData  <= x"FFFFFFFF";
        ALUResult <= x"FFFFFFFF";
        WriteReg  <= "11111";
        wait for CLK_PERIOD;

        assert o_RegWrite  = '1'         report "FAIL: RegWrite not held during stall"  severity error;
        assert o_MemToReg  = '0'         report "FAIL: MemToReg not held during stall"  severity error;
        assert o_ReadData  = x"00000000" report "FAIL: ReadData not held during stall"   severity error;
        assert o_ALUResult = x"00000008" report "FAIL: ALUResult not held during stall"  severity error;
        assert o_WriteReg  = "01001"     report "FAIL: WriteReg not held during stall"   severity error;

        -------- RELEASE STALL --------
        stall <= '0';
        wait for CLK_PERIOD;

        assert o_RegWrite  = '0'         report "FAIL: RegWrite after stall release"  severity error;
        assert o_MemToReg  = '1'         report "FAIL: MemToReg after stall release"  severity error;
        assert o_ReadData  = x"FFFFFFFF" report "FAIL: ReadData after stall release"   severity error;
        assert o_ALUResult = x"FFFFFFFF" report "FAIL: ALUResult after stall release"  severity error;
        assert o_WriteReg  = "11111"     report "FAIL: WriteReg after stall release"   severity error;

        -------- FLUSH --------
        flush <= '1';
        wait for CLK_PERIOD;

        assert o_RegWrite  = '0'         report "FAIL: RegWrite not zero after flush"  severity error;
        assert o_MemToReg  = '0'         report "FAIL: MemToReg not zero after flush"  severity error;
        assert o_ReadData  = x"00000000" report "FAIL: ReadData not zero after flush"   severity error;
        assert o_ALUResult = x"00000000" report "FAIL: ALUResult not zero after flush"  severity error;
        assert o_WriteReg  = "00000"     report "FAIL: WriteReg not zero after flush"   severity error;

        -------- RELEASE FLUSH --------
        flush     <= '0';
        RegWrite  <= '1';
        MemToReg  <= '0';
        ReadData  <= x"12345678";
        ALUResult <= x"DEADBEEF";
        WriteReg  <= "10110";
        wait for CLK_PERIOD;

        assert o_RegWrite  = '1'         report "FAIL: RegWrite after flush release"  severity error;
        assert o_MemToReg  = '0'         report "FAIL: MemToReg after flush release"  severity error;
        assert o_ReadData  = x"12345678" report "FAIL: ReadData after flush release"   severity error;
        assert o_ALUResult = x"DEADBEEF" report "FAIL: ALUResult after flush release"  severity error;
        assert o_WriteReg  = "10110"     report "FAIL: WriteReg after flush release"   severity error;

        report "MEM_WB_register_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
