----------------------------------------------------------------------
-- Testbench: mux32x1nbit_tb
-- Target: GHDL / VHDL-93
-- Description: Tests the 32x1 N-bit Mux by mapping unique values 
--              to each input and verifying the output at each select.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mux32x1nbit_tb IS
END mux32x1nbit_tb;

ARCHITECTURE behavior OF mux32x1nbit_tb IS

    -- Generic width for the test
    CONSTANT g_bits : POSITIVE := 8;

    -- Signal declarations
    -- Using an array-like signal list for easier stimulus in the process
    TYPE t_input_array IS ARRAY (0 TO 31) OF std_logic_vector(g_bits-1 DOWNTO 0);
    SIGNAL s_inputs : t_input_array;
    
    SIGNAL s_sel    : std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_out    : std_logic_vector(g_bits-1 DOWNTO 0);

BEGIN

    -- Direct Instantiation of the 32x1 Mux
    uut: entity work.mux32x1nbit(structural)
        GENERIC MAP (bits => g_bits)
        PORT MAP (
            i_0 => s_inputs(0),   i_1 => s_inputs(1),   i_2 => s_inputs(2),   i_3 => s_inputs(3),
            i_4 => s_inputs(4),   i_5 => s_inputs(5),   i_6 => s_inputs(6),   i_7 => s_inputs(7),
            i_8 => s_inputs(8),   i_9 => s_inputs(9),   i_10 => s_inputs(10), i_11 => s_inputs(11),
            i_12 => s_inputs(12), i_13 => s_inputs(13), i_14 => s_inputs(14), i_15 => s_inputs(15),
            i_16 => s_inputs(16), i_17 => s_inputs(17), i_18 => s_inputs(18), i_19 => s_inputs(19),
            i_20 => s_inputs(20), i_21 => s_inputs(21), i_22 => s_inputs(22), i_23 => s_inputs(23),
            i_24 => s_inputs(24), i_25 => s_inputs(25), i_26 => s_inputs(26), i_27 => s_inputs(27),
            i_28 => s_inputs(28), i_29 => s_inputs(29), i_30 => s_inputs(30), i_31 => s_inputs(31),
            i_sel => s_sel,
            o_out => s_out
        );

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        REPORT "Starting 32x1 N-bit Mux Testbench...";

        -- Step 1: Initialize all inputs with a unique value (index + offset)
        FOR i IN 0 TO 31 LOOP
            s_inputs(i) <= std_logic_vector(to_unsigned(i + 10, g_bits));
        END LOOP;
        WAIT FOR 10 ns;

        -- Step 2: Iterate through every selection and verify
        FOR i IN 0 TO 31 LOOP
            s_sel <= std_logic_vector(to_unsigned(i, 5));
            WAIT FOR 10 ns;
            
            -- Check if the output matches input(i)
            ASSERT (s_out = s_inputs(i))
                REPORT "FAILED at Select: " & integer'image(i) & 
                       " Expected: " & integer'image(i + 10) & 
                       " Got: " & integer'image(to_integer(unsigned(s_out)))
                SEVERITY ERROR;
                
            IF s_out = s_inputs(i) THEN
                REPORT "PASSED: Select " & integer'image(i) SEVERITY NOTE;
            END IF;
        END LOOP;

        REPORT "32x1 Mux Verification Complete.";
        WAIT;
    END PROCESS;

END behavior;