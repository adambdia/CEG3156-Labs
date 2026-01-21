----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: nbitpipo.vhd
-- Description: n bit parallel in/out register
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity nbitpipo is
    generic (bits : positive := 8);
    port(
        i_in : in std_logic_vector(bits -1 downto 0);
        i_rstBAR: in std_logic;
        i_clk : in std_logic;
        i_ld: in std_logic;
        o_out : out std_logic_vector(bits-1 downto 0));
end nbitpipo;

architecture rtl of nbitpipo is

begin
    
    gen_dffs: for i in 0 to bits-1 generate
        dff: entity work.dff_ar
                port map(
                    i_resetBar	=> i_rstBAR,
		            i_d		=> i_in(i),
		            i_enable => i_ld,
		            i_clock => i_clk,	
		            o_q => o_out(i),
                    o_qBar => open
                );
        end generate;
        

end rtl;