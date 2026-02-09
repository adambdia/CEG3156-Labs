library ieee;
use ieee.std_logic_1164.all;

entity exponentOutput is
    generic(bits : positive := 8);
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_input                     : in std_logic_vector(bits-1 downto 0);
        i_ld                        : in std_logic;
        i_clr                       : in std_logic;
        o_exponentOutput            : out std_logic_vector(bits-1 downto 0)
    );
end exponentOutput;

architecture rtl of exponentOutput is
    signal int_input            : std_logic_vector(bits-1 downto 0);
    signal int_ld               : std_logic;
begin
    piponbit_inst: entity work.piponbit
    generic map (
      bits => bits
    )
    port map (
      i_in     => int_input,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => int_ld,
      o_out    => o_exponentOutput
    );

    int_input <= i_input and (bits-1 downto 0 => not i_clr);

    -- concurrent signals
    int_ld <= i_ld or i_clr;
end rtl;