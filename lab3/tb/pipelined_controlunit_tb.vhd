----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: pipelined_controlunit_tb.vhd
-- Description: Testbench for pipelined control unit
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity pipelined_controlunit_tb is
end pipelined_controlunit_tb;

architecture behavior of pipelined_controlunit_tb is

    signal opcode   : std_logic_vector(5 downto 0) := "000000";
    signal RegDst   : std_logic;
    signal MemRead  : std_logic;
    signal MemToReg : std_logic;
    signal MemWrite : std_logic;
    signal ALUSrc   : std_logic;
    signal RegWrite : std_logic;
    signal Branch   : std_logic;
    signal ALUOp    : std_logic_vector(1 downto 0);
    signal Jump     : std_logic;

begin

    uut: entity work.pipelined_controlunit
        port map(
            i_opcode   => opcode,
            o_RegDst   => RegDst,
            o_MemRead  => MemRead,
            o_MemToReg => MemToReg,
            o_MemWrite => MemWrite,
            o_ALUSrc   => ALUSrc,
            o_RegWrite => RegWrite,
            o_Branch   => Branch,
            o_ALUOp    => ALUOp,
            o_Jump     => Jump
        );

    stim_process: process
    begin
        -------- R-type (opcode 000000) --------
        opcode <= "000000";
        wait for 10 ns;
        assert RegDst   = '1'  report "FAIL R-type: RegDst"   severity error;
        assert ALUSrc   = '0'  report "FAIL R-type: ALUSrc"   severity error;
        assert MemToReg = '0'  report "FAIL R-type: MemToReg" severity error;
        assert RegWrite = '1'  report "FAIL R-type: RegWrite" severity error;
        assert MemRead  = '0'  report "FAIL R-type: MemRead"  severity error;
        assert MemWrite = '0'  report "FAIL R-type: MemWrite" severity error;
        assert Branch   = '0'  report "FAIL R-type: Branch"   severity error;
        assert ALUOp    = "10" report "FAIL R-type: ALUOp"    severity error;
        assert Jump     = '0'  report "FAIL R-type: Jump"     severity error;

        -------- lw (opcode 100011) --------
        opcode <= "100011";
        wait for 10 ns;
        assert RegDst   = '0'  report "FAIL lw: RegDst"   severity error;
        assert ALUSrc   = '1'  report "FAIL lw: ALUSrc"   severity error;
        assert MemToReg = '1'  report "FAIL lw: MemToReg" severity error;
        assert RegWrite = '1'  report "FAIL lw: RegWrite" severity error;
        assert MemRead  = '1'  report "FAIL lw: MemRead"  severity error;
        assert MemWrite = '0'  report "FAIL lw: MemWrite" severity error;
        assert Branch   = '0'  report "FAIL lw: Branch"   severity error;
        assert ALUOp    = "00" report "FAIL lw: ALUOp"    severity error;
        assert Jump     = '0'  report "FAIL lw: Jump"     severity error;

        -------- sw (opcode 101011) --------
        opcode <= "101011";
        wait for 10 ns;
        assert RegDst   = '0'  report "FAIL sw: RegDst"   severity error;
        assert ALUSrc   = '1'  report "FAIL sw: ALUSrc"   severity error;
        assert MemToReg = '1'  report "FAIL sw: MemToReg" severity error;
        assert RegWrite = '0'  report "FAIL sw: RegWrite" severity error;
        assert MemRead  = '0'  report "FAIL sw: MemRead"  severity error;
        assert MemWrite = '1'  report "FAIL sw: MemWrite" severity error;
        assert Branch   = '0'  report "FAIL sw: Branch"   severity error;
        assert ALUOp    = "00" report "FAIL sw: ALUOp"    severity error;
        assert Jump     = '0'  report "FAIL sw: Jump"     severity error;

        -------- beq (opcode 000100) --------
        opcode <= "000100";
        wait for 10 ns;
        assert RegDst   = '0'  report "FAIL beq: RegDst"   severity error;
        assert ALUSrc   = '0'  report "FAIL beq: ALUSrc"   severity error;
        assert MemToReg = '0'  report "FAIL beq: MemToReg" severity error;
        assert RegWrite = '0'  report "FAIL beq: RegWrite" severity error;
        assert MemRead  = '0'  report "FAIL beq: MemRead"  severity error;
        assert MemWrite = '0'  report "FAIL beq: MemWrite" severity error;
        assert Branch   = '1'  report "FAIL beq: Branch"   severity error;
        assert ALUOp    = "01" report "FAIL beq: ALUOp"    severity error;
        assert Jump     = '0'  report "FAIL beq: Jump"     severity error;

        -------- j (opcode 000010) --------
        opcode <= "000010";
        wait for 10 ns;
        assert RegDst   = '0'  report "FAIL j: RegDst"   severity error;
        assert ALUSrc   = '0'  report "FAIL j: ALUSrc"   severity error;
        assert MemToReg = '0'  report "FAIL j: MemToReg" severity error;
        assert RegWrite = '0'  report "FAIL j: RegWrite" severity error;
        assert MemRead  = '0'  report "FAIL j: MemRead"  severity error;
        assert MemWrite = '0'  report "FAIL j: MemWrite" severity error;
        assert Branch   = '0'  report "FAIL j: Branch"   severity error;
        assert ALUOp    = "00" report "FAIL j: ALUOp"    severity error;
        assert Jump     = '1'  report "FAIL j: Jump"     severity error;

        report "pipelined_controlunit_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
