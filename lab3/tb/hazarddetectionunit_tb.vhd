----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: hazarddetectionunit_tb.vhd
-- Description: Testbench for hazard detection unit
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hazarddetectionunit_tb is
end hazarddetectionunit_tb;

architecture behavior of hazarddetectionunit_tb is

    signal IDEX_MemRead : std_logic := '0';
    signal IDEX_Rt      : std_logic_vector(4 downto 0) := "00000";
    signal IFID_Rs      : std_logic_vector(4 downto 0) := "00000";
    signal IFID_Rt      : std_logic_vector(4 downto 0) := "00000";
    signal stall        : std_logic;

begin

    uut: entity work.hazarddetectionunit
        port map(
            i_IDEX_MemRead => IDEX_MemRead,
            i_IDEX_Rt      => IDEX_Rt,
            i_IFID_Rs      => IFID_Rs,
            i_IFID_Rt      => IFID_Rt,
            o_stall        => stall
        );

    stim_process: process
    begin
        -------- No hazard: MemRead=0 --------
        IDEX_MemRead <= '0';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00001";
        IFID_Rt <= "00010";
        wait for 10 ns;
        assert stall = '0' report "FAIL: stall should be 0 when MemRead=0" severity error;

        -------- MemRead=1, no match --------
        IDEX_MemRead <= '1';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00001";
        IFID_Rt <= "00010";
        wait for 10 ns;
        assert stall = '0' report "FAIL: stall should be 0 when no register match" severity error;

        -------- MemRead=1, Rs match --------
        IDEX_MemRead <= '1';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00101";
        IFID_Rt <= "00010";
        wait for 10 ns;
        assert stall = '1' report "FAIL: stall should be 1 when Rs matches" severity error;

        -------- MemRead=1, Rt match --------
        IDEX_MemRead <= '1';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00001";
        IFID_Rt <= "00101";
        wait for 10 ns;
        assert stall = '1' report "FAIL: stall should be 1 when Rt matches" severity error;

        -------- MemRead=1, both match --------
        IDEX_MemRead <= '1';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00101";
        IFID_Rt <= "00101";
        wait for 10 ns;
        assert stall = '1' report "FAIL: stall should be 1 when both match" severity error;

        -------- MemRead=0, match exists (no hazard) --------
        IDEX_MemRead <= '0';
        IDEX_Rt <= "00101";
        IFID_Rs <= "00101";
        IFID_Rt <= "00101";
        wait for 10 ns;
        assert stall = '0' report "FAIL: stall should be 0 when MemRead=0 even with match" severity error;

        report "hazarddetectionunit_tb: ALL TESTS PASSED" severity note;
        wait;
    end process;

end behavior;
