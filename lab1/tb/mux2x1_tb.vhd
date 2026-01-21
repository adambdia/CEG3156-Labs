----------------------------------------------------------------------
-- Testbench: mux2x1_tb
-- Description: Verifies N-bit 2x1 Multiplexer functionality
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux2x1_tb IS
END mux2x1_tb;

ARCHITECTURE behavior OF mux2x1_tb IS

    -- 1. Constants
    -- We can test with 8 bits as defined in your generic default, 
    -- or change this to 16 to match your other components.
    CONSTANT c_width : INTEGER := 8;
    
    -- 2. Signals
    SIGNAL s_a   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_b   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_sel : std_logic := '0';
    SIGNAL s_out : std_logic_vector(c_width-1 DOWNTO 0);

BEGIN

    -- 3. Instantiate the DUT (Device Under Test)
    -- Using "entity work." to avoid binding errors
    uut: entity work.mux2x1nbit
        GENERIC MAP (
            bits => c_width
        )
        PORT MAP (
            i_a   => s_a,
            i_b   => s_b,
            i_sel => s_sel,
            o_out => s_out
        );

    -- 4. Stimulus Process
    p_stimulus: PROCESS
    BEGIN
        REPORT "--- Starting Mux 2x1 Test ---";

        -- =========================================================
        -- TEST 1: Select Input A (Sel = 0)
        -- Data: A = 0xAA (10101010), B = 0x55 (01010101)
        -- =========================================================
        s_a   <= x"AA";
        s_b   <= x"55";
        s_sel <= '0';
        
        WAIT FOR 10 ns;
        
        ASSERT s_out = x"AA"
            REPORT "Error T1: Sel=0 did not select Input A" SEVERITY ERROR;
            
        REPORT "T1 (Sel=0): Passed. Output = " & integer'image(to_integer(unsigned(s_out)));


        -- =========================================================
        -- TEST 2: Select Input B (Sel = 1)
        -- Data: A = 0xAA, B = 0x55
        -- =========================================================
        s_sel <= '1';
        
        WAIT FOR 10 ns;
        
        ASSERT s_out = x"55"
            REPORT "Error T2: Sel=1 did not select Input B" SEVERITY ERROR;

        REPORT "T2 (Sel=1): Passed. Output = " & integer'image(to_integer(unsigned(s_out)));


        -- =========================================================
        -- TEST 3: Check Data Independence
        -- Keep Sel=1 (Select B), change A. Output should NOT change.
        -- =========================================================
        s_a   <= x"FF"; -- Change A
        s_b   <= x"55"; -- Keep B same
        s_sel <= '1';
        
        WAIT FOR 10 ns;
        
        ASSERT s_out = x"55"
            REPORT "Error T3: Output changed when unselected input changed" SEVERITY ERROR;

        REPORT "T3 (Isolation): Passed. Changing A did not affect Output (since B is selected).";


        -- =========================================================
        -- TEST 4: Check Dynamic Switching
        -- Set A=00, B=FF. Toggle Sel back and forth.
        -- =========================================================
        s_a <= x"00";
        s_b <= x"FF";
        
        s_sel <= '0'; -- Select A (00)
        WAIT FOR 10 ns;
        ASSERT s_out = x"00" REPORT "Error T4a" SEVERITY ERROR;
        
        s_sel <= '1'; -- Select B (FF)
        WAIT FOR 10 ns;
        ASSERT s_out = x"FF" REPORT "Error T4b" SEVERITY ERROR;
        
        REPORT "T4 (Toggle): Passed.";

        
        REPORT "--- Simulation Complete ---";
        WAIT; 
    END PROCESS;

END behavior;