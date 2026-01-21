----------------------------------------------------------------------
-- Testbench: mux4x1_tb
-- Description: Verifies N-bit 4x1 Multiplexer functionality
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux4x1_tb IS
END mux4x1_tb;

ARCHITECTURE behavior OF mux4x1_tb IS

    -- 1. Constants
    CONSTANT c_width : INTEGER := 8;
    
    -- 2. Signals
    SIGNAL s_a   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_b   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_c   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_d   : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL s_sel : std_logic_vector(1 DOWNTO 0) := "00";
    SIGNAL s_out : std_logic_vector(c_width-1 DOWNTO 0);

BEGIN

    -- 3. Instantiate the DUT
    uut: entity work.mux4x1nbit
        GENERIC MAP (
            bits => c_width
        )
        PORT MAP (
            i_a   => s_a,
            i_b   => s_b,
            i_c   => s_c,
            i_d   => s_d,
            i_sel => s_sel,
            o_out => s_out
        );

    -- 4. Stimulus Process
    p_stimulus: PROCESS
    BEGIN
        REPORT "--- Starting Mux 4x1 Test ---";

        -- Initialize Inputs with distinct patterns
        s_a <= x"AA"; -- 10101010
        s_b <= x"BB"; -- 10111011
        s_c <= x"CC"; -- 11001100
        s_d <= x"DD"; -- 11011101

        -- =========================================================
        -- TEST 1: Select A ("00")
        -- =========================================================
        s_sel <= "00";
        WAIT FOR 10 ns;
        ASSERT s_out = x"AA" 
            REPORT "Error T1: '00' did not select A" SEVERITY ERROR;
        REPORT "T1 ('00'): Select A passed.";

        -- =========================================================
        -- TEST 2: Select B ("01")
        -- =========================================================
        s_sel <= "01";
        WAIT FOR 10 ns;
        ASSERT s_out = x"BB" 
            REPORT "Error T2: '01' did not select B" SEVERITY ERROR;
        REPORT "T2 ('01'): Select B passed.";

        -- =========================================================
        -- TEST 3: Select C ("10")
        -- =========================================================
        s_sel <= "10";
        WAIT FOR 10 ns;
        ASSERT s_out = x"CC" 
            REPORT "Error T3: '10' did not select C" SEVERITY ERROR;
        REPORT "T3 ('10'): Select C passed.";

        -- =========================================================
        -- TEST 4: Select D ("11")
        -- =========================================================
        s_sel <= "11";
        WAIT FOR 10 ns;
        ASSERT s_out = x"DD" 
            REPORT "Error T4: '11' did not select D" SEVERITY ERROR;
        REPORT "T4 ('11'): Select D passed.";


        -- =========================================================
        -- TEST 5: Data Independence
        -- While D is selected, change A, B, and C. Output should stay D.
        -- =========================================================
        s_sel <= "11"; -- Ensure D is selected
        s_d   <= x"DD";
        WAIT FOR 5 ns;

        -- Change unselected inputs
        s_a <= x"00"; 
        s_b <= x"00"; 
        s_c <= x"00";
        
        WAIT FOR 5 ns;
        
        ASSERT s_out = x"DD"
            REPORT "Error T5: Output changed when unselected inputs changed!" SEVERITY ERROR;
        
        REPORT "T5 (Isolation): Passed.";
        
        REPORT "--- Simulation Complete ---";
        WAIT; 
    END PROCESS;

END behavior;