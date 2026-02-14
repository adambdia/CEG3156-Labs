library ieee;
use ieee.std_logic_1164.all;

entity topLevelMultiplier is
    generic(
        exponent_bits : positive := 7;
        mantissa_bits : positive := 8
    );
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_signA, i_signB            : in std_logic;
        i_exponentA, i_exponentB    : in std_logic_vector(exponent_bits-1 downto 0);
        i_mantissaA, i_mantissaB    : in std_logic_vector(mantissa_bits-1 downto 0);
        o_signOutput                : out std_logic;
        o_exponentOutput            : out std_logic_vector(exponent_bits-1 downto 0);
        o_mantissaOutput            : out std_logic_vector(mantissa_bits-1 downto 0)
    );
end topLevelMultiplier;

architecture rtl of topLevelMultiplier is
    signal control_ldInputs, control_clrOutput  : std_logic;
    signal control_ldSignficandOutput           : std_logic;
    signal control_ldExponentOutput             : std_logic;
    signal control_subtract_exponent            : std_logic;
    signal control_shift_significandOutput      : std_logic;
    signal sel_adder_input1                     : std_logic;
    signal sel_adder_input2                     : std_logic_vector(1 downto 0);
    signal status_significandMSB, status_input_0: std_logic;

begin
    datapathmultiplier_inst: entity work.DatapathMultiplier
    generic map (
      mantissa_bits => mantissa_bits,
      exponent_bits => exponent_bits
    )
    port map (
      i_rstBAR                 => i_rstBAR,
      i_clk                    => i_clk,
      i_mantissaA              => i_mantissaA,
      i_mantissaB              => i_mantissaB,
      i_exponentA              => i_exponentA,
      i_exponentB              => i_exponentB,
      i_signA                  => i_signA,
      i_signB                  => i_signB,
      i_ldInputs               => control_ldInputs,
      o_mantissaOutput         => o_mantissaOutput,
      o_exponentOutput         => o_exponentOutput,
      o_signOutput             => o_signOutput,
      i_ldSignificandOutput    => control_ldSignficandOutput,
      i_clrSignificandOutput   => control_clrOutput,
      i_shiftSignificandOutput => control_shift_significandOutput,
      i_sel_adder_input1       => sel_adder_input1,
      i_sel_adder_input2       => sel_adder_input2,
      control_subtract         => control_subtract_exponent,
      i_ldExponentOutput       => control_ldExponentOutput,
      i_clrExponentOutput      => control_clrOutput,
      status_significandMSB    => status_significandMSB,
      status_input_0           => status_input_0
    );

    controlpathmultiplier_inst: entity work.ControlPathMultiplier
    port map (
      i_rstBAR                        => i_rstBAR,
      i_clk                           => i_clk,
      status_significandMSB           => status_significandMSB,
      status_input_0                  => status_input_0,
      control_ldInputs                => control_ldInputs,
      control_clrOutput               => control_clrOutput,
      control_ldSignficandOutput      => control_ldSignficandOutput,
      control_ldExponentOutput        => control_ldExponentOutput,
      control_subtract_exponent       => control_subtract_exponent,
      control_shift_significandOutput => control_shift_significandOutput,
      sel_adder_input1                => sel_adder_input1,
      sel_adder_input2                => sel_adder_input2
    );
end rtl;