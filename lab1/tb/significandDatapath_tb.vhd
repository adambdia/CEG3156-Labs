library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity significandDatapath_tb is
end significandDatapath_tb;

architecture sim of significandDatapath_tb is

    constant bits : positive := 9;
    constant CLK_PERIOD : time := 10 ns;

    -- DUT signals
    signal i_rstBAR              : std_logic := '0';
    signal i_clk                 : std_logic := '0';
    signal i_mantissaA           : std_logic_vector(bits-2 downto 0) := (others => '0');
    signal i_mantissaB           : std_logic_vector(bits-2 downto 0) := (others => '0');

    signal i_ldA                 : std_logic := '0';
    signal i_ldB                 : std_logic := '0';
    signal i_ldOutput            : std_logic := '0';
    signal i_ldOutputA           : std_logic := '0';

    signal i_swap                : std_logic := '0';
    signal i_shiftR_B            : std_logic := '0';
    signal i_shiftL_output       : std_logic := '0';
    signal i_subtractSignificand : std_logic := '0';

    signal o_significandOutput   : std_logic_vector(bits downto 0);
    signal flag_zero             : std_logic;

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
    dut : entity work.significandDatapath
        generic map(bits => bits)
        port map(
            i_rstBAR              => i_rstBAR,
            i_clk                 => i_clk,
            i_mantissaA           => i_mantissaA,
            i_mantissaB           => i_mantissaB,
            i_ldA                 => i_ldA,
            i_ldB                 => i_ldB,
            i_ldOutput            => i_ldOutput,
            i_ldOutputA           => i_ldOutputA,
            i_swap                => i_swap,
            i_shiftR_B            => i_shiftR_B,
            i_shiftL_output       => i_shiftL_output,
            i_subtractSignificand => i_subtractSignificand,
            o_significandOutput   => o_significandOutput,
            flag_zero             => flag_zero
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
        -- LOAD A AND B
        --------------------------------------------------
        i_mantissaA <= "10101010";
        i_mantissaB <= "00110011";
        i_ldA <= '1';
        i_ldB <= '1';

        wait for CLK_PERIOD;
        i_ldA <= '0';
        i_ldB <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- LOAD ADDER OUTPUT
        --------------------------------------------------
        i_ldOutput <= '1';
        wait for CLK_PERIOD;
        i_ldOutput <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST SHIFT RIGHT B
        --------------------------------------------------
        i_shiftR_B <= '1';
        i_ldB <= '1';
        wait for CLK_PERIOD;
        i_shiftR_B <= '0';
        i_ldB <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST SWAP
        --------------------------------------------------
        i_swap <= '1';
        i_ldA <= '1'; i_ldB <= '1';
        wait for CLK_PERIOD;
        i_swap <= '0';
        i_ldA <= '0'; i_ldB <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST SHIFT LEFT OUTPUT
        --------------------------------------------------
        i_shiftL_output <= '1';
        i_ldOutput <= '1';
        wait for CLK_PERIOD;
        i_shiftL_output <= '0';
        i_ldOutput <= '0';

        wait for 2 * CLK_PERIOD;


        --------------------------------------------------
        -- TEST SWAP
        --------------------------------------------------
        i_swap <= '1';
        i_ldA <= '1'; i_ldB <= '1';
        wait for CLK_PERIOD;
        i_swap <= '0';
        i_ldA <= '0'; i_ldB <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST SUBTRACTION
        --------------------------------------------------
        i_subtractSignificand <= '1';
        i_ldOutput <= '1';
        wait for CLK_PERIOD;
        i_subtractSignificand <= '0';
        i_ldOutput <= '0';

        wait for 2 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST LOAD A INTO OUTPUT
        --------------------------------------------------
        i_ldOutputA <= '1';
        wait for CLK_PERIOD;
        i_ldOutputA <= '0';

        --------------------------------------------------
        -- END SIM
        --------------------------------------------------
        wait for 3 * CLK_PERIOD;
        report "Simulation complete." severity note;
        wait;
    end process;

end sim;
