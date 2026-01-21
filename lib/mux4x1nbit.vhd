----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: mux4x1nbit.vhd
-- Description: we build this with 3 2x1 muxes, one mux is used to switch between the two lower level muxes
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux4x1nbit is
    generic (bits : positive := 8);
    port(
        i_a : in std_logic_vector(bits-1 downto 0);
        i_b : in std_logic_vector(bits-1 downto 0);
        i_c : in std_logic_vector(bits-1 downto 0);
        i_d : in std_logic_vector(bits-1 downto 0);
        i_sel: in std_logic_vector(1 downto 0);
        o_out : out std_logic_vector(bits-1 downto 0));
end mux4x1nbit;

architecture rtl of mux4x1nbit is
-- Signals
    signal int_mux_a_out : std_logic_vector(bits-1 downto 0);
    signal int_mux_b_out : std_logic_vector(bits-1 downto 0);
    begin
        

        mux_a: entity work.mux2x1nbit 
                generic map(bits => bits)
                port map(
                    i_a => i_a,
                    i_b => i_b,
                    i_sel => i_sel(0),
                    o_out => int_mux_a_out
                );

        mux_b: entity work.mux2x1nbit
                generic map(bits => bits)
                port map(
                    i_a => i_c,
                    i_b => i_d,
                    i_sel => i_sel(0),
                    o_out => int_mux_b_out
                );

        -- the higher level mux
        mux_c: entity work.mux2x1nbit
                generic map(bits => bits)
                port map(
                    i_a => int_mux_a_out,
                    i_b => int_mux_b_out,
                    i_sel => i_sel(1),
                    o_out => o_out
                );

end rtl;