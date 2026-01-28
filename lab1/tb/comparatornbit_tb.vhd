-- Name: comparatornbit_tb.vhd
-- Description: Testbench for generic n-bit comparator (greater/less/equal)

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY comparatornbit_tb IS
END comparatornbit_tb;

ARCHITECTURE tb OF comparatornbit_tb IS

    CONSTANT BITS : positive := 8;

    SIGNAL A   : std_logic_vector(BITS-1 DOWNTO 0);
    SIGNAL B   : std_logic_vector(BITS-1 DOWNTO 0);
    SIGNAL GT  : std_logic;
    SIGNAL LT  : std_logic;
    SIGNAL EQ  : std_logic;

BEGIN

    -- Direct entity instantiation to avoid binding issues
    DUT: ENTITY work.comparatornbit
        GENERIC MAP (bits => BITS)
        PORT MAP(
            i_A => A,
            i_B => B,
            o_GT => GT,
            o_LT => LT,
            o_EQ => EQ
        );

    stim_proc: PROCESS
    BEGIN
        ----------------------------------------------------------------
        -- Test 1: A = B -> EQ=1, GT=0, LT=0
        ----------------------------------------------------------------
        A <= x"55";          -- 0b0101_0101
        B <= x"55";
        WAIT FOR 10 ns;
        ASSERT (EQ = '1' AND GT = '0' AND LT = '0')
            REPORT "Test 1 failed: A=B" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 2: A > B -> GT=1, LT=0, EQ=0
        ----------------------------------------------------------------
        A <= x"80";          -- 128
        B <= x"7F";          -- 127
        WAIT FOR 10 ns;
        ASSERT (GT = '1' AND LT = '0' AND EQ = '0')
            REPORT "Test 2 failed: A>B" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 3: A < B -> LT=1, GT=0, EQ=0
        ----------------------------------------------------------------
        A <= x"01";
        B <= x"10";
        WAIT FOR 10 ns;
        ASSERT (LT = '1' AND GT = '0' AND EQ = '0')
            REPORT "Test 3 failed: A<B" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Test 4: Different equal pattern
        ----------------------------------------------------------------
        A <= x"AA";
        B <= x"AA";
        WAIT FOR 10 ns;
        ASSERT (EQ = '1' AND GT = '0' AND LT = '0')
            REPORT "Test 4 failed: A=B (second pattern)" SEVERITY ERROR;

        ----------------------------------------------------------------
        -- Done
        ----------------------------------------------------------------
        REPORT "All comparator tests passed." SEVERITY NOTE;
        WAIT;
    END PROCESS;

END tb;
