library ieee;
use ieee.std_logic_1164.all;

entity significandOutput_tb is
end significandOutput_tb;

architecture tb of significandOutput_tb is

    constant bits : positive := 10;
    constant clk_period : time := 10 ns;

    signal i_rstBAR            : std_logic := '1';
    signal i_clk               : std_logic := '0';
    signal i_input, i_inputA   : std_logic_vector(bits-1 downto 0);
    signal i_ld                : std_logic;
    signal i_shiftL            : std_logic;
    signal i_ldA               : std_logic;
    signal o_significandOutput : std_logic_vector(bits-1 downto 0);
    signal flag_zero           : std_logic;

begin

    -- DUT instantiation
    dut: entity work.significandOutput
        generic map (bits => bits)
        port map (
            i_rstBAR            => i_rstBAR,
            i_clk               => i_clk,
            i_input             => i_input,
            i_inputA            => i_inputA,
            i_ld                => i_ld,
            i_shiftL            => i_shiftL,
            i_ldA               => i_ldA,
            o_significandOutput => o_significandOutput,
            flag_zero           => flag_zero
        );

    -- Clock generation
    clk_proc : process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period / 2;
            i_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Init values
        i_ld <= '0';
        i_shiftL <= '0';
        i_ldA <= '0';
        i_input <= (others => '0');
        i_inputA <= (others => '0');
        -- Reset
        i_rstBAR <= '0';
        wait for 20 ns;
        i_rstBAR <= '1';

        -- ==========================
        -- Load initial input value
        -- ==========================
        wait for 10 ns;
        i_input <= "0001000010"; -- 10-bit value
        i_inputA <= "1111100001";
        i_shiftL <= '0';
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==========================
        -- Shift left once
        -- ==========================
        wait for 20 ns;
        i_shiftL <= '1';
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==========================
        -- Shift left again
        -- ==========================
        wait for 20 ns;
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==========================
        -- Shift left one more time
        -- ==========================
        wait for 20 ns;
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        -- ==========================
        -- Load new input value
        -- ==========================
        wait for 20 ns;
        i_shiftL <= '0';
        i_input <= "0011110001";
        i_ld <= '1';
        wait for clk_period;
        i_ld <= '0';

        i_ldA <= '1';
        wait for clk_period;
        i_ldA <= '0';

        -- ==========================
        -- End simulation
        -- ==========================
        wait for 50 ns;
        report "Simulation finished successfully";
        wait;

    end process;

end tb;
