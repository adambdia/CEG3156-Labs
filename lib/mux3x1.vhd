library ieee;
use ieee.std_logic_1164.all;

entity mux3x1 is
    port(
        i_a, i_b, i_c           : in std_logic;
        i_sel                   : in std_logic_vector(1 downto 0);
        o_out                   : out std_logic
    );
end mux3x1;

architecture rtl of mux3x1 is 
begin
    o_out <= ((i_sel(0) nor i_sel(1)) and i_a) or (not i_sel(1) and i_sel(0) and i_b) or (i_sel(1) and not i_sel(0) and i_c);
end rtl;