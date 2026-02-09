library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentDatapath_tb is
end exponentDatapath_tb;

architecture sim of exponentDatapath_tb is

    constant bits : positive := 7;
    constant mantissa_bits : positive := 8;
    constant CLK_PERIOD : time := 10 ns;

    -- DUT signals
    signal i_rstBAR              : std_logic := '0';
    signal i_clk                 : std_logic := '0';

    signal i_exponentA           : std_logic_vector(bits-1 downto 0) := (others => '0');
    signal i_exponentB           : std_logic_vector(bits-1 downto 0) := (others => '0');

    signal i_ldA                 : std_logic := '0';
    signal i_ldB                 : std_logic := '0';
    signal i_ldOutput            : std_logic := '0';
    signal i_clrOutput           : std_logic := '0';
    signal i_ldEdiff             : std_logic := '0';

    signal i_swap                : std_logic := '0';
    signal i_sel_adder_input1    : std_logic_vector(1 downto 0) := "00";
    signal i_sel_adder_input2    : std_logic := '0';
    signal i_selOutput           : std_logic := '1';
    signal i_subtractExponent    : std_logic := '0';

    signal o_exponentOut         : std_logic_vector(bits-1 downto 0);
    signal o_exponentA           : std_logic_vector(bits-1 downto 0);
    signal o_exponentB           : std_logic_vector(bits-1 downto 0);
    signal flag_GT_MAX_Ediff     : std_logic;
    signal flag_zero_Ediff       : std_logic;

begin

    -- Clock generator
    clk_proc : process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD/2;
            i_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- DUT instance
    dut : entity work.exponentDatapath
        generic map (
            exponent_bits => bits,
            mantissa_bits => mantissa_bits
        )
        port map (
            i_rstBAR              => i_rstBAR,
            i_clk                 => i_clk,
            i_exponentA           => i_exponentA,
            i_exponentB           => i_exponentB,
            i_ldA                 => i_ldA,
            i_ldB                 => i_ldB,
            i_ldOutput            => i_ldOutput,
            i_clrOutput           => i_clrOutput,
            i_subtractExponent    => i_subtractExponent,
            i_ldEdiff             => i_ldEdiff,
            i_swap                => i_swap,
            i_sel_adder_input1    => i_sel_adder_input1,
            i_sel_adder_input2    => i_sel_adder_input2,
            i_selOutput           => i_selOutput,
            o_exponentOut         => o_exponentOut,
            o_exponentA           => o_exponentA,
            o_exponentB           => o_exponentB,
            flag_GT_MAX_EDIFF     => flag_GT_MAX_Ediff,
            flag_zero_Ediff       => flag_zero_Ediff
        );

    -- Stimulus
    stim_proc : process
    begin

        --------------------------------------------------
        -- RESET
        --------------------------------------------------
        i_rstBAR <= '0';
        wait for 2 * CLK_PERIOD;
        i_rstBAR <= '1';
        wait for CLK_PERIOD;

        --------------------------------------------------
        -- LOAD EXPONENT A = 20, B = 5
        --------------------------------------------------
        i_exponentA <= "0001001";
        i_exponentB <= "0010000";

        i_ldA <= '1';
        i_ldB <= '1';
        wait for CLK_PERIOD;

        i_ldA <= '0';
        i_ldB <= '0';
        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- COMPUTE EDIFF = A - B
        --------------------------------------------------
        i_sel_adder_input1 <= "00"; -- select exponentA
        i_sel_adder_input2 <= '0'; -- select exponentB
        i_ldEdiff <= '1';
        i_subtractExponent <= '1';
        wait for CLK_PERIOD;
        i_subtractExponent <= '0';
        i_ldEdiff <= '0';
        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- CHECK MAX_EDIFF FLAG
        --------------------------------------------------
        report "Ediff = " & integer'image(to_integer(unsigned(o_exponentOut)));

        --------------------------------------------------
        -- TEST SWAP
        --------------------------------------------------
        i_swap <= '1';
        i_ldA <= '1';
        i_ldB <= '1';
        wait for CLK_PERIOD;

        i_swap <= '0';
        i_ldA <= '0';
        i_ldB <= '0';
        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- COMPUTE EDIFF = A - B
        --------------------------------------------------
        i_sel_adder_input1 <= "00"; -- select exponentA
        i_sel_adder_input2 <= '0'; -- select exponentB
        i_ldEdiff <= '1';
        i_subtractExponent <= '1';
        wait for CLK_PERIOD;
        i_subtractExponent <= '0';
        i_ldEdiff <= '0';
        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- SUBTRACT 1 FROM EDIFF A and Store In EDIFF
        --------------------------------------------------
        i_sel_adder_input1 <= "01"; -- select ExponentA
        i_sel_adder_input2 <= '1'; -- select CONST_1
        i_ldEdiff <= '1';
        i_subtractExponent <= '1';
        wait for 3 * CLK_PERIOD;

        i_ldEdiff <= '0';
        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- ADD 1 TO A AND STORE IN EXPONENTOUTPUT
        --------------------------------------------------
        i_subtractExponent <= '0';
        i_sel_adder_input1 <= "00";
        i_sel_adder_input2 <= '1';
        i_ldOutput <= '1';
        wait for clk_period;
        i_ldOutput <= '0';

        --------------------------------------------------
        -- DECREMENT 1 FROM EXPONENTOUT 
        --------------------------------------------------
        i_sel_adder_input1 <= "10";
        i_sel_adder_input2 <= '1';
        i_subtractExponent <= '1';
        i_ldOutput <= '1';
        WAIT FOR 3 * CLK_PERIOD;
        i_ldOutput <= '0';

        --------------------------------------------------
        -- FORCE LARGE EDIFF TO TRIGGER FLAG
        --------------------------------------------------
        i_exponentA <= std_logic_vector(to_unsigned(120, bits));
        i_exponentB <= std_logic_vector(to_unsigned(1, bits));
        i_ldA <= '1';
        i_ldB <= '1';
        wait for CLK_PERIOD;

        i_ldA <= '0';
        i_ldB <= '0';

        i_sel_adder_input1 <= "10";
        i_sel_adder_input2 <= '1';
        i_ldEdiff <= '1';
        wait for CLK_PERIOD;
        i_ldEdiff <= '0';

        wait for 2 * CLK_PERIOD;

        i_selOutput <= '0';
        wait for CLK_PERIOD;
        i_selOutput <= '1';

        i_clrOutput <= '1';
        i_ldOutput <= '1';
        wait for CLK_PERIOD;
        i_clrOutput <= '0';
        i_ldOutput <= '0';
        --------------------------------------------------
        -- END SIM
        --------------------------------------------------
        report "Simulation complete." severity note;
        wait;
    end process;

end sim;
