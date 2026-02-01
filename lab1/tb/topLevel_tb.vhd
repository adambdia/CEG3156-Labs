library ieee;
use ieee.std_logic_1164.all;

entity topLevel_tb is
end topLevel_tb;

architecture sim of topLevel_tb is
    constant CLK_PERIOD : time := 10 ns;

    -- DUT generics
    constant M_BITS : positive := 8;
    constant E_BITS : positive := 7;

    -- Clock / reset
    signal i_clk    : std_logic := '0';
    signal i_rstBAR : std_logic := '0';

    -- Inputs
    signal i_signA, i_signB : std_logic := '0';
    signal i_mantissaA      : std_logic_vector(M_BITS-1 downto 0) := (others => '0');
    signal i_mantissaB      : std_logic_vector(M_BITS-1 downto 0) := (others => '0');
    signal i_exponentA      : std_logic_vector(E_BITS-1 downto 0) := (others => '0');
    signal i_exponentB      : std_logic_vector(E_BITS-1 downto 0) := (others => '0');

    -- Outputs
    signal o_signOutput     : std_logic;
    signal o_mantissaOutput : std_logic_vector(M_BITS-1 downto 0);
    signal o_exponentOutput : std_logic_vector(E_BITS-1 downto 0);
begin
    -- =========================
    -- Clock generation
    -- =========================
    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for CLK_PERIOD/2;
            i_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- =========================
    -- DUT
    -- =========================
    dut: entity work.topLevel
        generic map (
            mantissa_bits => M_BITS,
            exponent_bits => E_BITS
        )
        port map (
            i_rstBAR          => i_rstBAR,
            i_clk             => i_clk,
            i_signA           => i_signA,
            i_signB           => i_signB,
            i_mantissaA       => i_mantissaA,
            i_mantissaB       => i_mantissaB,
            i_exponentA       => i_exponentA,
            i_exponentB       => i_exponentB,
            o_signOutput      => o_signOutput,
            o_mantissaOutput  => o_mantissaOutput,
            o_exponentOutput  => o_exponentOutput
        );

    -- =========================
    -- Stimulus
    -- =========================
    stim_proc : process
    begin
        -- RESET
        i_rstBAR <= '0';
        wait for 2 * CLK_PERIOD;
        i_rstBAR <= '1';

        -- Load operands
        -- A = + 0.0001100 * 2^4
        -- B = + 0.11111111 * 2^1
        i_signA     <= '0';
        i_signB     <= '0';
        i_exponentA <= "0000100";
        i_mantissaA <= "00001100";
        i_exponentB <= "0000001";
        i_mantissaB <= "11111111";

        -- Let FSM run
        wait for 30 * CLK_PERIOD;

        -- Change operands (optional second test)
        i_exponentA <= "0000011";
        i_mantissaA <= "01000000";
        i_exponentB <= "0000011";
        i_mantissaB <= "00100000";

        wait for 30 * CLK_PERIOD;

        -- Stop simulation
        wait;
    end process;

end sim;
