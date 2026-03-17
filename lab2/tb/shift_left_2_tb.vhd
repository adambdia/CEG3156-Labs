----------------------------------------------------------------------
-- Testbench: shift_left_2_tb
-- Target: GHDL / VHDL-93
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY shift_left_2_tb IS
END shift_left_2_tb;

ARCHITECTURE behavior OF shift_left_2_tb IS
    signal s_i : std_logic_vector(31 downto 0) := (others => '0');
    signal s_o : std_logic_vector(31 downto 0);
BEGIN

    uut: entity work.shift_left_2(structural)
        PORT MAP (
            i_data => s_i,
            o_data => s_o
        );

    stim_proc: process
    begin
        report "Starting Shift Left 2 Testbench...";

        -- TEST 1: Basic Shift (1 -> 4)
        s_i <= x"00000001";
        wait for 10 ns;
        assert (s_o = x"00000004") report "FAILED: Shift 1 to 4" severity error;
        if (s_o = x"00000004") then report "PASSED: Shift 1 to 4" severity note; end if;

        -- TEST 2: Multi-bit Shift (7 -> 28 / 0x1C)
        s_i <= x"00000007";
        wait for 10 ns;
        assert (s_o = x"0000001C") report "FAILED: Shift 7 to 0x1C" severity error;
        if (s_o = x"0000001C") then report "PASSED: Shift 7 to 0x1C" severity note; end if;

        -- TEST 3: MSB shift-out check
        -- 0xC0000000 (1100...00) should become 0x00000000 as bits shift out of 32-bit range
        s_i <= x"C0000000";
        wait for 10 ns;
        assert (s_o = x"00000000") report "FAILED: Shift-out MSBs" severity error;
        if (s_o = x"00000000") then report "PASSED: Shift-out MSBs" severity note; end if;

        -- TEST 4: Mid-range shift
        s_i <= x"0000FFFF";
        wait for 10 ns;
        assert (s_o = x"0003FFFC") report "FAILED: Mid-range shift" severity error;
        if (s_o = x"0003FFFC") then report "PASSED: Mid-range shift" severity note; end if;

        report "Shift Left 2 Verification Complete.";
        wait;
    end process;
END behavior;