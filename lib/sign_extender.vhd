----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: sign_extender.vhd
-- Description: 16-bit to 32-bit Sign Extender
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity sign_extender is
    port(
        i_data : in  std_logic_vector(15 downto 0);
        o_data : out std_logic_vector(31 downto 0)
    );
end sign_extender;

architecture structural of sign_extender is
begin

    --Lower 16 bits are direct wire connections
    o_data(15 downto 0) <= i_data;

    -- Connect the MSB (i_data(15)) to all upper bits
    gen_sign: for i in 16 to 31 generate
        o_data(i) <= i_data(15);
    end generate gen_sign;

end structural;