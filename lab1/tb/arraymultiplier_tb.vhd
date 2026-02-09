-- Name: arraymultiplier_tb.vhd
-- Description: Testbench for 8-bit array multiplier (new test vectors)

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY arraymultiplier_tb IS
END arraymultiplier_tb;

ARCHITECTURE tb OF arraymultiplier_tb IS

    SIGNAL i_M       : std_logic_vector(7 DOWNTO 0);
    SIGNAL i_Q       : std_logic_vector(7 DOWNTO 0);
    SIGNAL o_product : std_logic_vector(15 DOWNTO 0);

BEGIN

    DUT: ENTITY work.arraymultiplier8bit
        PORT MAP(
            i_M      => i_M,
            i_Q      => i_Q,
            o_product => o_product
        );

    stim_proc: PROCESS
        VARIABLE expected : unsigned(15 DOWNTO 0);
    BEGIN
        -- Test 1: Zero case
        i_M <= x"00"; i_Q <= x"AB"; WAIT FOR 10 ns;
        expected := x"0000"; ASSERT o_product = std_logic_vector(expected) REPORT "Test1 FAIL" SEVERITY ERROR;

        -- Test 2: 10 * 25 = 250 (0xFA)
        i_M <= x"0A"; i_Q <= x"19"; WAIT FOR 10 ns;
        expected := x"00FA"; ASSERT o_product = std_logic_vector(expected) REPORT "Test2 FAIL" SEVERITY ERROR;

        -- Test 3: 100 * 7 = 700 (0x02BC)
        i_M <= x"64"; i_Q <= x"07"; WAIT FOR 10 ns;
        expected := x"02BC"; ASSERT o_product = std_logic_vector(expected) REPORT "Test3 FAIL" SEVERITY ERROR;

        -- Test 4: 42 * 17 = 714 (0x02CA)
        i_M <= x"2A"; i_Q <= x"11"; WAIT FOR 10 ns;
        expected := x"02CA"; ASSERT o_product = std_logic_vector(expected) REPORT "Test4 FAIL" SEVERITY ERROR;

        -- Test 5: 200 * 50 = 10000 (0x2710)
        i_M <= x"C8"; i_Q <= x"32"; WAIT FOR 10 ns;
        expected := x"2710"; ASSERT o_product = std_logic_vector(expected) REPORT "Test5 FAIL" SEVERITY ERROR;

        -- Test 6: Max: 255 * 255 = 65025 (0xFE01)
        i_M <= x"FF"; i_Q <= x"FF"; WAIT FOR 10 ns;
        expected := x"FE01"; ASSERT o_product = std_logic_vector(expected) REPORT "Test6 FAIL" SEVERITY ERROR;

        REPORT "All multiplier tests PASSED" SEVERITY NOTE;
        WAIT;
    END PROCESS;

END tb;
