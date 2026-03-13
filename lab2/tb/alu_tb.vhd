library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is

constant bits : integer := 32;

signal A, B : std_logic_vector(bits-1 downto 0);
signal ALUOP : std_logic_vector(1 downto 0) := "10";
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
    i_ALUOP  => ALUOP,
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

---------------- ALUOP = 00 (FORCED ADD) ----------------
ALUOP <= "00";

func <= "100000"; -- random func, should still ADD
A <= x"00000004"; B <= x"00000006";  -- result = 10
wait for 10 ns;

func <= "100101"; -- OR func but should ADD
A <= x"00000003"; B <= x"00000002";  -- result = 5
wait for 10 ns;

func <= "101010"; -- SLT func but should ADD
A <= x"FFFFFFFF"; B <= x"00000001";  -- result = 0
wait for 10 ns;


---------------- ALUOP = 01 (FORCED SUB) ----------------
ALUOP <= "01";

func <= "100000"; -- ADD func but should SUB
A <= x"00000009"; B <= x"00000004";  -- result = 5
wait for 10 ns;

func <= "100100"; -- AND func but should SUB
A <= x"00000007"; B <= x"00000003";  -- result = 4
wait for 10 ns;

func <= "100101"; -- OR func but should SUB
A <= x"00000005"; B <= x"00000008";  -- result = -3
wait for 10 ns;

end process;

end behavior;