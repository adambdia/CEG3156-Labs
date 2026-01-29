library ieee;
use ieee.std_logic_1164.all;

entity significandOutput is
    generic(bits : positive := 10);
    port(
        i_rstBAR, i_clk         : in std_logic;
        i_input                 : in std_logic_vector(bits-1 downto 0);
        i_ld, i_shiftL          : in std_logic;
        o_significandOutput     : out std_logic_vector(bits-1 downto 0)
    );
end significandOutput;

architecture rtl of significandOutput is
    signal int_shifted         : std_logic_vector(bits-1 downto 0);
    signal int_mux             : std_logic_vector(bits-1 downto 0);
    signal int_significandOutput    : std_logic_vector(bits-1 downto 0);
begin
    mux2x1nbit_inst: entity work.mux2x1nbit
    generic map (
      bits => bits
    )
    port map (
      i_a   => i_input,
      i_b   => int_shifted,
      i_sel => i_shiftL,
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
      o_out    => int_significandOutput
    );

    -- Concurrent Signals
    int_shifted <= int_significandOutput(bits-2 downto 0) & '0';

    -- Output drivers
    o_significandOutput <= int_significandOutput;

end rtl;