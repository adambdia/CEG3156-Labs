library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity productregister_tb is
end entity;

architecture tb of productregister_tb is

    constant INPUT_BITS : positive := 4;

    -- DUT signals
    signal i_rstBAR               : std_logic := '0';
    signal i_clk                  : std_logic := '0';

    signal control_ld             : std_logic := '0';
    signal control_select_option  : std_logic_vector(1 downto 0) := "00";

    signal i_multiplier           : std_logic_vector(INPUT_BITS-1 downto 0) := (others => '0');
    signal i_carryOut             : std_logic := '0';
    signal i_sum                  : std_logic_vector(INPUT_BITS-1 downto 0) := (others => '0');

    signal o_product              : std_logic_vector(2*INPUT_BITS-1 downto 0);
    signal status_LSB             : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    ------------------------------------------------------------------
    -- Clock generation
    ------------------------------------------------------------------
    clk_proc : process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- DUT instantiation
    ------------------------------------------------------------------
    dut : entity work.productregister
        generic map (
            input_bits => INPUT_BITS
        )
        port map (
            i_rstBAR              => i_rstBAR,
            i_clk                 => i_clk,
            control_ld            => control_ld,
            control_select_option => control_select_option,
            i_multiplier          => i_multiplier,
            i_carryOut            => i_carryOut,
            i_sum                 => i_sum,
            o_product             => o_product,
            status_LSB            => status_LSB
        );

    ------------------------------------------------------------------
    -- Stimulus (simulate 1011 * 0111)
    ------------------------------------------------------------------
    stim_proc : process
    begin
        -- Reset
        i_rstBAR <= '0';
        control_ld <= '0';
        wait for 30 ns;

        i_rstBAR <= '1';
        wait for CLK_PERIOD;

        -- Load multiplier, (and counter = 4)
        i_multiplier <= "0111";
        control_select_option <= "00"; -- init mode
        control_ld <= '1';
        wait for CLK_PERIOD;

        control_ld <= '0';
        -- Product = 0000 0111 , counter = 4 (not done)
        wait for CLK_PERIOD;
        -- Counter = 3, LSB = 1 (add and shift mode)
        -- Product = 0000 0111 , counter = 3 (not done), LSB = 1
        -- 0000 + 1011 = 1011 (carry out = 0)
        i_sum <= "1011";
        i_carryOut <= '0';
        control_select_option <= "10"; -- add and shift mode
        control_ld <= '1';
        wait for CLK_PERIOD;
        control_ld <= '0';

        -- Product = 0101 1011, not done
        wait for CLK_PERIOD;
        -- Counter = 2, LSB = 1 (add and shift mode)
        -- 0101 + 1011 = 0000 (carry out = 1)
        control_select_option <= "10";
        i_sum <= "0000";
        i_carryOut <= '1';
        control_ld <= '1';
        wait for CLK_PERIOD;

        control_ld <= '0';

        -- Product = 1000 0101
        wait for CLK_PERIOD;
        -- counter = 1, LSB = 1 (add and shift mode)
        -- 1000 + 1011 = 0011 (carry out = 1)
        control_select_option <= "10";
        i_sum <= "0011";
        i_carryOut <= '1';
        control_ld <= '1';
        wait for CLK_PERIOD;
        control_ld <= '0';

        -- Product = 1001 1010
        wait for CLK_PERIOD;
        -- counter = 0, LSB = 0 (shift mode)
        control_select_option <= "01";
        control_ld <= '1';
        wait for CLK_PERIOD;
        control_ld <= '0';

        -- Product = 0100 1101 (done)

        -- Finish
        wait;
    end process;

end architecture;
