----------------------------------------------------------------------
-- Testbench: register_file_tb
-- Target: GHDL / VHDL-93
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END register_file_tb;

ARCHITECTURE behavior OF register_file_tb IS

    CONSTANT clk_period : TIME := 10 ns;

    signal s_clk      : std_logic := '0';
    signal s_rstBAR   : std_logic := '0';
    signal s_regWrite : std_logic := '0';
    signal s_w_addr   : std_logic_vector(4 downto 0)  := (others => '0');
    signal s_w_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_r1_addr  : std_logic_vector(4 downto 0)  := (others => '0');
    signal s_r2_addr  : std_logic_vector(4 downto 0)  := (others => '0');
    signal s_r1_data  : std_logic_vector(31 downto 0);
    signal s_r2_data  : std_logic_vector(31 downto 0);

BEGIN

    uut: entity work.register_file(structural)
        PORT MAP (
            i_clk      => s_clk,
            i_rstBAR   => s_rstBAR,
            i_regWrite => s_regWrite,
            i_w_addr   => s_w_addr,
            i_w_data   => s_w_data,
            i_r1_addr  => s_r1_addr,
            i_r2_addr  => s_r2_addr,
            o_r1_data  => s_r1_data,
            o_r2_data  => s_r2_data
        );

    -- Clock Generation
    clk_process : process
    begin
        s_clk <= '0';
        wait for clk_period/2;
        s_clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- 1. Reset Phase
        s_rstBAR <= '0';
        s_regWrite <= '0';
        wait for clk_period * 2;
        s_rstBAR <= '1';
        wait for clk_period;

        -- 2. SETUP FOR DUAL PORT READ: Write data into Reg 5
        report "Writing to Reg 5...";
        s_w_addr   <= "00101"; 
        s_w_data   <= x"AAAA5555";
        s_regWrite <= '1';
        wait until rising_edge(s_clk); -- Data captured here
        
        -- 3. SETUP FOR DUAL PORT READ: Write data into Reg 31
        report "Writing to Reg 31...";
        s_w_addr   <= "11111"; 
        s_w_data   <= x"12345678";
        s_regWrite <= '1';
        wait until rising_edge(s_clk); -- Data captured here

        -- 4. PERFORM DUAL PORT READ
        -- Stop writing so we don't accidentally overwrite anything
        s_regWrite <= '0';
        
        -- Apply read addresses
        s_r1_addr  <= "00101"; -- Should see x"AAAA5555"
        s_r2_addr  <= "11111"; -- Should see x"12345678"
        
        -- Wait for the combinational mux propagation
        wait for 2 ns; 

        assert (s_r1_data = x"AAAA5555") 
            report "FAILED: Port 1 read Reg 5" severity error;
        assert (s_r2_data = x"12345678") 
            report "FAILED: Port 2 read Reg 31" severity error;
            
        if (s_r1_data = x"AAAA5555" and s_r2_data = x"12345678") then
            report "PASSED: Dual Port Read Achieved" severity note;
        end if;

        -- 5. TEST ENABLE LOGIC: Attempt write without RegWrite
        report "Testing Write Disable...";
        s_w_addr   <= "00101"; 
        s_w_data   <= x"00000000"; -- Attempt to clear Reg 5
        s_regWrite <= '0';         -- But enable is OFF
        wait until rising_edge(s_clk);
        
        wait for 2 ns;
        assert (s_r1_data = x"AAAA5555") 
            report "FAILED: Write enable logic (Reg 5 changed despite regWrite='0')" severity error;
        
        if (s_r1_data = x"AAAA5555") then
            report "PASSED: Write Enable Logic" severity note;
        end if;

        report "Simulation Finished.";
        wait;
    end process;

END behavior;