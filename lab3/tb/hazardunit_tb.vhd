----------------------------------------------------------------------
-- Testbench: hazardunit_tb
-- Target: GHDL / VHDL-93
-- Description: Verifies Load-Use stalling and Branch flushing logic.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hazardunit_tb IS
END hazardunit_tb;

ARCHITECTURE behavior OF hazardunit_tb IS

    -- Stimulus signals
    signal s_IDEX_MemRead   : std_logic := '0';
    signal s_IDEX_Rt        : std_logic_vector(4 downto 0) := (others => '0');
    signal s_IFID_Rs        : std_logic_vector(4 downto 0) := (others => '0');
    signal s_IFID_Rt        : std_logic_vector(4 downto 0) := (others => '0');
    
    signal s_Branch         : std_logic := '0';
    signal s_OpA            : std_logic_vector(31 downto 0) := (others => '0');
    signal s_OpB            : std_logic_vector(31 downto 0) := (others => '0');

    -- Observation signals
    signal s_PCWrite        : std_logic;
    signal s_IFIDWrite      : std_logic;
    signal s_StallMuxSel    : std_logic;
    signal s_IFIDFlush      : std_logic;

BEGIN

    -- Direct Entity Instantiation
    uut: entity work.hazardunit(structural)
        PORT MAP (
            i_IDEX_MemRead => s_IDEX_MemRead,
            i_IDEX_Rt      => s_IDEX_Rt,
            i_IFID_Rs      => s_IFID_Rs,
            i_IFID_Rt      => s_IFID_Rt,
            i_Branch       => s_Branch,
            i_OpA          => s_OpA,
            i_OpB          => s_OpB,
            o_PCWrite      => s_PCWrite,
            o_IFIDWrite    => s_IFIDWrite,
            o_StallMuxSel  => s_StallMuxSel,
            o_IFIDFlush    => s_IFIDFlush
        );

    stim_proc: process
    begin
        report "Starting Hazard Detection Unit Testbench...";

        ----------------------------------------------------------------
        -- TEST 1: Normal Execution (No Hazards)
        ----------------------------------------------------------------
        s_IDEX_MemRead <= '0';
        s_Branch       <= '0';
        s_IFID_Rs      <= "00001";
        s_IFID_Rt      <= "00010";
        s_IDEX_Rt      <= "00011";
        wait for 10 ns;
        assert (s_PCWrite = '1' and s_IFIDWrite = '1' and s_StallMuxSel = '0' and s_IFIDFlush = '0')
            report "FAILED: Normal Execution Case" severity error;
        if (s_PCWrite = '1') then report "PASSED: Normal Execution" severity note; end if;

        ----------------------------------------------------------------
        -- TEST 2: Load-Use Hazard (Match on Rs)
        ----------------------------------------------------------------
        s_IDEX_MemRead <= '1';
        s_IDEX_Rt      <= "00101"; -- Load is writing to Reg 5
        s_IFID_Rs      <= "00101"; -- Next instruction needs Reg 5
        wait for 10 ns;
        assert (s_PCWrite = '0' and s_IFIDWrite = '0' and s_StallMuxSel = '1')
            report "FAILED: Load-Use Hazard (Rs match)" severity error;
        if (s_PCWrite = '0') then report "PASSED: Load-Use Hazard (Rs match)" severity note; end if;

        ----------------------------------------------------------------
        -- TEST 3: Load-Use Hazard (Match on Rt)
        ----------------------------------------------------------------
        s_IFID_Rs <= "01111";
        s_IFID_Rt <= "00101"; -- Match on Rt
        wait for 10 ns;
        assert (s_PCWrite = '0' and s_IFIDWrite = '0' and s_StallMuxSel = '1')
            report "FAILED: Load-Use Hazard (Rt match)" severity error;
        if (s_PCWrite = '0') then report "PASSED: Load-Use Hazard (Rt match)" severity note; end if;

        ----------------------------------------------------------------
        -- TEST 4: Control Hazard (BEQ Branch Taken)
        ----------------------------------------------------------------
        s_IDEX_MemRead <= '0'; -- Remove Stall
        s_Branch       <= '1';
        s_OpA          <= x"0000CAFE";
        s_OpB          <= x"0000CAFE"; -- Operands Equal
        wait for 10 ns;
        assert (s_IFIDFlush = '1') report "FAILED: BEQ Branch Taken (Flush)" severity error;
        if (s_IFIDFlush = '1') then report "PASSED: BEQ Branch Taken (Flush)" severity note; end if;

        ----------------------------------------------------------------
        -- TEST 5: Control Hazard (BEQ Branch Not Taken)
        ----------------------------------------------------------------
        s_OpB <= x"0000BABE"; -- Operands Not Equal
        wait for 10 ns;
        assert (s_IFIDFlush = '0') report "FAILED: BEQ Branch Not Taken" severity error;
        if (s_IFIDFlush = '0') then report "PASSED: BEQ Branch Not Taken" severity note; end if;

        ----------------------------------------------------------------
        -- TEST 6: Simultaneous Stall and Branch
        -- (Stall logic should still trigger regardless of Branch inputs)
        ----------------------------------------------------------------
        s_IDEX_MemRead <= '1';
        s_IDEX_Rt      <= "10101";
        s_IFID_Rs      <= "10101"; -- Cause Stall
        s_Branch       <= '1';
        s_OpA          <= x"11111111";
        s_OpB          <= x"11111111"; -- Cause Flush
        wait for 10 ns;
        assert (s_PCWrite = '0' and s_IFIDFlush = '1') 
            report "FAILED: Simultaneous Stall and Flush" severity error;
        if (s_PCWrite = '0' and s_IFIDFlush = '1') then 
            report "PASSED: Simultaneous Stall and Flush" severity note; 
        end if;

        report "Hazard Detection Unit Verification Complete.";
        wait;
    end process;

END behavior;