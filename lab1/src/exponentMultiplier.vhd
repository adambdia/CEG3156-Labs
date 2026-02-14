library ieee;
use ieee.std_logic_1164.all;

entity exponentMultiplier is
    generic(
        exponent_bits : positive := 7
    );
    port(
        i_rstBAR, i_clk                     : in std_logic;
        i_sum                               : in std_logic_vector(exponent_bits-1 downto 0);
        i_ld, i_clr                         : in std_logic;
        o_exponentOutput                    : out std_logic_vector(exponent_bits-1 downto 0)
    );
end exponentMultiplier;

architecture rtl of exponentMultiplier is
    signal int_exponentOutput               : std_logic_vector(exponent_bits-1 downto 0);
    signal int_sum                          : std_logic_vector(exponent_bits-1 downto 0);
begin
    piponbit_inst: entity work.piponbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_in     => int_sum,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ld,
      o_out    => int_exponentOutput
    );



    -- Concurrent signals
    gen_int_sum : for i in 0 to exponent_bits-1 generate
        int_sum(i) <= i_sum(i) and (not i_clr);
    end generate gen_int_sum;

    -- Output Drivers
    o_exponentOutput <= int_exponentOutput;

end rtl;