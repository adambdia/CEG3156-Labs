----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: shift_left_2.vhd
-- Description: 32-bit Shift Left 2 unit.
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity shift_left_2 is
    port(
        i_data : in  std_logic_vector(31 downto 0);
        o_data : out std_logic_vector(31 downto 0)
    );
end shift_left_2;

architecture structural of shift_left_2 is
begin

    -- Structural Routing:
    -- Bits 31 down to 2 of the output are connected to bits 29 down to 0 of the input.
    o_data(31 downto 2) <= i_data(29 downto 0);

    -- The two least significant bits are tied to ground (logic '0').
    o_data(1) <= '0';
    o_data(0) <= '0';

end structural;