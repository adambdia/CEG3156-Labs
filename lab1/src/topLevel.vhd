library ieee;
use ieee.std_logic_1164.all;

entity topLevel is
    generic (
        mantissa_bits : positive := 8;
        exponent_bits : positive := 7
    );
    port (
        -- Global
        i_rstBAR  : in  std_logic;
        i_clk     : in  std_logic;

        -- External inputs
        i_signA, i_signB      : in std_logic;
        i_mantissaA           : in std_logic_vector(mantissa_bits-1 downto 0);
        i_mantissaB           : in std_logic_vector(mantissa_bits-1 downto 0);
        i_exponentA           : in std_logic_vector(exponent_bits-1 downto 0);
        i_exponentB           : in std_logic_vector(exponent_bits-1 downto 0);

        -- Final outputs
        o_signOutput          : out std_logic;
        o_mantissaOutput     : out std_logic_vector(mantissa_bits-1 downto 0);
        o_exponentOutput     : out std_logic_vector(exponent_bits-1 downto 0)
    );
end topLevel;

architecture rtl of topLevel is
    -- =========================
    -- Control signals
    -- =========================
    signal control_swap                 : std_logic;
    signal control_selOutput            : std_logic;
    signal control_ldsign               : std_logic;

    signal control_ldA_significand      : std_logic;
    signal control_ldB_significand      : std_logic;
    signal control_ldOutput_significand : std_logic;
    signal control_shiftR_B             : std_logic;
    signal control_shiftL_output        : std_logic;

    signal control_ldA_exponent         : std_logic;
    signal control_ldB_exponent         : std_logic;
    signal control_ldOutput_exponent    : std_logic;
    signal control_clrOutput_exponent   : std_logic;
    signal control_subtractExponent     : std_logic;
    signal control_ldEdiff              : std_logic;
    signal control_sel_adder_input2     : std_logic;
    signal control_sel_adder_input1     : std_logic_vector(1 downto 0);

    -- =========================
    -- Flags
    -- =========================
    signal flag_zero_significandOutput  : std_logic;
    signal flag_MSB_significandOutput   : std_logic;
    signal flag_zero_B                  : std_logic;
    signal flag_GT_MAX_EDIFF            : std_logic;
    signal flag_zero_Ediff              : std_logic;
    signal flag_B_GT_A                  : std_logic;

    -- Unused but required datapath outputs
    signal o_significandOutput          : std_logic_vector(mantissa_bits+1 downto 0);
begin
    -- =========================
    -- Controlpath
    -- =========================
    control_inst: entity work.Controlpath
        port map (
            i_rstBAR => i_rstBAR,
            i_clk    => i_clk,

            flag_zero_significandOutput => flag_zero_significandOutput,
            flag_MSB_significandOutput  => flag_MSB_significandOutput,
            flag_zero_B                 => flag_zero_B,
            flag_GT_MAX_EDIFF           => flag_GT_MAX_EDIFF,
            flag_zero_Ediff             => flag_zero_Ediff,
            flag_B_GT_A                 => flag_B_GT_A,

            control_swap                => control_swap,
            control_selOutput           => control_selOutput,
            control_ldsign              => control_ldsign,
            control_ldA_significand     => control_ldA_significand,
            control_ldB_significand     => control_ldB_significand,
            control_ldOutput_significand=> control_ldOutput_significand,
            control_shiftR_B            => control_shiftR_B,
            control_shiftL_output       => control_shiftL_output,
            control_ldA_exponent        => control_ldA_exponent,
            control_ldB_exponent        => control_ldB_exponent,
            control_ldOutput_exponent   => control_ldOutput_exponent,
            control_clrOutput_exponent  => control_clrOutput_exponent,
            control_subtractExponent    => control_subtractExponent,
            control_ldEdiff             => control_ldEdiff,
            control_sel_adder_input2    => control_sel_adder_input2,
            control_sel_adder_input1    => control_sel_adder_input1
        );

    -- =========================
    -- Datapath
    -- =========================
    datapath_inst: entity work.fullDatapath
        generic map (
            mantissa_bits => mantissa_bits,
            exponent_bits => exponent_bits
        )
        port map (
            i_rstBAR => i_rstBAR,
            i_clk    => i_clk,
            i_swap   => control_swap,
            i_selOutput => control_selOutput,

            i_signA => i_signA,
            i_signB => i_signB,
            i_ldsign => control_ldsign,

            i_mantissaA => i_mantissaA,
            i_mantissaB => i_mantissaB,
            i_ldA_significand => control_ldA_significand,
            i_ldB_significand => control_ldB_significand,
            i_ldOutput_significand => control_ldOutput_significand,
            i_shiftR_B => control_shiftR_B,
            i_shiftL_output => control_shiftL_output,

            i_exponentA => i_exponentA,
            i_exponentB => i_exponentB,
            i_ldA_exponent => control_ldA_exponent,
            i_ldB_exponent => control_ldB_exponent,
            i_ldOutput_exponent => control_ldOutput_exponent,
            i_clrOutput => control_clrOutput_exponent,
            i_subtractExponent => control_subtractExponent,
            i_ldEdiff => control_ldEdiff,
            i_sel_adder_input2 => control_sel_adder_input2,
            i_sel_adder_input1 => control_sel_adder_input1,

            o_signOutput => o_signOutput,
            o_significandOutput => o_significandOutput,
            o_mantissaOutput => o_mantissaOutput,
            o_exponentOut => o_exponentOutput,

            flag_zero_significandOutput => flag_zero_significandOutput,
            flag_MSB_significandOutput  => flag_MSB_significandOutput,
            flag_zero_B                 => flag_zero_B,
            flag_GT_MAX_EDIFF           => flag_GT_MAX_EDIFF,
            flag_zero_Ediff             => flag_zero_Ediff,
            flag_B_GT_A                 => flag_B_GT_A
        );
end rtl;
