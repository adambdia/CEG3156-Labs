library ieee;
use ieee.std_logic_1164.all;

entity signDatapath_tb is
end signDatapath_tb;

architecture tb of signDatapath_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal i_rstBAR, i_clk, i_signA, i_signB, i_ldsign, i_swap : std_logic := '0';
    signal o_signA, o_signB, o_subtract     : std_logic;
begin
    clk_process : process
    begin
        loop
            i_clk <= '0';
            wait for CLK_PERIOD/2;
            i_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process clk_process;

    DUT: entity work.signDatapath
    port map (
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_signA  => i_signA,
      i_signB  => i_signB,
      i_ldsign => i_ldsign,
      i_swap   => i_swap,
      o_signA  => o_signA,
      o_signB  => o_signB,
      o_subtract => o_subtract
    );


    stim_proc: process
    begin
        i_rstBAR <= '0';
        i_signA <= '1';
        i_signB <= '0';
        wait for CLK_PERIOD;
        i_rstBAR <= '1';

        i_ldsign <= '1';
        wait for CLK_PERIOD;
        i_ldsign <= '0';

        wait for 2 * CLK_PERIOD;

        i_swap <= '1';
        i_ldsign <= '1';
        wait for CLK_PERIOD;
        i_swap <= '0';
        i_ldsign <= '0';

        wait for 2 * CLK_PERIOD;

        i_signA <= '1';
        i_signB <= '1';
        i_ldsign <= '1';
        wait for CLK_PERIOD;
        i_ldsign <= '0';

        wait;

    end process stim_proc;
end tb;

