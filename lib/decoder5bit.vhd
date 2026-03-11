----------------------------------------------------------------------
-- Authors : Akram Atassi and Adam Dia
-- Name: decoder5bit.vhd
-- Description: 5-to-32 bit decoder using vector input and output.
--              Implemented using strictly structural binary operators.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity decoder5bit is
    port(
        i_en  : in  std_logic;
        i_sel : in  std_logic_vector(4 downto 0);
        o_y   : out std_logic_vector(31 downto 0)
    );
end decoder5bit;

architecture structural of decoder5bit is
    -- Internal signals for inverted bits of the input vector
    signal int_n : std_logic_vector(4 downto 0);
begin

    -- Inverters for each bit of the selection vector
    int_n(4) <= not i_sel(4);
    int_n(3) <= not i_sel(3);
    int_n(2) <= not i_sel(2);
    int_n(1) <= not i_sel(1);
    int_n(0) <= not i_sel(0);

    -- Decoder Logic: Each output is a minterm gated by i_en
    o_y(0)  <= i_en and int_n(4) and int_n(3) and int_n(2) and int_n(1) and int_n(0);
    o_y(1)  <= i_en and int_n(4) and int_n(3) and int_n(2) and int_n(1) and i_sel(0);
    o_y(2)  <= i_en and int_n(4) and int_n(3) and int_n(2) and i_sel(1) and int_n(0);
    o_y(3)  <= i_en and int_n(4) and int_n(3) and int_n(2) and i_sel(1) and i_sel(0);
    o_y(4)  <= i_en and int_n(4) and int_n(3) and i_sel(2) and int_n(1) and int_n(0);
    o_y(5)  <= i_en and int_n(4) and int_n(3) and i_sel(2) and int_n(1) and i_sel(0);
    o_y(6)  <= i_en and int_n(4) and int_n(3) and i_sel(2) and i_sel(1) and int_n(0);
    o_y(7)  <= i_en and int_n(4) and int_n(3) and i_sel(2) and i_sel(1) and i_sel(0);
    
    o_y(8)  <= i_en and int_n(4) and i_sel(3) and int_n(2) and int_n(1) and int_n(0);
    o_y(9)  <= i_en and int_n(4) and i_sel(3) and int_n(2) and int_n(1) and i_sel(0);
    o_y(10) <= i_en and int_n(4) and i_sel(3) and int_n(2) and i_sel(1) and int_n(0);
    o_y(11) <= i_en and int_n(4) and i_sel(3) and int_n(2) and i_sel(1) and i_sel(0);
    o_y(12) <= i_en and int_n(4) and i_sel(3) and i_sel(2) and int_n(1) and int_n(0);
    o_y(13) <= i_en and int_n(4) and i_sel(3) and i_sel(2) and int_n(1) and i_sel(0);
    o_y(14) <= i_en and int_n(4) and i_sel(3) and i_sel(2) and i_sel(1) and int_n(0);
    o_y(15) <= i_en and int_n(4) and i_sel(3) and i_sel(2) and i_sel(1) and i_sel(0);
    
    o_y(16) <= i_en and i_sel(4) and int_n(3) and int_n(2) and int_n(1) and int_n(0);
    o_y(17) <= i_en and i_sel(4) and int_n(3) and int_n(2) and int_n(1) and i_sel(0);
    o_y(18) <= i_en and i_sel(4) and int_n(3) and int_n(2) and i_sel(1) and int_n(0);
    o_y(19) <= i_en and i_sel(4) and int_n(3) and int_n(2) and i_sel(1) and i_sel(0);
    o_y(20) <= i_en and i_sel(4) and int_n(3) and i_sel(2) and int_n(1) and int_n(0);
    o_y(21) <= i_en and i_sel(4) and int_n(3) and i_sel(2) and int_n(1) and i_sel(0);
    o_y(22) <= i_en and i_sel(4) and int_n(3) and i_sel(2) and i_sel(1) and int_n(0);
    o_y(23) <= i_en and i_sel(4) and int_n(3) and i_sel(2) and i_sel(1) and i_sel(0);
    
    o_y(24) <= i_en and i_sel(4) and i_sel(3) and int_n(2) and int_n(1) and int_n(0);
    o_y(25) <= i_en and i_sel(4) and i_sel(3) and int_n(2) and int_n(1) and i_sel(0);
    o_y(26) <= i_en and i_sel(4) and i_sel(3) and int_n(2) and i_sel(1) and int_n(0);
    o_y(27) <= i_en and i_sel(4) and i_sel(3) and int_n(2) and i_sel(1) and i_sel(0);
    o_y(28) <= i_en and i_sel(4) and i_sel(3) and i_sel(2) and int_n(1) and int_n(0);
    o_y(29) <= i_en and i_sel(4) and i_sel(3) and i_sel(2) and int_n(1) and i_sel(0);
    o_y(30) <= i_en and i_sel(4) and i_sel(3) and i_sel(2) and i_sel(1) and int_n(0);
    o_y(31) <= i_en and i_sel(4) and i_sel(3) and i_sel(2) and i_sel(1) and i_sel(0);

end structural;