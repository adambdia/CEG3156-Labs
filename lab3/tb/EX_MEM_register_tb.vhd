----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: EX_MEM_register_tb.vhd
-- Description: Testbench for EX/MEM pipeline register
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity EX_MEM_register_tb is
end EX_MEM_register_tb;

architecture behavior of EX_MEM_register_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk          : std_logic := '0';
    signal rstBAR       : std_logic := '0';
    signal stall        : std_logic := '0';
    signal flush        : std_logic := '0';

    -- Control inputs
    signal RegWrite     : std_logic := '0';
    signal MemToReg     : std_logic := '0';
    signal Branch       : std_logic := '0';
    signal MemRead      : std_logic := '0';
    signal MemWrite     : std_logic := '0';

    -- Data inputs
    signal BranchTarget : std_logic_vector(7 downto 0)  := (others => '0');
    signal Zero         : std_logic := '0';
    signal ALUResult    : std_logic_vector(31 downto 0) := (others => '0');
    signal WriteData    : std_logic_vector(31 downto 0) := (others => '0');
    signal WriteReg     : std_logic_vector(4 downto 0)  := (others => '0');

    -- Control outputs
    signal o_RegWrite   : std_logic;
    signal o_MemToReg   : std_logic;
    signal o_Branch     : std_logic;
    signal o_MemRead    : std_logic;
    signal o_MemWrite   : std_logic;

    -- Data outputs
    signal o_BranchTarget : std_logic_vector(7 downto 0);
    signal o_Zero         : std_logic;
    signal o_ALUResult    : std_logic_vector(31 downto 0);
    signal o_WriteData    : std_logic_vector(31 downto 0);
    signal o_WriteReg     : std_logic_vector(4 downto 0);

