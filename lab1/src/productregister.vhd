library ieee;
use ieee.std_logic_1164.all;

entity productregister is
    generic(input_bits : positive);
    port(
        i_rstBAR, i_clk         : in std_logic;

        -- Control signals
        control_ld                    : in std_logic;
        control_select_option         : in std_logic_vector(1 downto 0);
        -- Contorl select option:
        -- Init: 00, shift: 01, add and shift: 10

        -- Inputs
        i_multiplier            : in std_logic_vector(input_bits-1 downto 0);
        i_carryOut              : in std_logic;
        i_sum                   : in std_logic_vector(input_bits-1 downto 0);

        o_product               : out std_logic_vector(2*input_bits-1 downto 0);

        -- Status signals
        status_LSB              : out std_logic
    );
end productregister;

architecture rtl of productregister is
    signal int_product          : std_logic_vector(2*input_bits-1 downto 0);

    signal int_product_LSBits   : std_logic_vector(input_bits-2 downto 0);
    signal int_product_middleBit   : std_logic;
    signal int_product_MSBits   : std_logic_vector(input_bits-2 downto 0);
    signal int_product_MSBit    : std_logic;

    signal int_sel_mux_LSbits   : std_logic;

    signal int_mux_MSBits       : std_logic_vector(input_bits-2 downto 0);
 
begin

    -- The register is split into 4 mini registers

    -- LSbits register (size bits-1)
    -- Equal to multipler(bits-2 downto 0) or logical shift product right once
    piponbit_LSBits: entity work.piponbit
    generic map (
      bits => input_bits-1
    )
    port map (
      i_in     => int_product_LSBits,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => control_ld,
      o_out    => int_product(input_bits-2 downto 0)
    );

    -- Middle bit (size 1)
    -- Equal to multiplier MSB or Sum LSB or logical shift product right once
    dff_ar_midBit: entity work.dff_ar
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_product_middleBit,
      i_enable   => control_ld,
      i_clock    => i_clk,
      o_q        => int_product(input_bits-1),
      o_qBar     => open
    );

    -- MSBits (size bits-1)
    -- Equal to 0 (on initialization) or Sum MSBits or logical shift product right once
    piponbit_MSBits: entity work.piponbit
    generic map (
      bits => input_bits-1
    )
    port map (
      i_in     => int_product_MSBits,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => control_ld,
      o_out    => int_product(2*input_bits-2 downto input_bits)
    );
    -- MSB (size 1)
    -- Equal to 0 or Carry out (only during adding and shifting mode)
    dff_ar_MSBit: entity work.dff_ar
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_product_MSBit,
      i_enable   => control_ld,
      i_clock    => i_clk,
      o_q        => int_product(2*input_bits-1),
      o_qBar     => open
    );

    ----------------- Multiplexers ------------------------

    -- MSBit (size 1)
    mux2x1nbit_MSBits: entity work.mux2x1nbit
    generic map (
      bits => input_bits-1
    )
    port map (
      i_a   => i_sum(input_bits-1 downto 1),
      i_b   => int_product(2*input_bits-1 downto input_bits+1),
      i_sel => control_select_option(0),
      o_out => int_mux_MSBits
    );

    mux3x1_midBit: entity work.mux3x1
    port map (
      i_a   => i_multiplier(input_bits-1),
      i_b   => int_product(input_bits),
      i_c   => i_sum(0),
      i_sel => control_select_option,
      o_out => int_product_middleBit
    );

    mux2x1nbit_LSBits: entity work.mux2x1nbit
    generic map (
      bits => input_bits-1
    )
    port map (
      i_a   => i_multiplier(input_bits-2 downto 0),
      i_b   => int_product(input_bits-1 downto 1),
      i_sel => int_sel_mux_LSbits,
      o_out => int_product_LSBits
    );

    -- Concurrent signals
    int_sel_mux_LSbits <= control_select_option(1) or control_select_option(0);

    -- Inputs to each register
    int_product_MSBit <= i_carryOut and control_select_option(1) and not control_select_option(0);

    gen_product_MSBits: for i in 0 to input_bits-2 generate
        int_product_MSBits(i) <= int_mux_MSBits(i) and (control_select_option(1) or control_select_option(0));
    end generate gen_product_MSBits;

    -- Output Drivers
    o_product <= int_product;

    status_LSB <= int_product(0);

    
end rtl;

