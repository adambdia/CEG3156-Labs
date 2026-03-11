----------------------------------------------------------------------
-- Testbench: controlunit_tb
-- Target: GHDL / VHDL-93
-- Description: Tests the integrated Control Unit (Decoder + Generator)
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controlunit_tb IS
END controlunit_tb;

ARCHITECTURE behavior OF controlunit_tb IS

    -- Signals to connect to the Control Unit
    signal s_opcode   : std_logic_vector(5 downto 0) := (others => '0');
    signal s_zero     : std_logic := '0';
    
    signal s_RegDst   : std_logic;
    signal s_MemRead  : std_logic;
    signal s_MemToReg : std_logic;
    signal s_MemWrite : std_logic;
    signal s_ALUSrc   : std_logic;
    signal s_RegWrite : std_logic;
    signal s_Branch   : std_logic;
    signal s_ALUOp    : std_logic_vector(1 downto 0);
    signal s_Jump     : std_logic;

BEGIN

    -- Direct Instantiation of the top-level Control Unit
    uut: entity work.controlunit(structural)
        PORT MAP (
            i_opcode   => s_opcode,
            i_zero     => s_zero,
            o_RegDst   => s_RegDst,
            o_MemRead  => s_MemRead,
            o_MemToReg => s_MemToReg,
            o_MemWrite => s_MemWrite,
            o_ALUSrc   => s_ALUSrc,
            o_RegWrite => s_RegWrite,
            o_Branch   => s_Branch,
            o_ALUOp    => s_ALUOp
        );

    -- Stimulus process
    stim_proc: process
    begin
        report "Starting Control Unit Integrated Testbench...";

        -- TEST 1: R-Type (Opcode 0)
        s_opcode <= "000000"; s_zero <= '0';
        wait for 10 ns;
        assert (s_RegDst = '1' and s_RegWrite = '1' and s_ALUOp = "10") 
            report "FAILED: R-Type Control Signals" severity error;
        assert (s_RegDst = '1') report "PASSED: R-Type Logic" severity note;

        -- TEST 2: Jump (Opcode 2)
        -- Per your logic: o_Branch should be high because i_Jump is high
        s_opcode <= "000010"; s_zero <= '0';
        wait for 10 ns;
        assert (s_Jump = '1' and s_Branch = '1') 
            report "FAILED: Jump Control Signals" severity error;
        assert (s_Jump = '1') report "PASSED: Jump Logic" severity note;

        -- TEST 3: BEQ - Taken (Opcode 4, Zero = 1)
        s_opcode <= "000100"; s_zero <= '1';
        wait for 10 ns;
        assert (s_Branch = '1' and s_ALUOp = "01") 
            report "FAILED: BEQ Taken" severity error;
        assert (s_Branch = '1') report "PASSED: BEQ Taken Logic" severity note;

        -- TEST 4: BEQ - Not Taken (Opcode 4, Zero = 0)
        s_opcode <= "000100"; s_zero <= '0';
        wait for 10 ns;
        assert (s_Branch = '0') report "FAILED: BEQ Not Taken" severity error;
        assert (s_Branch = '0') report "PASSED: BEQ Not Taken Logic" severity note;

        -- TEST 5: BNE - Taken (Opcode 5, Zero = 0)
        -- BNE + Zero=0 should result in Branch=1
        s_opcode <= "000101"; s_zero <= '0';
        wait for 10 ns;
        assert (s_Branch = '1') report "FAILED: BNE Taken" severity error;
        assert (s_Branch = '1') report "PASSED: BNE Taken Logic" severity note;

        -- TEST 6: BNE - Not Taken (Opcode 5, Zero = 1)
        s_opcode <= "000101"; s_zero <= '1';
        wait for 10 ns;
        assert (s_Branch = '0') report "FAILED: BNE Not Taken" severity error;
        assert (s_Branch = '0') report "PASSED: BNE Not Taken Logic" severity note;

        -- TEST 7: Load Word (Opcode 35 -> 100011)
        s_opcode <= "100011"; s_zero <= '0';
        wait for 10 ns;
        assert (s_MemRead = '1' and s_RegWrite = '1' and s_ALUSrc = '1') 
            report "FAILED: LW Control Signals" severity error;
        assert (s_MemRead = '1') report "PASSED: LW Logic" severity note;

        -- TEST 8: Store Word (Opcode 43 -> 101011)
        s_opcode <= "101011"; s_zero <= '0';
        wait for 10 ns;
        assert (s_MemWrite = '1' and s_ALUSrc = '1' and s_RegWrite = '0') 
            report "FAILED: SW Control Signals" severity error;
        assert (s_MemWrite = '1') report "PASSED: SW Logic" severity note;

        report "All Integrated Control Unit tests completed successfully.";
        wait;
    end process;

END behavior;