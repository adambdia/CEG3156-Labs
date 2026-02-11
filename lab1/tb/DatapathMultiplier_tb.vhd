library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DatapathMultiplier_tb is
end entity;

architecture sim of DatapathMultiplier_tb is

    -- Match DUT generics
    constant mantissa_bits : positive := 8;
    constant exponent_bits : positive := 7;

    -- DUT signals
    signal i_rstBAR, i_clk : std_logic := '0';

    signal i_mantissaA, i_mantissaB : std_logic_vector(mantissa_bits-1 downto 0);
    signal i_exponentA, i_exponentB : std_logic_vector(exponent_bits-1 downto 0);
    signal i_signA, i_signB         : std_logic;

    signal i_ldInputs               : std_logic;
    signal i_ldSignificandOutput    : std_logic;
    signal i_clrSignificandOutput   : std_logic;
    signal i_shiftSignificandOutput : std_logic;

    signal o_mantissaOutput : std_logic_vector(mantissa_bits-1 downto 0);
    signal o_exponentOutput : std_logic_vector(exponent_bits-1 downto 0);
    signal o_signOutput     : std_logic;

    signal status_significandMSB : std_logic;
    signal status_input_0        : std_logic;

begin

    ----------------------------------------------------------------
    -- Instantiate DUT
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

        o_mantissaOutput => o_mantissaOutput,
        o_exponentOutput => o_exponentOutput,

        i_ldSignificandOutput    => i_ldSignificandOutput,
        i_clrSignificandOutput   => i_clrSignificandOutput,
        i_shiftSignificandOutput => i_shiftSignificandOutput,

        o_signOutput           => o_signOutput,
        status_significandMSB  => status_significandMSB,
        status_input_0         => status_input_0
    );

    ----------------------------------------------------------------
    -- Clock generation (10 ns period)
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for 5 ns;
            i_clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Stimulus process
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

        wait for 20 ns;
        i_rstBAR <= '1';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 1 : Load first operands
        ----------------------------------------------------------------
        i_mantissaA <= "10000000";
        i_mantissaB <= "01000000";
        i_exponentA <= "0001010";
        i_exponentB <= "0001010";
        i_signA <= '0';
        i_signB <= '0';

        i_ldInputs <= '1';
        wait for 10 ns;
        i_ldInputs <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- Load product into significandOutput
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        i_shiftSignificandOutput <= '0';
        i_clrSignificandOutput <= '0';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- SHIFT 3 TIMES (ld + shift both high)
        ----------------------------------------------------------------

        -- Shift #1
        i_ldSignificandOutput <= '1';
        i_shiftSignificandOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_shiftSignificandOutput <= '0';

        wait for 10 ns;

        -- Shift #2
        i_ldSignificandOutput <= '1';
        i_shiftSignificandOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_shiftSignificandOutput <= '0';

        wait for 10 ns;

        -- Shift #3
        i_ldSignificandOutput <= '1';
        i_shiftSignificandOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_shiftSignificandOutput <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- CLEAR (clr + ld both high)
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        i_clrSignificandOutput <= '1';
        i_shiftSignificandOutput <= '0';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';
        i_clrSignificandOutput <= '0';

        wait for 20 ns;

        ----------------------------------------------------------------
        -- TEST 2 : Load different operands
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
        -- Load new product into significandOutput
        ----------------------------------------------------------------
        i_ldSignificandOutput <= '1';
        wait for 10 ns;
        i_ldSignificandOutput <= '0';

        wait for 40 ns;

        wait;
    end process;


end architecture;
