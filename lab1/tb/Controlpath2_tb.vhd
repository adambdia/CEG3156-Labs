library ieee;
use ieee.std_logic_1164.all;

entity Controlpath2_tb is
end Controlpath2_tb;

architecture tb of Controlpath2_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal i_rstBAR                    : std_logic := '0';
    signal i_clk                       : std_logic := '0';

    signal flag_zero_significandOutput : std_logic := '0';
    signal flag_MSB_significandOutput  : std_logic := '0';
    signal flag_GT_MAX_EDIFF           : std_logic := '0';
    signal flag_zero_Ediff             : std_logic := '0';
    signal flag_B_GT_A                 : std_logic := '0';

    -- Outputs (undriven internally, still required)
    signal control_swap                : std_logic;
    signal control_selOutput           : std_logic;
    signal control_ldsign              : std_logic;
    signal control_ldA_significand     : std_logic;
    signal control_ldB_significand     : std_logic;
    signal control_ldOutput_significand: std_logic;
    signal control_shiftR_B            : std_logic;
    signal control_shiftL_output       : std_logic;
    signal control_ldA_exponent        : std_logic;
    signal control_ldB_exponent        : std_logic;
    signal control_ldOutput_exponent   : std_logic;
    signal control_clrOutput           : std_logic;
    signal control_subtractExponent    : std_logic;
    signal control_ldEdiff             : std_logic;
    signal control_sel_adder_input2    : std_logic;
    signal control_sel_adder_input1    : std_logic_vector(1 downto 0);
begin
    -- DUT
    uut: entity work.Controlpath
        port map (
            i_rstBAR => i_rstBAR,
            i_clk => i_clk,
            flag_zero_significandOutput => flag_zero_significandOutput,
            flag_MSB_significandOutput => flag_MSB_significandOutput,
            flag_GT_MAX_EDIFF => flag_GT_MAX_EDIFF,
            flag_zero_Ediff => flag_zero_Ediff,
            flag_B_GT_A => flag_B_GT_A,
            control_swap => control_swap,
            control_selOutput => control_selOutput,
            control_ldsign => control_ldsign,
            control_ldA_significand => control_ldA_significand,
            control_ldB_significand => control_ldB_significand,
            control_ldOutput_significand => control_ldOutput_significand,
            control_shiftR_B => control_shiftR_B,
            control_shiftL_output => control_shiftL_output,
            control_ldA_exponent => control_ldA_exponent,
            control_ldB_exponent => control_ldB_exponent,
            control_ldOutput_exponent => control_ldOutput_exponent,
            control_clrOutput_exponent => control_clrOutput,
            control_subtractExponent => control_subtractExponent,
            control_ldEdiff => control_ldEdiff,
            control_sel_adder_input2 => control_sel_adder_input2,
            control_sel_adder_input1 => control_sel_adder_input1
        );

    -- Clock generation
    clk_proc: process
    begin
        while true loop
            i_clk <= '0'; wait for CLK_PERIOD/2;
            i_clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        i_rstBAR <= '0';
        wait for CLK_PERIOD;
        i_rstBAR <= '1';

        -- Clear comparator flag
        flag_B_GT_A <= '0';
        wait for 2 * CLK_PERIOD;

        -- Exponent flags
        flag_GT_MAX_EDIFF <= '1';
        flag_zero_Ediff <= '1';
        wait for CLK_PERIOD;
        flag_zero_Ediff <= '0';
        flag_GT_MAX_EDIFF <= '0';

        -- Significand flags
        flag_zero_significandOutput <= '0';
        wait for CLK_PERIOD;
        flag_zero_significandOutput <= '0';

        flag_MSB_significandOutput <= '0';
        wait for 5 * CLK_PERIOD;
        flag_MSB_significandOutput <= '1';
        wait for CLK_PERIOD;
        flag_MSB_significandOutput <= '0';

        report "Controlpath2_tb finished" severity note;
        wait;
    end process;
end tb;
