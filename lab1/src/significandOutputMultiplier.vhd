library ieee;
use ieee.std_logic_1164.all;

entity significandOutputMultiplier is
    generic(
        product_bits  : positive := 18
    );
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_product                   : in std_logic_vector(product_bits-1 downto 0);
        i_ld, i_clr, i_shift        : in std_logic;
        o_significandOutput         : out std_logic_vector(product_bits-1 downto 0)
    );
end significandOutputMultiplier;

architecture rtl of significandOutputMultiplier is
    -- Multiplexers:
    signal int_shifted              : std_logic_vector(product_bits-1 downto 0);
    constant CLEARED_OUTPUT         : std_logic_vector(product_bits-1 downto 0) := (others => '0');
    signal int_sel_mux              : std_logic_vector(1 downto 0);


    signal int_signficandOutput_input     : std_logic_vector(product_bits-1 downto 0);
    signal int_signficandOutput     : std_logic_vector(product_bits-1 downto 0);

 
begin
    mux3x1nbit_inst: entity work.mux3x1nbit
    generic map (
      bits => product_bits
    )
    port map (
      i_a   => i_product,
      i_b   => int_shifted,
      i_c   => CLEARED_OUTPUT,
      i_sel => int_sel_mux,
      o_out => int_signficandOutput_input
    );

    piponbit_inst: entity work.piponbit
    generic map (
      bits => product_bits
    )
    port map (
      i_in     => int_signficandOutput_input,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ld,
      o_out    => int_signficandOutput
    );


    -- Concurrent Signals
    int_shifted <= int_signficandOutput(product_bits-2 downto 0) & '0';
    int_sel_mux <=  i_clr & i_shift;

    -- Output driver: 
    o_significandOutput <= int_signficandOutput;
end rtl;