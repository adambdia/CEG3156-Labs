library ieee;
use ieee.std_logic_1164.all;

entity mux3x1nbit is
    generic(bits : positive);
    port(
        i_a, i_b, i_c               : in std_logic_vector(bits-1 downto 0);
        i_sel                       : in std_logic_vector(1 downto 0);
        o_out                       : out std_logic_vector(bits-1 downto 0)
    );
end mux3x1nbit;

architecture rtl of mux3x1nbit is
begin
    gen_mux : for i in 0 to bits-1 generate
        mux3x1_inst: entity work.mux3x1
        port map (
          i_a   => i_a(i),
          i_b   => i_b(i),
          i_c   => i_c(i),
          i_sel => i_sel,
          o_out => o_out(i)
        );
    end generate gen_mux;
end rtl;