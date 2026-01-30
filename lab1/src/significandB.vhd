library ieee;
use ieee.std_logic_1164.all;

entity significandB is
    generic(bits : positive := 9);
    port(
        i_rstBAR, i_clk         : in std_logic;
        i_mantissaB             : in std_logic_vector(bits-2 downto 0);
        i_significandA          : in std_logic_vector(bits-1 downto 0);
        i_ld                    : in std_logic;
        i_mux_select            : in std_logic_vector(1 downto 0);
        o_significandB          : out std_logic_vector(bits-1 downto 0)
    );
end significandB;

architecture rtl of significandB is
    signal int_significandB         : std_logic_vector(bits-1 downto 0);
    signal int_shifted              : std_logic_vector(bits-1 downto 0);
    signal int_mux                  : std_logic_vector(bits-1 downto 0);
    signal int_significandB_output  : std_logic_vector(bits-1 downto 0);
begin
    mux4x1nbit_inst: entity work.mux4x1nbit
    generic map (
      bits => bits
    )
    port map (
      i_a   => int_significandB,
      i_b   => i_significandA,
      i_c   => int_shifted,
      i_d   => int_shifted,
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
      o_out    => int_significandB_output
    );

    -- Concurrent Signals
    int_significandB <= '1' & i_mantissaB;
    int_shifted <= '0' & int_significandB_output(bits-1 downto 1);

    -- Output drivers
    o_significandB <= int_significandB_output;

end rtl;