----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: ID_EX_register_tb.vhd
-- Description: Testbench for ID/EX pipeline register
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_register_tb is
end ID_EX_register_tb;

architecture behavior of ID_EX_register_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk        : std_logic := '0';
    signal rstBAR     : std_logic := '0';
    signal stall      : std_logic := '0';
    signal flush      : std_logic := '0';

    -- Control inputs
    signal RegWrite   : std_logic := '0';
    signal MemToReg   : std_logic := '0';
    signal Branch     : std_logic := '0';
    signal MemRead    : std_logic := '0';
    signal MemWrite   : std_logic := '0';
    signal RegDst     : std_logic := '0';
    signal ALUOp      : std_logic_vector(1 downto 0)  := "00";
    signal ALUSrc     : std_logic := '0';

    -- Data inputs
    signal PC_plus4   : std_logic_vector(7 downto 0)  := (others => '0');
    signal ReadData1  : std_logic_vector(31 downto 0) := (others => '0');
    signal ReadData2  : std_logic_vector(31 downto 0) := (others => '0');
    signal SignExtImm : std_logic_vector(31 downto 0) := (others => '0');
    signal rs         : std_logic_vector(4 downto 0)  := (others => '0');
    signal rt         : std_logic_vector(4 downto 0)  := (others => '0');
    signal rd         : std_logic_vector(4 downto 0)  := (others => '0');
    signal func       : std_logic_vector(5 downto 0)  := (others => '0');

    -- Control outputs
    signal o_RegWrite : std_logic;
    signal o_MemToReg : std_logic;
    signal o_Branch   : std_logic;
    signal o_MemRead  : std_logic;
    signal o_MemWrite : std_logic;
    signal o_RegDst   : std_logic;
    signal o_ALUOp    : std_logic_vector(1 downto 0);
    signal o_ALUSrc   : std_logic;

    -- Data outputs
    signal o_PC_plus4   : std_logic_vector(7 downto 0);
    signal o_ReadData1  : std_logic_vector(31 downto 0);
    signal o_ReadData2  : std_logic_vector(31 downto 0);
    signal o_SignExtImm : std_logic_vector(31 downto 0);
    signal o_rs         : std_logic_vector(4 downto 0);
    signal o_rt         : std_logic_vector(4 downto 0);
    signal o_rd         : std_logic_vector(4 downto 0);
    signal o_func       : std_logic_vector(5 downto 0);

