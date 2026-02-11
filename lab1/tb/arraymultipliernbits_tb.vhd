----------------------------------------------------------------------
-- Name: arraymultiplier_tb.vhd
-- Description: Testbench for 9-bit generic array multiplier
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY arraymultipliernbits_tb IS
END arraymultipliernbits_tb;

ARCHITECTURE tb OF arraymultipliernbits_tb IS

    CONSTANT bits : positive := 9;

    SIGNAL i_M       : std_logic_vector(bits-1 DOWNTO 0);
    SIGNAL i_Q       : std_logic_vector(bits-1 DOWNTO 0);
    SIGNAL o_product : std_logic_vector(2*bits-1 DOWNTO 0);

BEGIN

    ------------------------------------------------------------------
    -- DUT Instantiation (Generic = 9 bits)
    ------------------------------------------------------------------
    DUT: ENTITY work.arraymultiplier
        GENERIC MAP(
            bits => bits
        )
        PORT MAP(
            i_M       => i_M,
            i_Q       => i_Q,
            o_product => o_product
        );

    ------------------------------------------------------------------
    -- Stimulus Process
    ------------------------------------------------------------------
    stim_proc: PROCESS
        VARIABLE expected : unsigned(2*bits-1 DOWNTO 0);
    BEGIN

        ------------------------------------------------------------------
        -- Test 1: Zero case
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(0, bits));
        i_Q <= std_logic_vector(to_unsigned(173, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(0, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test1 FAIL" SEVERITY ERROR;

        ------------------------------------------------------------------
        -- Test 2: 10 * 25 = 250
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(10, bits));
        i_Q <= std_logic_vector(to_unsigned(25, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(10*25, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test2 FAIL" SEVERITY ERROR;

        ------------------------------------------------------------------
        -- Test 3: 100 * 7 = 700
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(100, bits));
        i_Q <= std_logic_vector(to_unsigned(7, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(100*7, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test3 FAIL" SEVERITY ERROR;

        ------------------------------------------------------------------
        -- Test 4: 42 * 17 = 714
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(42, bits));
        i_Q <= std_logic_vector(to_unsigned(17, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(42*17, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test4 FAIL" SEVERITY ERROR;

        ------------------------------------------------------------------
        -- Test 5: 200 * 50 = 10000
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(200, bits));
        i_Q <= std_logic_vector(to_unsigned(50, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(200*50, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test5 FAIL" SEVERITY ERROR;

        ------------------------------------------------------------------
        -- Test 6: Max case (511 * 511)
        -- 511 is max for 9 bits
        -- 511 * 511 = 261121
        ------------------------------------------------------------------
        i_M <= std_logic_vector(to_unsigned(511, bits));
        i_Q <= std_logic_vector(to_unsigned(511, bits));
        WAIT FOR 10 ns;

        expected := to_unsigned(511*511, 2*bits);
        ASSERT unsigned(o_product) = expected
            REPORT "Test6 FAIL (Max case)" SEVERITY ERROR;

        ------------------------------------------------------------------
        REPORT "All 9-bit multiplier tests PASSED" SEVERITY NOTE;
        WAIT;

    END PROCESS;

END tb;
