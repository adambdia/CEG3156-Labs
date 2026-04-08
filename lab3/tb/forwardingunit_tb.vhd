----------------------------------------------------------------------
-- Testbench: forwardingunit_tb
-- Target: GHDL / VHDL-93
-- Description: Verifies EX hazards, MEM hazards, and priority logic.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY forwardingunit_tb IS
END forwardingunit_tb;

ARCHITECTURE behavior OF forwardingunit_tb IS

    -- Stimulus signals
    signal s_EXMEM_RegWrite : std_logic := '0';
    signal s_MEMWB_RegWrite : std_logic := '0';
    signal s_EXMEM_Rd       : std_logic_vector(4 downto 0) := (others => '0');
    signal s_MEMWB_Rd       : std_logic_vector(4 downto 0) := (others => '0');
    signal s_IDEX_Rs        : std_logic_vector(4 downto 0) := (others => '0');
    signal s_IDEX_Rt        : std_logic_vector(4 downto 0) := (others => '0');

    -- Observation signals
    signal s_ForwardA       : std_logic_vector(1 downto 0);
    signal s_ForwardB       : std_logic_vector(1 downto 0);

BEGIN

    -- Direct Entity Instantiation
    uut: entity work.forwardingunit(structural)
        PORT MAP (
            i_EXMEM_RegWrite => s_EXMEM_RegWrite,
            i_MEMWB_RegWrite => s_MEMWB_RegWrite,
            i_EXMEM_Rd       => s_EXMEM_Rd,
            i_MEMWB_Rd       => s_MEMWB_Rd,
            i_IDEX_Rs        => s_IDEX_Rs,
            i_IDEX_Rt        => s_IDEX_Rt,
            o_ForwardA       => s_ForwardA,
            o_ForwardB       => s_ForwardB
        );

    stim_proc: process
    begin
        report "Starting Forwarding Unit Testbench...";

        -- TEST 1: No Hazards
        s_EXMEM_RegWrite <= '0'; s_MEMWB_RegWrite <= '0';
        s_IDEX_Rs <= "00001"; s_IDEX_Rt <= "00010";
        s_EXMEM_Rd <= "00011"; s_MEMWB_Rd <= "00100";
        wait for 10 ns;
        assert (s_ForwardA = "00" and s_ForwardB = "00") report "FAILED: No Hazard case" severity error;
        if (s_ForwardA = "00") then report "PASSED: No Hazard case" severity note; end if;

        -- TEST 2: EX Hazard on Rs (ForwardA should be 10)
        s_EXMEM_RegWrite <= '1';
        s_EXMEM_Rd <= "00001"; -- Matches IDEX_Rs
        wait for 10 ns;
        assert (s_ForwardA = "10") report "FAILED: EX Hazard on Rs" severity error;
        if (s_ForwardA = "10") then report "PASSED: EX Hazard on Rs" severity note; end if;

        -- TEST 3: EX Hazard on Rt (ForwardB should be 10)
        s_IDEX_Rt <= "00001"; -- Matches EXMEM_Rd
        wait for 10 ns;
        assert (s_ForwardB = "10") report "FAILED: EX Hazard on Rt" severity error;
        if (s_ForwardB = "10") then report "PASSED: EX Hazard on Rt" severity note; end if;

        -- TEST 4: MEM Hazard on Rs (ForwardA should be 01)
        s_EXMEM_RegWrite <= '0'; -- Disable EX Hazard
        s_MEMWB_RegWrite <= '1';
        s_MEMWB_Rd <= "00001";   -- Matches IDEX_Rs
        wait for 10 ns;
        assert (s_ForwardA = "01") report "FAILED: MEM Hazard on Rs" severity error;
        if (s_ForwardA = "01") then report "PASSED: MEM Hazard on Rs" severity note; end if;

        -- TEST 5: Double Data Hazard Priority (ForwardA should remain 10)
        -- Both stages write to Reg 1. EX stage (most recent) must win.
        s_EXMEM_RegWrite <= '1';
        s_EXMEM_Rd <= "00001"; 
        s_MEMWB_Rd <= "00001";
        wait for 10 ns;
        assert (s_ForwardA = "10") report "FAILED: Double Hazard Priority (EX should win)" severity error;
        if (s_ForwardA = "10") then report "PASSED: Double Hazard Priority logic" severity note; end if;

        -- TEST 6: Register 0 Check (Should never forward)
        s_IDEX_Rs <= "00000";
        s_EXMEM_Rd <= "00000";
        s_EXMEM_RegWrite <= '1';
        wait for 10 ns;
        assert (s_ForwardA = "00") report "FAILED: Register 0 Forwarding protection" severity error;
        if (s_ForwardA = "00") then report "PASSED: Register 0 Forwarding protection" severity note; end if;

        -- TEST 7: RegWrite Disable Check
        s_IDEX_Rs <= "01010";
        s_EXMEM_Rd <= "01010";
        s_EXMEM_RegWrite <= '0'; -- Even though addresses match, RegWrite is low
        wait for 10 ns;
        assert (s_ForwardA = "00") report "FAILED: RegWrite enable check" severity error;
        if (s_ForwardA = "00") then report "PASSED: RegWrite enable check" severity note; end if;

        report "Forwarding Unit Verification Complete.";
        wait;
    end process;

END behavior;