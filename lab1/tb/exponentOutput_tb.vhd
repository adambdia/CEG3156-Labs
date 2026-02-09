library ieee;
use ieee.std_logic_1164.all;

entity exponentOutput_tb is
end exponentOutput_tb;

architecture tb of exponentOutput_tb is
    constant bits : positive := 8;

    signal i_rstBAR  : std_logic := '1';
    signal i_clk     : std_logic := '0';
    signal i_input   : std_logic_vector(bits-1 downto 0) := (others => '0');
    signal i_ld      : std_logic := '0';
    signal i_clr     : std_logic := '0';
    signal o_expOut  : std_logic_vector(bits-1 downto 0);
begin
    -- DUT
    uut: entity work.exponentOutput
        generic map (
            bits => bits
        )
        port map (
            i_rstBAR          => i_rstBAR,
            i_clk             => i_clk,
            i_input           => i_input,
            i_ld              => i_ld,
            i_clr             => i_clr,
            o_exponentOutput  => o_expOut
        );

    -- Clock generation (10 ns period)
    clk_proc: process
    begin
        while true loop
            i_clk <= '0'; wait for 5 ns;
            i_clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- =====================
        -- Reset test
        -- =====================
        i_rstBAR <= '0';
        wait for 10 ns;
        i_rstBAR <= '1';
        wait for 10 ns;

        assert o_expOut = (bits-1 downto 0 => '0')
            report "FAIL: Reset did not clear output"
            severity error;

        -- =====================
        -- Load test
        -- =====================
        i_input <= x"3A";
        i_ld    <= '1';
        wait for 10 ns;
        i_ld <= '0';
        wait for 10 ns;

        assert o_expOut = x"3A"
            report "FAIL: Load failed"
            severity error;

        -- =====================
        -- Clear test
        -- =====================
        i_clr <= '1';
        wait for 10 ns;
        i_clr <= '0';
        wait for 10 ns;

        assert o_expOut = (bits-1 downto 0 => '0')
            report "FAIL: Clear failed"
            severity error;

        -- =====================
        -- Clear priority over load
        -- =====================
        i_input <= x"FF";
        i_ld    <= '1';
        i_clr   <= '1';
        wait for 10 ns;
        i_ld  <= '0';
        i_clr <= '0';
        wait for 10 ns;

        assert o_expOut = (bits-1 downto 0 => '0')
            report "FAIL: Clear did not override load"
            severity error;

        report "exponentOutput_tb PASSED" severity note;
        wait;
    end process;
end tb;
