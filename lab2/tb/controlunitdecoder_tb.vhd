----------------------------------------------------------------------
-- Testbench: controlunitdecoder_tb
-- Target: GHDL / VHDL-93
-- Method: Direct Entity Instantiation (No component declaration)
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controlunitdecoder_tb IS
END controlunitdecoder_tb;

ARCHITECTURE behavior OF controlunitdecoder_tb IS

    -- Signals to connect to the Unit Under Test (UUT)
    signal s_opcode       : std_logic_vector(5 downto 0) := (others => '0');
    signal s_Rtype        : std_logic;
    signal s_Itype        : std_logic;
    signal s_lw           : std_logic;
    signal s_sw           : std_logic;
    signal s_Jtype        : std_logic;
    signal s_Jump         : std_logic;
    signal s_opcode_bit_0 : std_logic;

BEGIN

    -- Direct Instantiation from the work library (VHDL-93 Feature)
    uut: entity work.controlunitdecoder(rtl) 
        PORT MAP (
            i_opcode       => s_opcode,
            o_Rtype        => s_Rtype,
            o_Itype        => s_Itype,
            o_lw           => s_lw,
            o_sw           => s_sw,
            o_Jtype        => s_Jtype,
            o_Jump         => s_Jump,
            o_opcode_bit_0 => s_opcode_bit_0
        );

    -- Stimulus process (Behavioral code permitted in testbenches)
    stim_proc: process
    begin
        report "Starting Control Unit Decoder Testbench (Direct Instantiation)...";

        -- TEST 1: R-Type (Opcode 0)
        s_opcode <= "000000";
        wait for 10 ns;
        assert (s_Rtype = '1') report "FAILED: R-type detection" severity error;
        assert (s_Rtype = '1') report "PASSED: R-type detection (Opcode 0)" severity note;

        -- TEST 2: Jump (Opcode 2)
        s_opcode <= "000010";
        wait for 10 ns;
        assert (s_Jump = '1') report "FAILED: Jump detection" severity error;
        assert (s_Jump = '1') report "PASSED: Jump detection (Opcode 2)" severity note;

        -- TEST 3: Branch - BEQ (Opcode 4)
        s_opcode <= "000100";
        wait for 10 ns;
        assert (s_Jtype = '1' and s_opcode_bit_0 = '0') report "FAILED: BEQ detection" severity error;
        assert (s_Jtype = '1') report "PASSED: Branch/Jtype detection (Opcode 4)" severity note;

        -- TEST 4: Branch - BNE (Opcode 5)
        s_opcode <= "000101";
        wait for 10 ns;
        assert (s_Jtype = '1' and s_opcode_bit_0 = '1') report "FAILED: BNE detection" severity error;
        assert (s_Jtype = '1') report "PASSED: Branch/Jtype detection (Opcode 5)" severity note;

        -- TEST 5: Load Word (Opcode 35 -> 100011)
        s_opcode <= "100011";
        wait for 10 ns;
        assert (s_lw = '1' and s_Itype = '1') report "FAILED: LW detection" severity error;
        assert (s_lw = '1') report "PASSED: LW detection (Opcode 35)" severity note;

        -- TEST 6: Store Word (Opcode 43 -> 101011)
        s_opcode <= "101011";
        wait for 10 ns;
        assert (s_sw = '1' and s_Itype = '1') report "FAILED: SW detection" severity error;
        assert (s_sw = '1') report "PASSED: SW detection (Opcode 43)" severity note;

        report "Verification complete.";
        wait; -- End of simulation
    end process;

END behavior;