----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: alu.vhd
-- Description: MIPS alu with the following operations:
-- A+B, A-B, A and B, A or B, A < B (returns 000...00lt), beq
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity alu is
    generic(bits : positive := 32);
    port(
        i_input1, i_input2              : in std_logic_vector(bits-1 downto 0);
        i_func                          : in std_logic_vector(5 downto 0);
        o_output                        : out std_logic_vector(bits-1 downto 0);
        o_zero                          : out std_logic;
        o_carryOut                      : out std_logic
    );
end alu;

architecture rtl of alu is
    -- internal output signals
    signal int_sum                      : std_logic_vector(bits-1 downto 0);
    signal int_and, int_or              : std_logic_vector(bits-1 downto 0);
    signal int_lt                       : std_logic_vector(bits-1 downto 0) := (others => '0' );
    signal int_output                   : std_logic_vector(bits-1 downto 0);

    -- Control signals
    signal ctrl_subtract                : std_logic;
    signal ctrl_sel                     : std_logic_vector(1 downto 0);

begin
    ---------------- Datapath ----------------
    -- adder, subtractor
    fulladdernbit_inst: entity work.fulladdernbit
    generic map (
      bits => bits
    )
    port map (
      i_a        => i_input1,
      i_b        => i_input2,
      i_carry    => '0',
      i_subtract => ctrl_subtract,
      o_sum      => int_sum,
      o_carry    => o_carryOut
    );

    -- And/Or 
    gen_and_or : for i in 0 to bits-1 generate
        int_and(i) <= i_input1(i) and i_input2(i);
        int_or(i)  <= i_input1(i) or i_input2(i);
    end generate gen_and_or;

    mux4x1nbit_inst: entity work.mux4x1nbit
    generic map (
      bits => bits
    )
    port map (
      i_a   => int_sum,
      i_b   => int_and,
      i_c   => int_or,
      i_d   => int_lt,
      i_sel => ctrl_sel,
      o_out => int_output
    );

    zero_flag_inst: entity work.zero_flag
    generic map (
      WIDTH => bits
    )
    port map (
      i_data      => int_output,
      o_zero_flag => o_zero
    );

    int_lt(0) <= int_sum(bits-1); -- Check sign

    ---------------- Control Logic ----------------
    -- in adder mode (func = 32), mux = 00, ctrl_subtract = 0
    -- in subtractor mode(func = 34), mux = 00, ctrl_subtract = 1
    -- in and mode (func = 36), mux = 01, ctrl_subtract = x
    -- in or mode (func = 37), mux = 10, ctrl_subtract = x
    -- in slt mode (func = 42), mux = 11, ctrl_subtract = 1
    -- For now, if func != any of the selected, just add
    

    -- ctrl_subtract <= (i_func == 34 or i_func == 42) = i_func == 10 0 010 or i_func == 10 1 010
    ctrl_subtract <= i_func(5) and not i_func(4) and not i_func(2) and i_func(1) and not i_func(0);
    -- ctrl_sel(1) <= (i_func == 37 or i_func == 42 ) = i_func == 10 0101 or 10 1010
    ctrl_sel(1) <= i_func(5) and not i_func(4) and ((not i_func(3) and i_func(2) and not i_func(1) and i_func(0)) or (i_func(3) and not i_func(2) and i_func(1) and not i_func(0)));
    -- ctrl_sel(0) <= (i_func == 36 or i_func == 42) = i_func == 10 010 0 or 10 101 0
    ctrl_sel(0) <= i_func(5) and not i_func(4) and ((not i_func(3) and i_func(2) and not i_func(1)) or (i_func(3) and not i_func(2) and i_func(1))) and not i_func(0);


    ---------------- Output Drivers ----------------
    o_output <= int_output;
    
end rtl;