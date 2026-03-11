----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: mux16x1nbit.vhd
-- Description: 16x1 N-bit Multiplexer
-- Structure: Two 8x1 Muxes and one 2x1 Mux
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux16x1nbit is
    generic (bits : positive := 8);
    port(
        i_0, i_1, i_2, i_3, i_4, i_5, i_6, i_7     : in std_logic_vector(bits-1 downto 0);
        i_8, i_9, i_10, i_11, i_12, i_13, i_14, i_15 : in std_logic_vector(bits-1 downto 0);
        i_sel : in  std_logic_vector(3 downto 0);
        o_out : out std_logic_vector(bits-1 downto 0)
    );
end mux16x1nbit;

architecture structural of mux16x1nbit is

    -- Internal signals to connect the 8x1 stages to the final 2x1 stage
    signal int_mux_low  : std_logic_vector(bits-1 downto 0);
    signal int_mux_high : std_logic_vector(bits-1 downto 0);

begin

    -- Lower Half Mux (Inputs 0-7)
    u_mux_low: entity work.mux8x1nbit(structural)
        generic map (bits => bits)
        port map (
            i_0   => i_0, i_1 => i_1, i_2 => i_2, i_3 => i_3,
            i_4   => i_4, i_5 => i_5, i_6 => i_6, i_7 => i_7,
            i_sel => i_sel(2 downto 0),
            o_out => int_mux_low
        );

    -- Upper Half Mux (Inputs 8-15)
    u_mux_high: entity work.mux8x1nbit(structural)
        generic map (bits => bits)
        port map (
            i_0   => i_8,  i_1 => i_9,  i_2 => i_10, i_3 => i_11,
            i_4   => i_12, i_5 => i_13, i_6 => i_14, i_7 => i_15,
            i_sel => i_sel(2 downto 0),
            o_out => int_mux_high
        );

    -- Final Stage Mux 
    -- Uses the MSB of the selector (i_sel(3)) to choose between low and high halves
    u_mux_final: entity work.mux2x1nbit(rtl)
        generic map (bits => bits)
        port map (
            i_a   => int_mux_low,
            i_b   => int_mux_high,
            i_sel => i_sel(3),
            o_out => o_out
        );

end structural;