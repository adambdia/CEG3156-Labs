----------------------------------------------------------------------
-- Testbench for 16-bit PIPO Adder/Subtractor System
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Used for creating test values easily

ENTITY tb_adder_system IS
END tb_adder_system;

ARCHITECTURE behavior OF tb_adder_system IS

    -- 1. Component Declarations
    
    COMPONENT fulladdernbit IS
        GENERIC (bits : POSITIVE := 16);
        PORT (
            i_a        : IN  std_logic_vector(bits-1 DOWNTO 0);
            i_b        : IN  std_logic_vector(bits-1 DOWNTO 0);
            i_subtract : IN  std_logic;
            o_sum      : OUT std_logic_vector(bits-1 DOWNTO 0); -- Changed from IN to OUT
            o_carry    : OUT std_logic
        );
    END COMPONENT;

    COMPONENT nbitpipo IS
        GENERIC (bits : POSITIVE := 16);
        PORT (
            i_in     : IN  std_logic_vector(bits-1 DOWNTO 0);
            i_rstBAR : IN  std_logic;
            i_clk    : IN  std_logic;
            i_ld     : IN  std_logic;
            o_out    : OUT std_logic_vector(bits-1 DOWNTO 0)
        );
    END COMPONENT;

    -- 2. Constants and Signals
    CONSTANT c_width : INTEGER := 16;
    CONSTANT c_clk_period : TIME := 10 ns;

    -- Global Control
    SIGNAL s_clk    : std_logic := '0';
    SIGNAL s_rstBar : std_logic := '0';

    -- Data Inputs (from Testbench to Registers)
    SIGNAL s_tb_data_a : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_tb_data_b : std_logic_vector(c_width-1 DOWNTO 0) := (OTHERS => '0');

    -- Control Signals
    SIGNAL s_load_a      : std_logic := '0';
    SIGNAL s_load_b      : std_logic := '0';
    SIGNAL s_load_result : std_logic := '0';
    SIGNAL s_subtract    : std_logic := '0';

    -- Interconnect Wires
    SIGNAL w_reg_a_out : std_logic_vector(c_width-1 DOWNTO 0);
    SIGNAL w_reg_b_out : std_logic_vector(c_width-1 DOWNTO 0);
    SIGNAL w_sum_out   : std_logic_vector(c_width-1 DOWNTO 0);
    SIGNAL w_carry_out : std_logic;
    
    -- Final Output (from Result Register)
    SIGNAL w_final_result : std_logic_vector(c_width-1 DOWNTO 0);

