library ieee;
use ieee.std_logic_1164.all;

entity fullDatapath is
    generic(
        mantissa_bits : positive := 8;
        exponent_bits    : positive := 7
    );
    port(
        -- Universal inputs
        i_rstBAR, i_clk, i_swap         : in std_logic;
        i_selOutput                     : in std_logic;

        i_signA, i_signB                : in std_logic;

        -- SignDatapath inputs
        i_ldsign                        : in std_logic;
        -- SignificandDatapath Inputs
        i_mantissaA, i_mantissaB        : in std_logic_vector(mantissa_bits-1 downto 0);
        i_ldA_significand, i_ldB_significand, i_ldOutput_significand        : in std_logic;
        i_shiftR_B              : in std_logic;
        i_shiftL_output         : in std_logic;

        -- ExponentDatapath Inputs
        i_exponentA, i_exponentB        : in std_logic_vector(exponent_bits-1 downto 0);
        i_ldA_exponent, i_ldB_exponent  : in std_logic;
        i_ldOutput_exponent             : in std_logic;
        i_clrOutput, i_subtractExponent : in std_logic;
        i_ldEdiff, i_sel_adder_input2   : in std_logic;
        i_sel_adder_input1              : in std_logic_vector(1 downto 0);

        -- SignDatapath Output
        o_signOutput                    : out std_logic;

        -- SignificandDatapath Outputs
        o_significandOutput             : out std_logic_vector(mantissa_bits+1 downto 0);
        o_mantissaOutput                : out std_logic_vector(mantissa_bits-1 downto 0);
        
        -- ExponentDatapath Outputs
        o_exponentOut                   : out std_logic_vector(exponent_bits-1 downto 0);
 
        -- SignificandDatapath Flags
        flag_zero_significandOutput     : out std_logic;
        flag_MSB_significandOutput      : out std_logic;

        -- ExponentDatapath Flags
        flag_GT_MAX_EDIFF               : out std_logic;
        flag_zero_Ediff                 : out std_logic;

        -- Comparator Flags (B > A)
        flag_B_GT_A                     : out std_logic

    );
end fullDatapath;

architecture rtl of fullDatapath is
    signal int_subtractSignificand              : std_logic;
    signal int_mantissaA, int_mantissaB         : std_logic_vector(mantissa_bits-1 downto 0);
    signal int_exponentA, int_exponentB         : std_logic_vector(exponent_bits-1 downto 0);

    signal int_A, int_B                         : std_logic_vector(mantissa_bits+exponent_bits-1 downto 0);
begin
    significanddatapath_inst: entity work.significandDatapath
    generic map (
      significand_bits => mantissa_bits+1
    )
    port map (
      i_rstBAR                    => i_rstBAR,
      i_clk                       => i_clk,
      i_mantissaA                 => i_mantissaA,
      i_mantissaB                 => i_mantissaB,
      i_ldA                       => i_ldA_significand,
      i_ldB                       => i_ldB_significand,
      i_ldOutput                  => i_ldOutput_significand,
      i_swap                      => i_swap,
      i_shiftR_B                  => i_shiftR_B,
      i_shiftL_output             => i_shiftL_output,
      i_subtractSignificand       => int_subtractSignificand,
      i_selOutput                 => i_selOutput,
      o_significandOutput         => o_significandOutput,
      o_mantissaA                 => int_mantissaA,
      o_mantissaB                 => int_mantissaB,
      o_mantissaOutput            => o_mantissaOutput,
      flag_zero_significandOutput => flag_zero_significandOutput,
      flag_MSB_significandOutput  => flag_MSB_significandOutput
    );

    exponentdatapath_inst: entity work.exponentDatapath
    generic map (
      exponent_bits => exponent_bits,
      mantissa_bits => mantissa_bits
    )
    port map (
      i_rstBAR           => i_rstBAR,
      i_clk              => i_clk,
      i_exponentA        => i_exponentA,
      i_exponentB        => i_exponentB,
      i_ldA              => i_ldA_exponent,
      i_ldB              => i_ldB_exponent,
      i_ldOutput         => i_ldOutput_exponent,
      i_clrOutput        => i_clrOutput,
      i_subtractExponent => i_subtractExponent,
      i_ldEdiff          => i_ldEdiff,
      i_swap             => i_swap,
      i_sel_adder_input1 => i_sel_adder_input1,
      i_sel_adder_input2 => i_sel_adder_input2,
      i_selOutput        => i_selOutput,
      o_exponentOut      => o_exponentOut,
      o_exponentA        => int_exponentA,
      o_exponentB        => int_exponentB,
      flag_GT_MAX_EDIFF  => flag_GT_MAX_EDIFF,
      flag_zero_Ediff    => flag_zero_Ediff
    );

    comparatornbit_inst: entity work.comparatornbit
    generic map (
      bits => mantissa_bits + exponent_bits
    )
    port map (
      i_A  => int_A,
      i_B  => int_B,
      o_GT => open,
      o_LT => flag_B_GT_A,
      o_EQ => open
    );

    signdatapath_inst: entity work.signDatapath
    port map (
      i_rstBAR   => i_rstBAR,
      i_clk      => i_clk,
      i_signA    => i_signA,
      i_signB    => i_signB,
      i_ldsign   => i_ldsign,
      i_swap     => i_swap,
      o_signA    => o_signOutput,
      o_signB    => open,
      o_subtract => int_subtractSignificand
    );


    -- Concurrent signals
    int_A <= int_exponentA & int_mantissaA;
    int_B <= int_exponentB & int_mantissaB;

    -- Output driver
end rtl;