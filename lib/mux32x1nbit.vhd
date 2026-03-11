----------------------------------------------------------------------
-- Name: mux32x1nbit.vhd
-- Description: 32x1 N-bit Multiplexer
-- Structure: Two 16x1 Muxes and one 2x1 Mux
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux32x1nbit is
    generic (bits : positive := 8);
    port(
        -- Inputs 0 to 15
        i_0, i_1, i_2, i_3, i_4, i_5, i_6, i_7,
        i_8, i_9, i_10, i_11, i_12, i_13, i_14, i_15 : in std_logic_vector(bits-1 downto 0);
        -- Inputs 16 to 31
        i_16, i_17, i_18, i_19, i_20, i_21, i_22, i_23,
        i_24, i_25, i_26, i_27, i_28, i_29, i_30, i_31 : in std_logic_vector(bits-1 downto 0);
        
        i_sel : in  std_logic_vector(4 downto 0);
        o_out : out std_logic_vector(bits-1 downto 0)
    );
end mux32x1nbit;

architecture structural of mux32x1nbit is

    -- Internal signals to connect the 16x1 stages to the final 2x1 stage
    signal int_mux_low  : std_logic_vector(bits-1 downto 0);
    signal int_mux_high : std_logic_vector(bits-1 downto 0);

begin

    -- Lower Half Mux (Inputs 0-15)
    u_mux_low: entity work.mux16x1nbit(structural)
        generic map (bits => bits)
        port map (
            i_0 => i_0,   i_1 => i_1,   i_2 => i_2,   i_3 => i_3,
            i_4 => i_4,   i_5 => i_5,   i_6 => i_6,   i_7 => i_7,
            i_8 => i_8,   i_9 => i_9,   i_10 => i_10, i_11 => i_11,
            i_12 => i_12, i_13 => i_13, i_14 => i_14, i_15 => i_15,
            i_sel => i_sel(3 downto 0),
            o_out => int_mux_low
        );

    -- Upper Half Mux (Inputs 16-31)
    u_mux_high: entity work.mux16x1nbit(structural)
        generic map (bits => bits)
        port map (
            i_0 => i_16,  i_1 => i_17,  i_2 => i_18,  i_3 => i_19,
            i_4 => i_20,  i_5 => i_21,  i_6 => i_22,  i_7 => i_23,
            i_8 => i_24,  i_9 => i_25,  i_10 => i_26, i_11 => i_27,
            i_12 => i_28, i_13 => i_29, i_14 => i_30, i_15 => i_31,
            i_sel => i_sel(3 downto 0),
            o_out => int_mux_high
        );

    -- Final Stage Mux 
    -- Uses the MSB of the 5-bit selector (i_sel(4))
    u_mux_final: entity work.mux2x1nbit(rtl)
        generic map (bits => bits)
        port map (
            i_a   => int_mux_low,
            i_b   => int_mux_high,
            i_sel => i_sel(4),
            o_out => o_out
        );

end structural;