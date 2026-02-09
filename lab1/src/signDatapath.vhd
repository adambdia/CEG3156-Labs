library ieee;
use ieee.std_logic_1164.all;

entity signDatapath is
    port(
        i_rstBAR, i_clk         : in std_logic;
        i_signA, i_signB        : in std_logic;
        i_ldsign, i_swap        : in std_logic;
        o_signA, o_signB        : out std_logic;
        o_subtract              : out std_logic
    );
end signDatapath;

architecture rtl of signDatapath is
    signal int_signA_input, int_signB_input     : std_logic;
    signal int_signA_output, int_signB_output   : std_logic;
begin
    mux2x1_A: entity work.mux2x1
    port map (
      i_a   => i_signA,
      i_b   => int_signB_output,
      i_sel => i_swap,
      o_out => int_signA_input
    );

    mux2x1_B: entity work.mux2x1
    port map (
      i_a   => i_signB,
      i_b   => int_signA_output,
      i_sel => i_swap,
      o_out => int_signB_input
    );

    dff_ar_A: entity work.dff_ar
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_signA_input,
      i_enable   => i_ldsign,
      i_clock    => i_clk,
      o_q        => int_signA_output,
      o_qBar     => open
    );

    dff_ar_B: entity work.dff_ar
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_signB_input,
      i_enable   => i_ldsign,
      i_clock    => i_clk,
      o_q        => int_signB_output,
      o_qBar     => open
    );

    -- Output Drivers
    o_signA <= int_signA_output;
    o_signB <= int_signB_output;
    o_subtract <= int_signA_output xor int_signB_output;


end rtl;