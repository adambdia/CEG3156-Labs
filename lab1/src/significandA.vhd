library ieee;
use ieee.std_logic_1164.all;

entity significandA is
    generic(bits : positive := 9);
    port(
        i_rstBAR, i_clk         : in std_logic;
        i_mantissaA             : in std_logic_vector(bits-2 downto 0);
        i_significandB          : in std_logic_vector(bits-1 downto 0);
        i_ld                    : in std_logic;
        i_mux_select            : in std_logic;
        o_significandA          : out std_logic_vector(bits-1 downto 0)
    );
end significandA;

architecture rtl of significandA is
    signal int_significandA     : std_logic_vector(bits-1 downto 0);
    signal int_mux              : std_logic_vector(bits-1 downto 0);
    signal int_significandA_output  : std_logic_vector(bits-1 downto 0);
begin
    mux2x1nbit_inst: entity work.mux2x1nbit
    generic map (
      bits => bits
    )
    port map (
      i_a   => int_significandA,
      i_b   => i_significandB,
      i_sel => i_mux_select,
      o_out => int_mux
    );

    piponbit_inst: entity work.piponbit
    generic map (
      bits => bits
    )
    port map (
      i_in     => int_mux,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ld,
      o_out    => int_significandA_output
    );

    -- Concurrent signals
    int_significandA <= '1' & i_mantissaA;

    -- output driver
    o_significandA <= int_significandA_output;
end rtl;