BEGIN

    -- 3. Instantiate Components (Unit Under Test)

    -- Register A
    INST_REG_A: nbitpipo
    GENERIC MAP (bits => c_width)
    PORT MAP (
        i_in     => s_tb_data_a,
        i_rstBAR => s_rstBar,
        i_clk    => s_clk,
        i_ld     => s_load_a,
        o_out    => w_reg_a_out
    );

    -- Register B
    INST_REG_B: nbitpipo
    GENERIC MAP (bits => c_width)
    PORT MAP (
        i_in     => s_tb_data_b,
        i_rstBAR => s_rstBar,
        i_clk    => s_clk,
        i_ld     => s_load_b,
        o_out    => w_reg_b_out
    );

    -- The Full Adder
    -- Inputs come from Reg A and Reg B outputs
    INST_ADDER: fulladdernbit
    GENERIC MAP (bits => c_width)
    PORT MAP (
        i_a        => w_reg_a_out,
        i_b        => w_reg_b_out,
        i_subtract => s_subtract,
        o_sum      => w_sum_out,
        o_carry    => w_carry_out
    );

    -- Register Result
    -- Input comes from Adder Output
    INST_REG_RES: nbitpipo
    GENERIC MAP (bits => c_width)
    PORT MAP (
        i_in     => w_sum_out,
        i_rstBAR => s_rstBar,
        i_clk    => s_clk,
        i_ld     => s_load_result,
        o_out    => w_final_result
    );

    -- 4. Clock Generation Process
    p_clk_gen: PROCESS
    BEGIN
        s_clk <= '0';
        WAIT FOR c_clk_period/2;
        s_clk <= '1';
        WAIT FOR c_clk_period/2;
    END PROCESS;

    -- 5. Stimulus Process
    p_stimulus: PROCESS
    BEGIN
        -- === Reset Sequence ===
        REPORT "Starting Simulation...";
        s_rstBar <= '0'; -- Activate Reset (Active Low)
        WAIT FOR c_clk_period * 2;
        s_rstBar <= '1'; -- Release Reset
        WAIT FOR c_clk_period;

        -- === TEST 1: ADDITION (25 + 10) ===
        REPORT "Test 1: Addition (25 + 10)";
        
        -- 1. Setup Data on TB lines
        s_tb_data_a <= std_logic_vector(to_unsigned(25, c_width));
        s_tb_data_b <= std_logic_vector(to_unsigned(10, c_width));
        s_subtract  <= '0'; -- Mode: Add
        
        -- 2. Load Registers A and B
        s_load_a <= '1';
        s_load_b <= '1';
        WAIT FOR c_clk_period; -- Clock edge happens here
        s_load_a <= '0';
        s_load_b <= '0';
        
        -- Allow adder combinatorial delay (signals propagate through adder now)
        WAIT FOR c_clk_period; 
        
        -- 3. Load Result Register
        s_load_result <= '1';
        WAIT FOR c_clk_period; -- Clock edge latches the sum
        s_load_result <= '0';

        -- 4. Check Result
        -- 25 + 10 = 35 (0x0023)
        ASSERT unsigned(w_final_result) = 35 
            REPORT "Error: 25 + 10 should be 35" SEVERITY ERROR;


        -- === TEST 2: SUBTRACTION (50 - 20) ===
        REPORT "Test 2: Subtraction (50 - 20)";
        
        -- 1. Setup Data
        s_tb_data_a <= std_logic_vector(to_unsigned(50, c_width));
        s_tb_data_b <= std_logic_vector(to_unsigned(20, c_width));
        s_subtract  <= '1'; -- Mode: Subtract
        
        -- 2. Load Registers A and B
        s_load_a <= '1';
        s_load_b <= '1';
        WAIT FOR c_clk_period; 
        s_load_a <= '0';
        s_load_b <= '0';
        
        WAIT FOR c_clk_period; -- Wait for adder ripple
        
        -- 3. Load Result Register
        s_load_result <= '1';
        WAIT FOR c_clk_period; 
        s_load_result <= '0';

        -- 4. Check Result
        -- 50 - 20 = 30 (0x001E)
        -- NOTE: If your adder logic is missing the initial Carry In = 1 logic,
        -- this might result in 29.
        ASSERT unsigned(w_final_result) = 30 
            REPORT "Error: 50 - 20 should be 30" SEVERITY ERROR;


        -- === TEST 3: Overflow/Roll over Test (65535 + 1) ===
        REPORT "Test 3: Max Value + 1";
        
        s_tb_data_a <= x"FFFF"; -- 65535
        s_tb_data_b <= x"0001"; -- 1
        s_subtract  <= '0';
        
        s_load_a <= '1';
        s_load_b <= '1';
        WAIT FOR c_clk_period;
        s_load_a <= '0';
        s_load_b <= '0';
        
        WAIT FOR c_clk_period;
        
        s_load_result <= '1';
        WAIT FOR c_clk_period;
        s_load_result <= '0';
        
        -- Result should be 0 (16-bit wrap around)
        ASSERT unsigned(w_final_result) = 0
            REPORT "Error: FFFF + 1 should be 0 (in 16 bit)" SEVERITY ERROR;
            
        -- Carry out logic (if implemented in your adder)
        -- ASSERT w_carry_out = '1' REPORT "Error: Carry out failed" SEVERITY ERROR;

        REPORT "Simulation Complete";
        WAIT; -- Stop simulation
    END PROCESS;

END behavior;