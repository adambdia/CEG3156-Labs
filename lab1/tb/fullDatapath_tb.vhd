library ieee;
use ieee.std_logic_1164.all;

entity fullDatapath_tb is
end fullDatapath_tb;

architecture tb of fullDatapath_tb is
    constant mantissa_bits : positive := 8;
    constant exponent_bits : positive := 7;
    constant CLK_PERIOD    : time := 10 ns;

    -- Universal
    signal i_rstBAR, i_clk, i_swap : std_logic := '0';
    signal i_selOutput             : std_logic := '0';

    -- Sign
    signal i_signA, i_signB        : std_logic := '0';
    signal i_ldsign                : std_logic := '0';

    -- Significand
    signal i_mantissaA, i_mantissaB : std_logic_vector(mantissa_bits-1 downto 0);
    signal i_ldA_significand        : std_logic := '0';
    signal i_ldB_significand        : std_logic := '0';
    signal i_ldOutput_significand   : std_logic := '0';
    signal i_shiftR_B               : std_logic := '0';
    signal i_shiftL_output          : std_logic := '0';

    -- Exponent
    signal i_exponentA, i_exponentB : std_logic_vector(exponent_bits-1 downto 0);
    signal i_ldA_exponent           : std_logic := '0';
    signal i_ldB_exponent           : std_logic := '0';
    signal i_ldOutput_exponent      : std_logic := '0';
    signal i_clrOutput              : std_logic := '0';
    signal i_subtractExponent       : std_logic := '0';
    signal i_ldEdiff                : std_logic := '0';
    signal i_sel_adder_input2       : std_logic := '0';
    signal i_sel_adder_input1       : std_logic_vector(1 downto 0) := "00";

    -- Outputs
    signal o_signOutput             : std_logic;
    signal o_significandOutput      : std_logic_vector(mantissa_bits+1 downto 0);
    signal o_mantissaOutput         : std_logic_vector(mantissa_bits-1 downto 0);
    signal o_exponentOut            : std_logic_vector(exponent_bits-1 downto 0);
    signal flag_zero_significandOutput : std_logic;
    signal flag_MSB_significandOutput  : std_logic;
    signal flag_GT_MAX_EDIFF           : std_logic;
    signal flag_zero_Ediff             : std_logic;
    signal flag_B_GT_A                 : std_logic;
begin
    -- DUT
    uut: entity work.fullDatapath
        generic map (
            mantissa_bits => mantissa_bits,
            exponent_bits => exponent_bits
        )
        port map (
            i_rstBAR => i_rstBAR,
            i_clk => i_clk,
            i_swap => i_swap,
            i_selOutput => i_selOutput,
            i_signA => i_signA,
            i_signB => i_signB,
            i_ldsign => i_ldsign,
            i_mantissaA => i_mantissaA,
            i_mantissaB => i_mantissaB,
            i_ldA_significand => i_ldA_significand,
            i_ldB_significand => i_ldB_significand,
            i_ldOutput_significand => i_ldOutput_significand,
            i_shiftR_B => i_shiftR_B,
            i_shiftL_output => i_shiftL_output,
            i_exponentA => i_exponentA,
            i_exponentB => i_exponentB,
            i_ldA_exponent => i_ldA_exponent,
            i_ldB_exponent => i_ldB_exponent,
            i_ldOutput_exponent => i_ldOutput_exponent,
            i_clrOutput => i_clrOutput,
            i_subtractExponent => i_subtractExponent,
            i_ldEdiff => i_ldEdiff,
            i_sel_adder_input2 => i_sel_adder_input2,
            i_sel_adder_input1 => i_sel_adder_input1,
            o_signOutput => o_signOutput,
            o_significandOutput => o_significandOutput,
            o_mantissaOutput => o_mantissaOutput,
            o_exponentOut => o_exponentOut,
            flag_zero_significandOutput => flag_zero_significandOutput,
            flag_MSB_significandOutput => flag_MSB_significandOutput,
            flag_GT_MAX_EDIFF => flag_GT_MAX_EDIFF,
            flag_zero_Ediff => flag_zero_Ediff,
            flag_B_GT_A => flag_B_GT_A
        );

    -- Clock
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

        -- Load A and B
        i_exponentA <= "0000100";
        i_mantissaA <= "00001100";
        i_exponentB <= "0000001";
        i_mantissaB <= "11111111";

        i_ldA_significand <= '1';
        i_ldB_significand <= '1';
        i_ldA_exponent    <= '1';
        i_ldB_exponent    <= '1';

        wait for CLK_PERIOD;

        i_ldA_significand <= '0';
        i_ldB_significand <= '0';
        i_ldA_exponent    <= '0';
        i_ldB_exponent    <= '0';

        -- Swap and load outputs
        i_swap <= '1';
        i_ldOutput_significand <= '1';
        i_ldOutput_exponent    <= '1';

        wait for 2 * CLK_PERIOD;

        i_swap <= '0';
        i_ldOutput_significand <= '0';
        i_ldOutput_exponent    <= '0';

        -- Exponent subtraction
        i_ldEdiff          <= '1';
        i_subtractExponent <= '1';

        wait for CLK_PERIOD;

        i_ldEdiff          <= '0';
        i_subtractExponent <= '0';

        report "fullDatapath_tb completed" severity note;
        wait;
    end process;
end tb;
