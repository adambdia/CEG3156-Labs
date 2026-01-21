----------------------------------------------------------------------
-- Testbench: adder_tb
-- Description: Verifies 16-bit Adder/Subtractor with Carry Input
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adder_tb IS
END adder_tb;

ARCHITECTURE behavior OF adder_tb IS

    -- 1. Constants
    CONSTANT c_width : INTEGER := 16;
    
    -- 2. Signals
    SIGNAL s_a        : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_b        : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_carry_in : std_logic := '0'; -- New signal for your new port
    SIGNAL s_subtract : std_logic := '0';
    SIGNAL s_sum      : std_logic_vector(c_width-1 DOWNTO 0);
    SIGNAL s_carry_out: std_logic;

BEGIN

    -- 3. Instantiate the DUT
    -- Using "entity work." prevents binding errors
    uut: entity work.fulladdernbit
        GENERIC MAP (
            bits => c_width
        )
        PORT MAP (
            i_a        => s_a,
            i_b        => s_b,
            i_carry    => s_carry_in, -- Connect new port
            i_subtract => s_subtract,
            o_sum      => s_sum,
            o_carry    => s_carry_out
        );

    -- 4. Stimulus Process
    p_stimulus: PROCESS
    BEGIN
        REPORT "--- Starting Adder/Subtractor Test ---";

        -- =========================================================
        -- TEST 1: Standard Addition (25 + 10)
        -- i_carry = 0, i_subtract = 0
        -- =========================================================
        s_a        <= std_logic_vector(to_unsigned(25, c_width));
        s_b        <= std_logic_vector(to_unsigned(10, c_width));
        s_carry_in <= '0';
        s_subtract <= '0';
        
        WAIT FOR 10 ns;
        
        ASSERT unsigned(s_sum) = 35
            REPORT "Error T1: 25 + 10 != 35" SEVERITY ERROR;
            
        REPORT "T1 (Add): 25 + 10 = " & integer'image(to_integer(unsigned(s_sum)));


        -- =========================================================
        -- TEST 2: Addition with Carry In (25 + 10 + 1)
        -- i_carry = 1, i_subtract = 0
        -- =========================================================
        s_a        <= std_logic_vector(to_unsigned(25, c_width));
        s_b        <= std_logic_vector(to_unsigned(10, c_width));
        s_carry_in <= '1'; -- Inject Carry
        s_subtract <= '0';
        
        WAIT FOR 10 ns;
        
        ASSERT unsigned(s_sum) = 36
            REPORT "Error T2: 25 + 10 + 1 != 36" SEVERITY ERROR;

        REPORT "T2 (Add+Cin): 25 + 10 + 1 = " & integer'image(to_integer(unsigned(s_sum)));


        -- =========================================================
        -- TEST 3: Standard Subtraction (50 - 20)
        -- i_carry = 0, i_subtract = 1
        -- Your logic: int_carry(0) <= i_carry or i_subtract
        -- This ensures the +1 for 2's complement happens automatically
        -- =========================================================
        s_a        <= std_logic_vector(to_unsigned(50, c_width));
        s_b        <= std_logic_vector(to_unsigned(20, c_width));
        s_carry_in <= '0';
        s_subtract <= '1';
        
        WAIT FOR 10 ns;
        
        ASSERT unsigned(s_sum) = 30
            REPORT "Error T3: 50 - 20 != 30" SEVERITY ERROR;

        REPORT "T3 (Sub): 50 - 20 = " & integer'image(to_integer(unsigned(s_sum)));


        -- =========================================================
        -- TEST 4: Negative Result (10 - 20)
        -- Should result in -10 (or 65526 / 0xFFF6 in unsigned 16-bit)
        -- =========================================================
        s_a        <= std_logic_vector(to_unsigned(10, c_width));
        s_b        <= std_logic_vector(to_unsigned(20, c_width));
        s_subtract <= '1';
        s_carry_in <= '0';
        
        WAIT FOR 10 ns;
        
        ASSERT s_sum = x"FFF6"
            REPORT "Error T4: 10 - 20 failed (Expected 0xFFF6)" SEVERITY ERROR;

        REPORT "T4 (Negative): 10 - 20 = " & integer'image(to_integer(signed(s_sum)));

        
        -- =========================================================
        -- TEST 5: Verify Carry/Subtract Priority
        -- Check if i_subtract forces the internal carry high
        -- even if i_carry is 0 (Your logic: i_carry OR i_subtract)
        -- =========================================================
        -- 100 - 50 = 50. 
        -- If the logic was wrong and carry-in stayed 0, 
        -- result would be 49 (1's complement).
        s_a        <= std_logic_vector(to_unsigned(100, c_width));
        s_b        <= std_logic_vector(to_unsigned(50, c_width));
        s_subtract <= '1';
        s_carry_in <= '0'; 
        
        WAIT FOR 10 ns;
        
        ASSERT unsigned(s_sum) = 50
            REPORT "Error T5: Subtraction logic for Carry-In failed" SEVERITY ERROR;
            
        REPORT "T5 (Logic Check): Subtraction correctly forced Carry-In high.";

        
        REPORT "--- Simulation Complete ---";
        WAIT; 
    END PROCESS;

END behavior;