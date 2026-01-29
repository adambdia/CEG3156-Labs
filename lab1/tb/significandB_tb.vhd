library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity significandB_tb is
end significandB_tb;

architecture sim of significandB_tb is

    constant bits : integer := 9;

    -- Signals
    signal i_clk       : std_logic := '0';
    signal i_rstBar    : std_logic := '1';
    signal i_ld        : std_logic := '0';
    signal i_mux_select: std_logic_vector(1 downto 0) := "00";
    signal i_mantissaB : std_logic_vector(bits-2 downto 0) := (others => '0');
    signal i_significandA : std_logic_vector(bits-1 downto 0) := (others => '0');
    signal o_significandB : std_logic_vector(bits-1 downto 0);

begin

    -- Clock generation
    clk_proc : process
    begin
        while true loop
            i_clk <= '0';
            wait for 5 ns;
            i_clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Instantiate DUT
    dut: entity work.significandB
        generic map(bits => bits)
        port map(
            i_rstBar => i_rstBar,
            i_clk => i_clk,
            i_mantissaB => i_mantissaB,
            i_significandA => i_significandA,
            i_ld => i_ld,
            i_mux_select => i_mux_select,
            o_significandB => o_significandB
        );

    -- Test process
    test_proc: process
    begin
        -- Reset
        i_rstBar <= '0';
        wait for 10 ns;
        i_rstBar <= '1';
        wait for 10 ns;

        -- Test all mux_select values with ld = '1'
        i_mantissaB <= "01010101"; -- example value
        i_significandA <= "111100000"; -- example value
        i_ld <= '1';

        for sel in 0 to 3 loop
            i_mux_select <= std_logic_vector(to_unsigned(sel, 2));
            wait for 10 ns;
        end loop;

        i_ld <= '0'; -- Turn off load
        wait for 20 ns;

        -- Finish simulation
        wait;
    end process;

end sim;
