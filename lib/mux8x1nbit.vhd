----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: mux8x1nbit.vhd
-- Description: 8x1 N-bit Multiplexer
-- Structure: Two 4x1 Muxes and one 2x1 Mux
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux8x1nbit is
    generic (bits : positive := 8);
    port(
        i_0   : in  std_logic_vector(bits-1 downto 0);
        i_1   : in  std_logic_vector(bits-1 downto 0);
        i_2   : in  std_logic_vector(bits-1 downto 0);
        i_3   : in  std_logic_vector(bits-1 downto 0);
        i_4   : in  std_logic_vector(bits-1 downto 0);
        i_5   : in  std_logic_vector(bits-1 downto 0);
        i_6   : in  std_logic_vector(bits-1 downto 0);
        i_7   : in  std_logic_vector(bits-1 downto 0);
        i_sel : in  std_logic_vector(2 downto 0);
        o_out : out std_logic_vector(bits-1 downto 0)
    );
end mux8x1nbit;

architecture structural of mux8x1nbit is

    -- Internal signals to connect the stages
    signal int_mux_low  : std_logic_vector(bits-1 downto 0);
    signal int_mux_high : std_logic_vector(bits-1 downto 0);

begin

    -- Lower Half Mux (Selects between 0, 1, 2, 3)
    u_mux_low: entity work.mux4x1nbit(rtl)
        generic map (bits => bits)
        port map (
            i_a   => i_0,
            i_b   => i_1,
            i_c   => i_2,
            i_d   => i_3,
            i_sel => i_sel(1 downto 0),
            o_out => int_mux_low
        );

    -- Upper Half Mux (Selects between 4, 5, 6, 7)
    u_mux_high: entity work.mux4x1nbit(rtl)
        generic map (bits => bits)
        port map (
            i_a   => i_4,
            i_b   => i_5,
            i_c   => i_6,
            i_d   => i_7,
            i_sel => i_sel(1 downto 0),
            o_out => int_mux_high
        );

    -- Final Stage Mux (Selects between Low and High results)
    -- i_sel(2) acts as the bridge
    u_mux_final: entity work.mux2x1nbit(rtl)
        generic map (bits => bits)
        port map (
            i_a   => int_mux_low,
            i_b   => int_mux_high,
            i_sel => i_sel(2),
            o_out => o_out
        );

end structural;