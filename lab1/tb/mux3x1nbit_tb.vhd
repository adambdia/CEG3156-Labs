library ieee;
use ieee.std_logic_1164.all;

entity mux3x1nbit_tb is
end mux3x1nbit_tb;

architecture tb of mux3x1nbit_tb is
    constant bits : positive := 4;

    signal i_a, i_b, i_c : std_logic_vector(bits-1 downto 0);
    signal i_sel         : std_logic_vector(1 downto 0);
    signal o_out         : std_logic_vector(bits-1 downto 0);
begin
    uut: entity work.mux3x1nbit
        generic map (
            bits => bits
        )
        port map (
            i_a   => i_a,
            i_b   => i_b,
            i_c   => i_c,
            i_sel => i_sel,
            o_out => o_out
        );

    stim_proc: process
    begin
        i_a <= "0001";
        i_b <= "1010";
        i_c <= "1111";

        i_sel <= "00"; wait for 10 ns;
        assert o_out = i_a report "FAIL: sel=00" severity error;

        i_sel <= "01"; wait for 10 ns;
        assert o_out = i_b report "FAIL: sel=01" severity error;

        i_sel <= "10"; wait for 10 ns;
        assert o_out = i_c report "FAIL: sel=10" severity error;

        i_sel <= "11"; wait for 10 ns;
        assert o_out = (bits-1 downto 0 => '0') report "FAIL: sel=11" severity error;

        report "mux3x1nbit_tb PASSED" severity note;
        wait;
    end process;
end tb;
