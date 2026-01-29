LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;

entity exponent is
    generic(bits : positive := 7);
    port(
        i_rstBAR, i_clk     : IN STD_LOGIC;
        i_exponent         : IN STD_LOGIC_VECTOR(bits-1 downto 0);
        i_exponentSwap         : IN STD_LOGIC_VECTOR(bits-1 downto 0);
        i_swap, i_ld        : IN STD_LOGIC;
        o_exponent         : OUT STD_LOGIC_VECTOR(bits-1 downto 0)
    );
end exponent;

architecture rtl of exponent is
    signal int_mux          : STD_LOGIC_VECTOR(bits-1 downto 0);
    signal int_ld           : STD_LOGIC;
    signal int_output       : STD_LOGIC_VECTOR(bits-1 downto 0);

begin
    mux_21 : entity work.mux2x1nbit
        port map(
            i_a => i_exponent,
            i_b => i_exponentSwap,
            i_sel => i_swap,
            o_out => int_mux);

    piponbit_inst: entity work.piponbit
    generic map (
      bits => bits
    )
    port map (
      i_in     => int_mux,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => int_ld,
      o_out    => int_output
    );

    -- Concurrent drivers
    int_ld <= i_ld or i_swap;
    -- Output Drivers
    o_exponent <= int_output;


end rtl;