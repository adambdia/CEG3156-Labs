----------------------------------------------------------------------
-- Testbench: sign_extender_tb
-- Target: GHDL / VHDL-93
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sign_extender_tb IS
END sign_extender_tb;

ARCHITECTURE behavior OF sign_extender_tb IS
    signal s_i : std_logic_vector(15 downto 0) := (others => '0');
    signal s_o : std_logic_vector(31 downto 0);
BEGIN

    uut: entity work.sign_extender(structural)
        PORT MAP (
            i_data => s_i,
            o_data => s_o
        );

    stim_proc: process
    begin
        report "Starting Sign Extender Testbench...";

        -- TEST 1: Positive Value (MSB = 0)
        s_i <= x"0001";
        wait for 10 ns;
        assert (s_o = x"00000001") report "FAILED: Positive extension" severity error;
        if (s_o = x"00000001") then report "PASSED: Positive extension" severity note; end if;

        -- TEST 2: Negative Value (MSB = 1)
        s_i <= x"8000";
        wait for 10 ns;
        assert (s_o = x"FFFF8000") report "FAILED: Negative extension (0x8000)" severity error;
        if (s_o = x"FFFF8000") then report "PASSED: Negative extension (0x8000)" severity note; end if;

        -- TEST 3: All ones
        s_i <= x"FFFF";
        wait for 10 ns;
        assert (s_o = x"FFFFFFFF") report "FAILED: All ones extension" severity error;
        if (s_o = x"FFFFFFFF") then report "PASSED: All ones extension" severity note; end if;

        -- TEST 4: Boundary check (highest positive)
        s_i <= x"7FFF";
        wait for 10 ns;
        assert (s_o = x"00007FFF") report "FAILED: Boundary positive extension" severity error;
        if (s_o = x"00007FFF") then report "PASSED: Boundary positive extension" severity note; end if;

        report "Sign Extender Verification Complete.";
        wait;
    end process;
END behavior;