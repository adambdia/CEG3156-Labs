library ieee;
use ieee.std_logic_1164.all;

entity ControlPathMultiplier is
    port(
        -- Reset and Clock
        i_rstBAR, i_clk                 : in std_logic;
        
        -- Status Signals
        status_significandMSB           : in std_logic;
        status_input_0                  : in std_logic;

        -- Control Signals
        control_ldInputs                : out std_logic;
        control_clrOutput               : out std_logic;
        control_ldSignficandOutput      : out std_logic;
        control_ldExponentOutput        : out std_logic;
        control_subtract_exponent       : out std_logic;  
        control_shift_significandOutput : out std_logic;

        sel_adder_input1                : out std_logic;
        sel_adder_input2                : out std_logic_vector(1 downto 0)

    );
end ControlPathMultiplier;

architecture rtl of ControlPathMultiplier is
    signal int_state_input, int_state_output            : std_logic_vector(4 downto 0);
begin
    state_0: entity work.dff_as
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_state_input(0),
      i_enable   => '1',
      i_clock    => i_clk,
      o_q        => int_state_output(0),
      o_qBar     => open
    );
    gen_states : for i in 1 to 4 generate
        dff_ar_inst: entity work.dff_ar
        port map (
          i_resetBar => i_rstBAR,
          i_d        => int_state_input(i),
          i_enable   => '1',
          i_clock    => i_clk,
          o_q        => int_state_output(i),
          o_qBar     => open
        );
    end generate gen_states;

    -- input states
    int_state_input(0) <= '0';
    int_state_input(1) <= int_state_output(0) and status_input_0;
    int_state_input(2) <= int_state_output(0) and not status_input_0;
    int_state_input(3) <= int_state_output(2);
    int_state_input(4) <= (int_state_output(3) or int_state_output(4)) and not status_significandMSB;

    -- Control Signal Drivers
    control_ldInputs <= int_state_output(0);
    control_clrOutput <= int_state_output(1);
    control_ldSignficandOutput <= int_state_output(1) or int_state_output(2) or int_state_output(4);
    control_ldExponentOutput <= int_state_output(1) or int_state_output(2) or int_state_output(3) or int_state_output(4);
    control_subtract_exponent <= int_state_output(3) or int_state_output(4);
    control_shift_significandOutput <= int_state_output(4);

    sel_adder_input1 <= int_state_output(3) or int_state_output(4);
    sel_adder_input2 <= int_state_output(4) & int_state_output(3); 
end rtl;