library ieee;
use ieee.std_logic_1164.all;

entity Controlpath is
    port(
        i_rstBAR, i_clk                 : in std_logic;
        -- SignificandDatapath Flags
        flag_zero_significandOutput     : in std_logic;
        flag_MSB_significandOutput      : in std_logic;

        -- ExponentDatapath Flags
        flag_GT_MAX_EDIFF               : in std_logic;
        flag_zero_Ediff                 : in std_logic;

        -- Comparator Flags (B > A)
        flag_B_GT_A                     : in std_logic;

        -- Control signals
        control_swap                          : out std_logic;
        control_selOutput                     : out std_logic;

        -- SignDatapath control signals
        control_ldsign                        : out std_logic;
        -- SignificandDatapath control signals
        control_ldA_significand               : out std_logic;
        control_ldB_significand               : out std_logic;
        control_ldOutput_significand          : out std_logic;
        control_shiftR_B                      : out std_logic;
        control_shiftL_output                 : out std_logic;

        -- ExponentDatapath control signals
        control_ldA_exponent                  : out std_logic;
        control_ldB_exponent                  : out std_logic;
        control_ldOutput_exponent             : out std_logic;
        control_clrOutput_exponent                     : out std_logic;
        control_subtractExponent              : out std_logic;
        control_ldEdiff                       : out std_logic;
        control_sel_adder_input2              : out std_logic;
        control_sel_adder_input1              : out std_logic_vector(1 downto 0)
    );
end Controlpath;

architecture rtl of Controlpath is
    signal int_SInput, int_sOutput            : std_logic_vector(8 downto 0);
begin
    dff_as_inst: entity work.dff_as
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_SInput(0),
      i_enable   => '1',
      i_clock    => i_clk,
      o_q        => int_sOutput(0),
      o_qBar     => open
    );

    gen_dFF_ar : for i in 1 to 8 generate
        dff_ar_inst: entity work.dff_ar
        port map (
          i_resetBar => i_rstBAR,
          i_d        => int_SInput(i),
          i_enable   => '1',
          i_clock    => i_clk,
          o_q        => int_sOutput(i),
          o_qBar     => open
        );
    end generate gen_dFF_ar;

    -- Concurrent signals
    int_SInput(0) <= '0';
    int_SInput(1) <= int_sOutput(0) and flag_B_GT_A;
    int_SInput(2) <= (int_sOutput(0) and (not flag_B_GT_A)) or int_sOutput(1);
    int_SInput(3) <= ((flag_GT_MAX_EDIFF or flag_zero_Ediff) and int_sOutput(2)) or int_sOutput(3);
    int_SInput(4) <= (not (flag_GT_MAX_EDIFF or flag_zero_Ediff) and not flag_zero_Ediff and int_sOutput(2)) or (int_sOutput(4) and not flag_zero_Ediff);
    int_SInput(5) <= (not (flag_GT_MAX_EDIFF or flag_zero_Ediff) and flag_zero_Ediff and int_sOutput(2)) or (int_sOutput(4) and flag_zero_Ediff);
    int_SInput(6) <= flag_zero_significandOutput and int_sOutput(5);
    int_SInput(7) <= ((not flag_zero_significandOutput and int_sOutput(5)) or int_sOutput(7)) and not flag_MSB_significandOutput;
    int_SInput(8) <= (((int_sOutput(5) and not flag_zero_significandOutput) or int_sOutput(7)) and flag_MSB_significandOutput) or int_sOutput(6) or int_sOutput(8);


    -- Control signals
    control_ldA_significand <= int_sOutput(0) or int_sOutput(1);
    control_ldB_significand <= int_sOutput(0) or int_sOutput(1) or int_sOutput(4);
    control_ldA_exponent <= int_sOutput(0) or int_sOutput(1);
    control_ldB_exponent <= int_sOutput(0) or int_sOutput(1);
    control_ldsign <= int_sOutput(0) or int_sOutput(1);
    control_swap <= int_sOutput(1);

    control_ldEdiff <= int_sOutput(2) or int_sOutput(4);
    control_subtractExponent <= int_sOutput(2) or int_sOutput(4) or int_sOutput(7);
    control_sel_adder_input1(0) <= int_sOutput(4);
    control_sel_adder_input1(1) <= int_sOutput(7);
    control_sel_adder_input2 <= int_sOutput(4) or int_sOutput(5) or int_sOutput(7);
    control_shiftR_B <= int_sOutput(4);
    control_ldOutput_significand <= int_sOutput(5) or int_sOutput(7);
    control_clrOutput_exponent <= int_sOutput(6);
    control_shiftL_output <= int_sOutput(7);
    control_ldOutput_exponent <= int_sOutput(5) or int_sOutput(7);
    control_selOutput <= int_sOutput(8);


end rtl;