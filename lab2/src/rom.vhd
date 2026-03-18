----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: template.vhd
-- Description: template file
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity rom is
    port(
        i_address : in std_logic_vector(4 downto 0);
        o_value : out std_logic_vector(31 downto 0)
    );
end rom;

architecture rtl of rom is
-- Signals
begin
        mux32x1nbit_inst: entity work.mux32x1nbit
generic map (
  bits => 32
)
    port map (
        i_0   => x"8C020000",
        i_1   => x"8C030001",
        i_2   => x"00430822",
        i_3   => x"00232025",
        i_4   => x"AC040003",
        i_5   => x"00430820",
        i_6   => x"AC010004",
        i_7   => x"8C020003",
        i_8   => x"0800000B",
        i_9   => x"1021FFF5",
        i_10  => x"1022FFFE",
        i_11  => x"1021FFF7",
        i_12  => x"00000000",
        i_13  => x"00000000",
        i_14  => x"00000000",
        i_15  => x"00000000",
        i_16  => x"00000000",
        i_17  => x"00000000",
        i_18  => x"00000000",
        i_19  => x"00000000",
        i_20  => x"00000000",
        i_21  => x"00000000",
        i_22  => x"00000000",
        i_23  => x"00000000",
        i_24  => x"00000000",
        i_25  => x"00000000",
        i_26  => x"00000000",
        i_27  => x"00000000",
        i_28  => x"00000000",
        i_29  => x"00000000",
        i_30  => x"00000000",
        i_31  => x"00000000",
        i_sel => i_address,
        o_out => o_value
    );

end rtl;