begin

    uut: entity work.ID_EX_register
        port map(
            i_clk        => clk,
            i_rstBAR     => rstBAR,
            i_stall      => stall,
            i_flush      => flush,
            i_RegWrite   => RegWrite,
            i_MemToReg   => MemToReg,
            i_Branch     => Branch,
            i_MemRead    => MemRead,
            i_MemWrite   => MemWrite,
            i_RegDst     => RegDst,
            i_ALUOp      => ALUOp,
            i_ALUSrc     => ALUSrc,
            i_PC_plus4   => PC_plus4,
            i_ReadData1  => ReadData1,
            i_ReadData2  => ReadData2,
            i_SignExtImm => SignExtImm,
            i_rs         => rs,
            i_rt         => rt,
            i_rd         => rd,
            i_func       => func,
            o_RegWrite   => o_RegWrite,
            o_MemToReg   => o_MemToReg,
            o_Branch     => o_Branch,
            o_MemRead    => o_MemRead,
            o_MemWrite   => o_MemWrite,
            o_RegDst     => o_RegDst,
            o_ALUOp      => o_ALUOp,
            o_ALUSrc     => o_ALUSrc,
            o_PC_plus4   => o_PC_plus4,
            o_ReadData1  => o_ReadData1,
            o_ReadData2  => o_ReadData2,
            o_SignExtImm => o_SignExtImm,
            o_rs         => o_rs,
            o_rt         => o_rt,
            o_rd         => o_rd,
            o_func       => o_func
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
        assert o_RegWrite = '0' report "FAIL: RegWrite not zero after reset" severity error;
        assert o_MemToReg = '0' report "FAIL: MemToReg not zero after reset" severity error;
        assert o_Branch   = '0' report "FAIL: Branch not zero after reset"   severity error;
        assert o_MemRead  = '0' report "FAIL: MemRead not zero after reset"  severity error;
        assert o_MemWrite = '0' report "FAIL: MemWrite not zero after reset" severity error;
        assert o_RegDst   = '0' report "FAIL: RegDst not zero after reset"   severity error;
        assert o_ALUOp    = "00" report "FAIL: ALUOp not zero after reset"   severity error;
        assert o_ALUSrc   = '0' report "FAIL: ALUSrc not zero after reset"   severity error;
        assert o_PC_plus4   = x"00"       report "FAIL: PC+4 not zero after reset"      severity error;
        assert o_ReadData1  = x"00000000" report "FAIL: ReadData1 not zero after reset"  severity error;
        assert o_ReadData2  = x"00000000" report "FAIL: ReadData2 not zero after reset"  severity error;
        assert o_SignExtImm = x"00000000" report "FAIL: SignExtImm not zero after reset" severity error;
        assert o_rs   = "00000"  report "FAIL: rs not zero after reset"   severity error;
        assert o_rt   = "00000"  report "FAIL: rt not zero after reset"   severity error;
        assert o_rd   = "00000"  report "FAIL: rd not zero after reset"   severity error;
        assert o_func = "000000" report "FAIL: func not zero after reset" severity error;

        -------- NORMAL LOAD (R-type: add $9, $1, $2) --------
        rstBAR    <= '1';
        RegWrite  <= '1';
        MemToReg  <= '0';
        Branch    <= '0';
        MemRead   <= '0';
        MemWrite  <= '0';
        RegDst    <= '1';
        ALUOp     <= "10";
        ALUSrc    <= '0';
        PC_plus4  <= x"08";
        ReadData1 <= x"00000005";
        ReadData2 <= x"00000003";
        SignExtImm<= x"00000000";
        rs        <= "00001";
        rt        <= "00010";
        rd        <= "01001";
        func      <= "100000";
        wait for CLK_PERIOD;

        assert o_RegWrite = '1'  report "FAIL: RegWrite load" severity error;
        assert o_MemToReg = '0'  report "FAIL: MemToReg load" severity error;
        assert o_Branch   = '0'  report "FAIL: Branch load"   severity error;
        assert o_MemRead  = '0'  report "FAIL: MemRead load"  severity error;
        assert o_MemWrite = '0'  report "FAIL: MemWrite load" severity error;
        assert o_RegDst   = '1'  report "FAIL: RegDst load"   severity error;
        assert o_ALUOp    = "10" report "FAIL: ALUOp load"    severity error;
        assert o_ALUSrc   = '0'  report "FAIL: ALUSrc load"   severity error;
        assert o_PC_plus4   = x"08"       report "FAIL: PC+4 load"      severity error;
        assert o_ReadData1  = x"00000005" report "FAIL: ReadData1 load"  severity error;
        assert o_ReadData2  = x"00000003" report "FAIL: ReadData2 load"  severity error;
        assert o_SignExtImm = x"00000000" report "FAIL: SignExtImm load" severity error;
        assert o_rs   = "00001"  report "FAIL: rs load"   severity error;
        assert o_rt   = "00010"  report "FAIL: rt load"   severity error;
        assert o_rd   = "01001"  report "FAIL: rd load"   severity error;
        assert o_func = "100000" report "FAIL: func load" severity error;

        -------- STALL: outputs must hold previous values --------
        stall     <= '1';
        RegWrite  <= '0';
        MemToReg  <= '1';
        MemRead   <= '1';
        ALUOp     <= "00";
        PC_plus4  <= x"0C";
        ReadData1 <= x"AAAAAAAA";
        ReadData2 <= x"BBBBBBBB";
        rs        <= "11111";
        rt        <= "11111";
        rd        <= "11111";
        func      <= "111111";
        wait for CLK_PERIOD;

        assert o_RegWrite = '1'  report "FAIL: RegWrite not held during stall" severity error;
        assert o_MemToReg = '0'  report "FAIL: MemToReg not held during stall" severity error;
        assert o_MemRead  = '0'  report "FAIL: MemRead not held during stall"  severity error;
        assert o_ALUOp    = "10" report "FAIL: ALUOp not held during stall"    severity error;
        assert o_PC_plus4   = x"08"       report "FAIL: PC+4 not held during stall"      severity error;
        assert o_ReadData1  = x"00000005" report "FAIL: ReadData1 not held during stall"  severity error;
        assert o_ReadData2  = x"00000003" report "FAIL: ReadData2 not held during stall"  severity error;
        assert o_rs   = "00001"  report "FAIL: rs not held during stall"   severity error;
        assert o_rt   = "00010"  report "FAIL: rt not held during stall"   severity error;
        assert o_rd   = "01001"  report "FAIL: rd not held during stall"   severity error;
        assert o_func = "100000" report "FAIL: func not held during stall" severity error;

        -------- RELEASE STALL: new values load --------
        stall <= '0';
        wait for CLK_PERIOD;

        assert o_RegWrite = '0'  report "FAIL: RegWrite after stall release" severity error;
        assert o_MemToReg = '1'  report "FAIL: MemToReg after stall release" severity error;
        assert o_MemRead  = '1'  report "FAIL: MemRead after stall release"  severity error;
        assert o_ALUOp    = "00" report "FAIL: ALUOp after stall release"    severity error;
        assert o_PC_plus4   = x"0C"       report "FAIL: PC+4 after stall release"      severity error;
        assert o_ReadData1  = x"AAAAAAAA" report "FAIL: ReadData1 after stall release"  severity error;
        assert o_ReadData2  = x"BBBBBBBB" report "FAIL: ReadData2 after stall release"  severity error;
        assert o_rs   = "11111"  report "FAIL: rs after stall release"   severity error;
        assert o_rt   = "11111"  report "FAIL: rt after stall release"   severity error;
        assert o_rd   = "11111"  report "FAIL: rd after stall release"   severity error;
        assert o_func = "111111" report "FAIL: func after stall release" severity error;

        -------- FLUSH: all outputs forced to zero --------
        flush <= '1';
        wait for CLK_PERIOD;

        assert o_RegWrite = '0' report "FAIL: RegWrite not zero after flush" severity error;
        assert o_MemToReg = '0' report "FAIL: MemToReg not zero after flush" severity error;
        assert o_Branch   = '0' report "FAIL: Branch not zero after flush"   severity error;
        assert o_MemRead  = '0' report "FAIL: MemRead not zero after flush"  severity error;
        assert o_MemWrite = '0' report "FAIL: MemWrite not zero after flush" severity error;
        assert o_RegDst   = '0' report "FAIL: RegDst not zero after flush"   severity error;
        assert o_ALUOp    = "00" report "FAIL: ALUOp not zero after flush"   severity error;
        assert o_ALUSrc   = '0' report "FAIL: ALUSrc not zero after flush"   severity error;
        assert o_PC_plus4   = x"00"       report "FAIL: PC+4 not zero after flush"      severity error;
        assert o_ReadData1  = x"00000000" report "FAIL: ReadData1 not zero after flush"  severity error;
        assert o_ReadData2  = x"00000000" report "FAIL: ReadData2 not zero after flush"  severity error;
        assert o_SignExtImm = x"00000000" report "FAIL: SignExtImm not zero after flush" severity error;
        assert o_rs   = "00000"  report "FAIL: rs not zero after flush"   severity error;
        assert o_rt   = "00000"  report "FAIL: rt not zero after flush"   severity error;
        assert o_rd   = "00000"  report "FAIL: rd not zero after flush"   severity error;
        assert o_func = "000000" report "FAIL: func not zero after flush" severity error;

        -------- RELEASE FLUSH: normal load resumes --------
        flush     <= '0';
        RegWrite  <= '1';
        MemToReg  <= '1';
        ALUOp     <= "01";
        PC_plus4  <= x"14";
        ReadData1 <= x"12345678";
        SignExtImm<= x"FFFFFFF0";
        rs        <= "10101";
        func      <= "100010";
        wait for CLK_PERIOD;

        assert o_RegWrite = '1'  report "FAIL: RegWrite after flush release" severity error;
        assert o_MemToReg = '1'  report "FAIL: MemToReg after flush release" severity error;
        assert o_ALUOp    = "01" report "FAIL: ALUOp after flush release"    severity error;
        assert o_PC_plus4   = x"14"       report "FAIL: PC+4 after flush release"      severity error;
        assert o_ReadData1  = x"12345678" report "FAIL: ReadData1 after flush release"  severity error;
        assert o_SignExtImm = x"FFFFFFF0" report "FAIL: SignExtImm after flush release" severity error;
        assert o_rs   = "10101"  report "FAIL: rs after flush release"   severity error;
        assert o_func = "100010" report "FAIL: func after flush release" severity error;

        report "ID_EX_register_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
