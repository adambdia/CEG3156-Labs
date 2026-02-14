library ieee;
use ieee.std_logic_1164.all;

entity ControlPathMultiplier_tb is
end ControlPathMultiplier_tb;

architecture tb of ControlPathMultiplier_tb is
    constant clk_period                     : time := 10 ns;

    signal i_rstBAR, i_clk                  : std_logic := '0';
    signal status_significandMSB            : std_logic := '0';
    signal status_input_0                   : std_logic := '0';
    signal control_ldInputs                 : std_logic := '0';
    signal control_clrOutput                : std_logic := '0';
    signal control_ldSignficandOutput       : std_logic := '0';
    signal control_ldExponentOutput         : std_logic := '0';
    signal control_subtract_exponent        : std_logic := '0';
    signal control_shift_significandOutput  : std_logic := '0';
    signal sel_adder_input1                 : std_logic := '0';
    signal sel_adder_input2                 : std_logic_vector(1 downto 0) := "00";

begin
    clk_process : process
    begin
        loop 
            i_clk <= '0';
            wait for clk_period/2;
            i_clk <= '1';
            wait for clk_period/2;
        end loop;
    end process clk_process;

    dut: entity work.ControlPathMultiplier
    port map (
      i_rstBAR                        => i_rstBAR,
      i_clk                           => i_clk,
      status_significandMSB           => status_significandMSB,
      status_input_0                  => status_input_0,
      control_ldInputs                => control_ldInputs,
      control_clrOutput               => control_clrOutput,
      control_ldSignficandOutput      => control_ldSignficandOutput,
      control_ldExponentOutput        => control_ldExponentOutput,
      control_subtract_exponent       => control_subtract_exponent,
      control_shift_significandOutput => control_shift_significandOutput,
      sel_adder_input1                => sel_adder_input1,
      sel_adder_input2                => sel_adder_input2
    );

    stim_proc : process
    begin

        ----------------------------------------------------
        -- RESET
        ----------------------------------------------------
        i_rstBAR <= '0';
        wait for clk_period;
        i_rstBAR <= '1';

        ----------------------------------------------------
        -- LD INPUTS (one of them is 0)
        ----------------------------------------------------
        status_input_0 <= '1';
        wait for 2 * clk_period;
        status_input_0 <= '0';

        ----------------------------------------------------
        -- RESET
        ----------------------------------------------------
        i_rstBAR <= '0';
        wait for clk_period;
        i_rstBAR <= '1';

        ----------------------------------------------------
        -- LD INPUTS (NEITHER ARE 0)
        ----------------------------------------------------
        status_input_0 <= '0';
        wait for clk_period;
        status_input_0 <= '1'; -- this should not affect

        ----------------------------------------------------
        -- TAKE THE PRODUCT (2 Cycles)
        ----------------------------------------------------
        wait for clk_period; -- Take the product and exponent
        status_significandMSB <= '0'; -- in between step
        wait for clk_period; -- fix the exponent bias


        ----------------------------------------------------
        -- NORMALIZE (MSB=1 AFTER 5 SHIFTS)
        ----------------------------------------------------
        wait for 5 * clk_period;
        status_significandMSB <= '1';

        wait for 3 * clk_period;

        wait;
        ----------------------------------------------------
        -- END
        ----------------------------------------------------
    end process stim_proc;
end tb;