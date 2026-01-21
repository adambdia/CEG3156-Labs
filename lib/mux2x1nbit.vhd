----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: mux2x1nbit.vhd
-- Description: template file
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux2x1nbit is
    generic (bits : positive := 8);
    port(
        i_a : in std_logic_vector(bits-1 downto 0);
        i_b : in std_logic_vector(bits-1 downto 0);
        i_sel : in std_logic;
        o_out : out std_logic_vector(bits-1 downto 0));
end mux2x1nbit;

architecture rtl of mux2x1nbit is
-- Signals
    begin

        gen_muxes: for i in 0 to bits-1 generate
                    mux2x1: entity work.mux2x1
                                port map(
                                    i_a => i_a(i),
                                    i_b => i_b(i),
                                    i_sel => i_sel,
                                    o_out => o_out(i)
                                );
                end generate;

end rtl;