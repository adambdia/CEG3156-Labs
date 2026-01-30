library ieee;
use ieee.std_logic_1164.all;

entity significandDatapath is
    generic(bits : positive := 9);
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_mantissaA, i_mantissaB    : in std_logic_vector(bits-2 downto 0); -- size of bits-1
        i_ldA, i_ldB, i_ldOutput    : in std_logic;
        i_ldOutputA                 : in std_logic;
        i_swap                      : in std_logic;
        i_shiftR_B                  : in std_logic;
        i_shiftL_output             : in std_logic;
        i_subtractSignificand       : in std_logic;
        o_significandOutput         : out std_logic_vector(bits downto 0); -- size of bits+1
        flag_zero                   : out std_logic
    );
end significandDatapath;

architecture rtl of significandDatapath is
    signal int_mux_selectB                          : std_logic_vector(1 downto 0);
    signal int_significandA, int_significandB       : std_logic_vector(bits-1 downto 0);
    signal int_significandA_extended                : std_logic_vector(bits downto 0);
    signal int_significand_output                   : std_logic_vector(bits downto 0);
    signal int_adder_result                         : std_logic_vector(bits downto 0);
    signal int_adder_carryout                       : std_logic;
begin
    significanda_inst: entity work.significandA
    generic map (
      bits => bits
    )
    port map (
      i_rstBAR       => i_rstBAR,
      i_clk          => i_clk,
      i_mantissaA    => i_mantissaA,
      i_significandB => int_significandB,
      i_ld           => i_ldA,
      i_mux_select   => i_swap,
      o_significandA => int_significandA
    );

    significandb_inst: entity work.significandB
    generic map (
      bits => bits
    )
    port map (
      i_rstBAR       => i_rstBAR,
      i_clk          => i_clk,
      i_mantissaB    => i_mantissaB,
      i_significandA => int_significandA,
      i_ld           => i_ldB,
      i_mux_select   => int_mux_selectB,
      o_significandB => int_significandB
    );

    fulladdernbit_inst: entity work.fulladdernbit
    generic map (
      bits => bits
    )
    port map (
      i_a        => int_significandA,
      i_b        => int_significandB,
      i_carry    => '0',
      i_subtract => i_subtractSignificand,
      o_sum      => int_adder_result(bits-1 downto 0),
      o_carry    => int_adder_carryout
    );

    significandoutput_inst: entity work.significandOutput
    generic map (
      bits => bits+1
    )
    port map (
      i_rstBAR            => i_rstBAR,
      i_clk               => i_clk,
      i_input             => int_adder_result,
      i_inputA            => int_significandA_extended,
      i_ld                => i_ldOutput,
      i_shiftL            => i_shiftL_output,
      i_ldA               => i_ldOutputA,
      o_significandOutput => int_significand_output,
      flag_zero           => flag_zero
    );

    -- concurrent signal
    int_mux_selectB <= (i_shiftR_B and not i_swap) & i_swap;
    int_adder_result(bits) <= int_adder_carryout and (not i_subtractSignificand);
    int_significandA_extended <= int_significandA & '0';


    -- output driver
    o_significandOutput <= int_significand_output;
end rtl;