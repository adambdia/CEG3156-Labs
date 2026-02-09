library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero_flag_tb is
end zero_flag_tb;

architecture sim of zero_flag_tb is

    constant WIDTH : positive := 10;

    signal i_data      : std_logic_vector(WIDTH-1 downto 0);
    signal o_zero_flag : std_logic;

begin

    -- DUT instantiation
    dut : entity work.zero_flag
        generic map (
            WIDTH => WIDTH
        )
        port map (
            i_data      => i_data,
            o_zero_flag => o_zero_flag
        );

    -- Stimulus process
    stim_proc : process
    begin

        --------------------------------------------------
        -- TEST 1: All zeros (should assert zero flag)
        --------------------------------------------------
        i_data <= (others => '0');
        wait for 10 ns;

        assert (o_zero_flag = '1')
            report "FAIL: Zero flag should be 1 when input = 0"
            severity error;

        --------------------------------------------------
        -- TEST 2: Single bit set
        --------------------------------------------------
        i_data <= (others => '0');
        i_data(3) <= '1';
        wait for 10 ns;

        assert (o_zero_flag = '0')
            report "FAIL: Zero flag should be 0 when any bit = 1"
            severity error;

        --------------------------------------------------
        -- TEST 3: Multiple bits set
        --------------------------------------------------
        i_data <= (others => '0');
        i_data(2) <= '1';
        i_data(6) <= '1';
        wait for 10 ns;

        assert (o_zero_flag = '0')
            report "FAIL: Zero flag should be 0 when multiple bits = 1"
            severity error;

        --------------------------------------------------
        -- TEST 4: All bits set
        --------------------------------------------------
        i_data <= (others => '1');
        wait for 10 ns;

        assert (o_zero_flag = '0')
            report "FAIL: Zero flag should be 0 when input = all ones"
            severity error;

        --------------------------------------------------
        -- TEST 5: Toggle back to zero
        --------------------------------------------------
        i_data <= (others => '0');
        wait for 10 ns;

        assert (o_zero_flag = '1')
            report "FAIL: Zero flag should return to 1"
            severity error;

        --------------------------------------------------
        -- DONE
        --------------------------------------------------
        report "All zero_flag tests PASSED." severity note;
        wait;
    end process;

end sim;