begin

    uut: entity work.EX_MEM_register
        port map(
            i_clk          => clk,
            i_rstBAR       => rstBAR,
            i_stall        => stall,
            i_flush        => flush,
            i_RegWrite     => RegWrite,
            i_MemToReg     => MemToReg,
            i_Branch       => Branch,
            i_MemRead      => MemRead,
            i_MemWrite     => MemWrite,
            i_BranchTarget => BranchTarget,
            i_Zero         => Zero,
            i_ALUResult    => ALUResult,
            i_WriteData    => WriteData,
            i_WriteReg     => WriteReg,
            o_RegWrite     => o_RegWrite,
            o_MemToReg     => o_MemToReg,
            o_Branch       => o_Branch,
            o_MemRead      => o_MemRead,
            o_MemWrite     => o_MemWrite,
            o_BranchTarget => o_BranchTarget,
            o_Zero         => o_Zero,
            o_ALUResult    => o_ALUResult,
            o_WriteData    => o_WriteData,
            o_WriteReg     => o_WriteReg
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
        assert o_BranchTarget = x"00"       report "FAIL: BranchTarget not zero after reset" severity error;
        assert o_Zero         = '0'         report "FAIL: Zero not zero after reset"         severity error;
        assert o_ALUResult    = x"00000000" report "FAIL: ALUResult not zero after reset"    severity error;
        assert o_WriteData    = x"00000000" report "FAIL: WriteData not zero after reset"    severity error;
        assert o_WriteReg     = "00000"     report "FAIL: WriteReg not zero after reset"     severity error;

        -------- NORMAL LOAD (sw-like: store, Branch taken) --------
        rstBAR       <= '1';
        RegWrite     <= '0';
        MemToReg     <= '0';
        Branch       <= '1';
        MemRead      <= '0';
        MemWrite     <= '1';
        BranchTarget <= x"20";
        Zero         <= '1';
        ALUResult    <= x"00000010";
        WriteData    <= x"ABCD1234";
        WriteReg     <= "01010";
        wait for CLK_PERIOD;

        assert o_RegWrite     = '0'         report "FAIL: RegWrite load"     severity error;
        assert o_Branch       = '1'         report "FAIL: Branch load"       severity error;
        assert o_MemWrite     = '1'         report "FAIL: MemWrite load"     severity error;
        assert o_BranchTarget = x"20"       report "FAIL: BranchTarget load" severity error;
        assert o_Zero         = '1'         report "FAIL: Zero load"         severity error;
        assert o_ALUResult    = x"00000010" report "FAIL: ALUResult load"    severity error;
        assert o_WriteData    = x"ABCD1234" report "FAIL: WriteData load"    severity error;
        assert o_WriteReg     = "01010"     report "FAIL: WriteReg load"     severity error;

        -------- STALL: outputs must hold --------
        stall        <= '1';
        RegWrite     <= '1';
        Branch       <= '0';
        MemWrite     <= '0';
        MemRead      <= '1';
        BranchTarget <= x"40";
        Zero         <= '0';
        ALUResult    <= x"FFFFFFFF";
        WriteData    <= x"00000000";
        WriteReg     <= "11111";
        wait for CLK_PERIOD;

        assert o_RegWrite     = '0'         report "FAIL: RegWrite not held during stall"     severity error;
        assert o_Branch       = '1'         report "FAIL: Branch not held during stall"       severity error;
        assert o_MemWrite     = '1'         report "FAIL: MemWrite not held during stall"     severity error;
        assert o_MemRead      = '0'         report "FAIL: MemRead not held during stall"      severity error;
        assert o_BranchTarget = x"20"       report "FAIL: BranchTarget not held during stall" severity error;
        assert o_Zero         = '1'         report "FAIL: Zero not held during stall"         severity error;
        assert o_ALUResult    = x"00000010" report "FAIL: ALUResult not held during stall"    severity error;
        assert o_WriteData    = x"ABCD1234" report "FAIL: WriteData not held during stall"    severity error;
        assert o_WriteReg     = "01010"     report "FAIL: WriteReg not held during stall"     severity error;

        -------- RELEASE STALL --------
        stall <= '0';
        wait for CLK_PERIOD;

        assert o_RegWrite     = '1'         report "FAIL: RegWrite after stall release"     severity error;
        assert o_Branch       = '0'         report "FAIL: Branch after stall release"       severity error;
        assert o_MemWrite     = '0'         report "FAIL: MemWrite after stall release"     severity error;
        assert o_MemRead      = '1'         report "FAIL: MemRead after stall release"      severity error;
        assert o_BranchTarget = x"40"       report "FAIL: BranchTarget after stall release" severity error;
        assert o_Zero         = '0'         report "FAIL: Zero after stall release"         severity error;
        assert o_ALUResult    = x"FFFFFFFF" report "FAIL: ALUResult after stall release"    severity error;
        assert o_WriteData    = x"00000000" report "FAIL: WriteData after stall release"    severity error;
        assert o_WriteReg     = "11111"     report "FAIL: WriteReg after stall release"     severity error;

        -------- FLUSH --------
        flush <= '1';
        wait for CLK_PERIOD;

        assert o_RegWrite     = '0'         report "FAIL: RegWrite not zero after flush"     severity error;
        assert o_MemToReg     = '0'         report "FAIL: MemToReg not zero after flush"     severity error;
        assert o_Branch       = '0'         report "FAIL: Branch not zero after flush"       severity error;
        assert o_MemRead      = '0'         report "FAIL: MemRead not zero after flush"      severity error;
        assert o_MemWrite     = '0'         report "FAIL: MemWrite not zero after flush"     severity error;
        assert o_BranchTarget = x"00"       report "FAIL: BranchTarget not zero after flush" severity error;
        assert o_Zero         = '0'         report "FAIL: Zero not zero after flush"         severity error;
        assert o_ALUResult    = x"00000000" report "FAIL: ALUResult not zero after flush"    severity error;
        assert o_WriteData    = x"00000000" report "FAIL: WriteData not zero after flush"    severity error;
        assert o_WriteReg     = "00000"     report "FAIL: WriteReg not zero after flush"     severity error;

        -------- RELEASE FLUSH --------
        flush        <= '0';
        RegWrite     <= '1';
        MemToReg     <= '1';
        Branch       <= '0';
        MemRead      <= '1';
        MemWrite     <= '0';
        BranchTarget <= x"30";
        Zero         <= '0';
        ALUResult    <= x"DEADBEEF";
        WriteData    <= x"CAFEBABE";
        WriteReg     <= "10011";
        wait for CLK_PERIOD;

        assert o_RegWrite     = '1'         report "FAIL: RegWrite after flush release"     severity error;
        assert o_MemToReg     = '1'         report "FAIL: MemToReg after flush release"     severity error;
        assert o_MemRead      = '1'         report "FAIL: MemRead after flush release"      severity error;
        assert o_BranchTarget = x"30"       report "FAIL: BranchTarget after flush release" severity error;
        assert o_ALUResult    = x"DEADBEEF" report "FAIL: ALUResult after flush release"    severity error;
        assert o_WriteData    = x"CAFEBABE" report "FAIL: WriteData after flush release"    severity error;
        assert o_WriteReg     = "10011"     report "FAIL: WriteReg after flush release"     severity error;

        report "EX_MEM_register_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
