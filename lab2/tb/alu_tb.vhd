library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is

constant bits : integer := 32;

signal A, B : std_logic_vector(bits-1 downto 0);
signal func : std_logic_vector(5 downto 0);
signal result : std_logic_vector(bits-1 downto 0);
signal zero : std_logic;
signal carry : std_logic;

begin

-- Instantiate ALU
uut: entity work.alu
generic map(bits => bits)
port map(
    i_input1 => A,
    i_input2 => B,
    i_func   => func,
    o_output => result,
    o_zero   => zero,
    o_carryOut => carry
);

process
begin

---------------- ADD TESTS ----------------
func <= "100000"; -- ADD

A <= x"00000005"; B <= x"00000003";
wait for 10 ns;

A <= x"00000010"; B <= x"00000010";
wait for 10 ns;

A <= x"FFFFFFFF"; B <= x"00000001";
wait for 10 ns;

---------------- SUB TESTS ----------------
func <= "100010"; -- SUB

A <= x"00000009"; B <= x"00000004";
wait for 10 ns;

A <= x"00000005"; B <= x"00000005";
wait for 10 ns;

A <= x"00000003"; B <= x"00000007";
wait for 10 ns;

---------------- AND TESTS ----------------
func <= "100100"; -- AND

A <= x"FFFFFFFF"; B <= x"0F0F0F0F";
wait for 10 ns;

A <= x"12345678"; B <= x"87654321";
wait for 10 ns;

A <= x"AAAAAAAA"; B <= x"55555555";
wait for 10 ns;

---------------- OR TESTS ----------------
func <= "100101"; -- OR

A <= x"00000000"; B <= x"FFFFFFFF";
wait for 10 ns;

A <= x"12345678"; B <= x"87654321";
wait for 10 ns;

A <= x"AAAAAAAA"; B <= x"55555555";
wait for 10 ns;

---------------- SLT TESTS ----------------
func <= "101010"; -- SLT

A <= x"00000002"; B <= x"00000005"; -- true
wait for 10 ns;

A <= x"00000009"; B <= x"00000003"; -- false
wait for 10 ns;

A <= x"FFFFFFFF"; B <= x"00000001"; -- negative < positive
wait for 10 ns;

wait;

end process;

end behavior;