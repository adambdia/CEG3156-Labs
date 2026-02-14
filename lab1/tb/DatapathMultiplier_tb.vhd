library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DatapathMultiplier_tb is
end entity;

architecture sim of DatapathMultiplier_tb is

    constant mantissa_bits : positive := 8;
    constant exponent_bits : positive := 7;

    -- Clock / Reset
    signal i_rstBAR, i_clk : std_logic := '0';

    -- Inputs
    signal i_mantissaA, i_mantissaB : std_logic_vector(mantissa_bits-1 downto 0);
    signal i_exponentA, i_exponentB : std_logic_vector(exponent_bits-1 downto 0);
    signal i_signA, i_signB         : std_logic;

    signal i_ldInputs               : std_logic;

    signal i_ldSignificandOutput    : std_logic;
    signal i_clrSignificandOutput   : std_logic;
    signal i_shiftSignificandOutput : std_logic;

    -- NEW control lines
    signal i_sel_adder_input1  : std_logic;
    signal i_sel_adder_input2  : std_logic_vector(1 downto 0);
    signal control_subtract    : std_logic;

    signal i_ldExponentOutput  : std_logic;
    signal i_clrExponentOutput : std_logic;

    -- Outputs
    signal o_mantissaOutput : std_logic_vector(mantissa_bits-1 downto 0);
    signal o_exponentOutput : std_logic_vector(exponent_bits-1 downto 0);
    signal o_signOutput     : std_logic;

    signal status_significandMSB : std_logic;
    signal status_input_0        : std_logic;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    DUT: entity work.DatapathMultiplier
    generic map(
        mantissa_bits => mantissa_bits,
        exponent_bits => exponent_bits
    )
    port map(
        i_rstBAR => i_rstBAR,
        i_clk    => i_clk,

        i_mantissaA => i_mantissaA,
        i_mantissaB => i_mantissaB,
        i_exponentA => i_exponentA,
        i_exponentB => i_exponentB,
        i_signA     => i_signA,
        i_signB     => i_signB,

        i_ldInputs => i_ldInputs,

        i_ldSignificandOutput    => i_ldSignificandOutput,
        i_clrSignificandOutput   => i_clrSignificandOutput,
        i_shiftSignificandOutput => i_shiftSignificandOutput,

        i_sel_adder_input1 => i_sel_adder_input1,
        i_sel_adder_input2 => i_sel_adder_input2,
        control_subtract   => control_subtract,

        i_ldExponentOutput  => i_ldExponentOutput,
        i_clrExponentOutput => i_clrExponentOutput,

        o_mantissaOutput => o_mantissaOutput,
        o_exponentOutput => o_exponentOutput,
        o_signOutput     => o_signOutput,

        status_significandMSB => status_significandMSB,
        status_input_0        => status_input_0
    );

    ----------------------------------------------------------------
    -- CLOCK (10 ns)
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            i_clk <= '0'; wait for 5 ns;
            i_clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- STIMULUS
    ----------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        i_rstBAR <= '0';

        i_ldInputs <= '0';
        i_ldSignificandOutput <= '0';
        i_clrSignificandOutput <= '0';
        i_shiftSignificandOutput <= '0';

        i_sel_adder_input1 <= '0';
        i_sel_adder_input2 <= "00";
        control_subtract <= '0';

        i_ldExponentOutput <= '0';
        i_clrExponentOutput <= '0';

        wait for 20 ns;
        i_rstBAR <= '1';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1 : LOAD INPUTS
        ----------------------------------------------------------------
        i_mantissaA <= "10000000";
        i_mantissaB <= "01000000";
        i_exponentA <= std_logic_vector(to_unsigned(87,exponent_bits));
        i_exponentB <= std_logic_vector(to_unsigned(31,exponent_bits));
        i_signA <= '0';
        i_signB <= '0';

        i_ldInputs <= '1';
        wait for 10 ns;
        i_ldInputs <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- LOAD PRODUCT INTO SIGNIFICAND OUTPUT
        -- LOAD EXPONENT SUM INTO EXPONENT OUTPUT
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        i_ldExponentOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_ldExponentOutput <= '0';

        ----------------------------------------------------------------
        -- SUBTRACT BIAS FROM EXPONENT
        ----------------------------------------------------------------
        i_sel_adder_input1 <= '1';
        i_sel_adder_input2 <= "01";
        control_subtract <= '1';
        i_ldExponentOutput <= '1';
        wait for 10 ns;
        i_sel_adder_input1 <= '0';
        i_sel_adder_input2 <= "00";
        control_subtract <= '0';
        i_ldExponentOutput <= '0';


        wait for 10 ns;


        ----------------------------------------------------------------
        -- SHIFT SIGNIFICAND OUTPUT 3 TIMES
        -- DECREMENT EXPONENT OUTPUT 3 TIMES
        ----------------------------------------------------------------
        for k in 1 to 3 loop
            i_ldSignificandOutput <= '1';
            i_shiftSignificandOutput <= '1';
            i_sel_adder_input1 <= '1';
            i_sel_adder_input2 <= "10";
            control_subtract <= '1';
            i_ldExponentOutput <= '1';
            wait for 10 ns;

            i_ldSignificandOutput <= '0';
            i_shiftSignificandOutput <= '0';
            i_sel_adder_input1 <= '0';
            i_sel_adder_input2 <= "00";
            control_subtract <= '0';
            i_ldExponentOutput <= '0';
            wait for 10 ns;
        end loop;

        wait for 20 ns;

        ----------------------------------------------------------------
        -- CLEAR SIGNIFICAND
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        i_clrSignificandOutput <= '1';
        wait for 10 ns;

        i_ldSignificandOutput <= '0';
        i_clrSignificandOutput <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 2 : DIFFERENT INPUTS
        ----------------------------------------------------------------
        i_mantissaA <= "11000000";
        i_mantissaB <= "00110000";
        i_exponentA <= "0000110";
        i_exponentB <= "0000100";
        i_signA <= '1';
        i_signB <= '0';

        i_ldInputs <= '1';
        wait for 10 ns;
        i_ldInputs <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- LOAD PRODUCT AGAIN
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        i_ldExponentOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_ldExponentOutput <= '0';

        wait for 40 ns;

        wait;
    end process;

end architecture;
