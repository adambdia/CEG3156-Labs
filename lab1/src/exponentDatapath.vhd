library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity exponentDatapath is
    generic(
        exponent_bits : positive := 7;
        mantissa_bits : positive := 8);
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_exponentA, i_exponentB    : in std_logic_vector(exponent_bits - 1 downto 0);
        i_ldA, i_ldB, i_ldOutput    : in std_logic;
        i_clrOutput                 : in std_logic;
        i_subtractExponent          : in std_logic;
        i_ldEdiff                   : in std_logic;
        i_swap                      : in std_logic;
        i_sel_adder_input1          : in std_logic_vector(1 downto 0);
        i_sel_adder_input2          : in std_logic;
        i_selOutput                 : in std_logic;
        o_exponentOut               : out std_logic_vector(exponent_bits - 1 downto 0);
        o_exponentA, o_exponentB    : out std_logic_vector(exponent_bits-1 downto 0);
        flag_GT_MAX_EDIFF           : out std_logic;
        flag_zero_Ediff             : out std_logic
    );
end exponentDatapath;

architecture rtl of exponentDatapath is
    signal int_exponentA, int_exponentB     : std_logic_vector(exponent_bits-1 downto 0);
    signal int_adder_result, int_Ediff      : std_logic_vector(exponent_bits-1 downto 0);
    signal int_adder1, int_adder2           : std_logic_vector(exponent_bits-1 downto 0);
    signal int_exponentOut                  : std_logic_vector(exponent_bits-1 downto 0);
    constant MAX_EDIFF : std_logic_vector(exponent_bits-1 downto 0) := std_logic_vector(to_unsigned(mantissa_bits, exponent_bits));
    constant CONST_1 : std_logic_vector(exponent_bits-1 downto 0) := std_logic_vector(to_unsigned(1,exponent_bits));
begin
    exponent_A: entity work.exponent
    generic map (
      bits => exponent_bits
    )
    port map (
      i_rstBAR       => i_rstBAR,
      i_clk          => i_clk,
      i_exponent1    => i_exponentA,
      i_exponent2    => int_exponentB,
      i_mux_select   => i_swap,
      i_ld           => i_ldA,
      o_exponent     => int_exponentA
    );

    exponent_B: entity work.exponent
    generic map (
      bits => 7
    )
    port map (
      i_rstBAR       => i_rstBAR,
      i_clk          => i_clk,
      i_exponent1    => i_exponentB,
      i_exponent2    => int_exponentA,
      i_mux_select   => i_swap,
      i_ld           => i_ldB,
      o_exponent     => int_exponentB
    );

    adder_input1: entity work.mux3x1nbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a   => int_exponentA,
      i_b   => int_Ediff,
      i_c   => int_exponentOut,
      i_sel => i_sel_adder_input1,
      o_out => int_adder1
    );


    adder_input2: entity work.mux2x1nbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a   => int_exponentB,
      i_b   => CONST_1,
      i_sel => i_sel_adder_input2,
      o_out => int_adder2
    );
    exponent_Adder: entity work.fulladdernbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a        => int_adder1,
      i_b        => int_adder2,
      i_carry    => '0',
      i_subtract => i_subtractExponent,
      o_sum      => int_adder_result,
      o_carry    => OPEN
    );

    Ediff: entity work.piponbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_in     => int_adder_result,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ldEdiff,
      o_out    => int_Ediff
    );
    Ediff_size_comparator: entity work.comparatornbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_A  => int_Ediff,
      i_B  => MAX_EDIFF,
      o_GT => flag_GT_MAX_EDIFF,
      o_LT => open,
      o_EQ => open
    );
    zero_flag_inst: entity work.zero_flag
    generic map (
      WIDTH => exponent_bits
    )
    port map (
      i_data      => int_Ediff,
      o_zero_flag => flag_zero_Ediff
    );

    exponentoutput_inst: entity work.exponentOutput
    generic map (
      bits => exponent_bits
    )
    port map (
      i_rstBAR         => i_rstBAR,
      i_clk            => i_clk,
      i_input          => int_adder_result,
      i_ld             => i_ldOutput,
      i_clr            => i_clrOutput,
      o_exponentOutput => int_exponentOut
    );


    mux2x1nbit_inst: entity work.mux2x1nbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a   => int_exponentA,
      i_b   => int_exponentOut,
      i_sel => i_selOutput,
      o_out => o_exponentOut
    );
    -- Output driver
    o_exponentA <= int_exponentA;
    o_exponentB <= int_exponentB;

end rtl;