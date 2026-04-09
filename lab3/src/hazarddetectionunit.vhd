----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: hazarddetectionunit.vhd
-- Description: Detects load-use data hazards and generates a stall
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity hazarddetectionunit is
    port(
        i_IDEX_MemRead : in  std_logic;
        i_IDEX_Rt      : in  std_logic_vector(4 downto 0);
        i_IFID_Rs      : in  std_logic_vector(4 downto 0);
        i_IFID_Rt      : in  std_logic_vector(4 downto 0);
        o_stall        : out std_logic
    );
end hazarddetectionunit;

architecture rtl of hazarddetectionunit is
    signal int_eq_rs : std_logic;
    signal int_eq_rt : std_logic;
    signal int_match : std_logic;
begin

    comp_rs: entity work.comparatornbit
        generic map(bits => 5)
        port map(
            i_A  => i_IDEX_Rt,
            i_B  => i_IFID_Rs,
            o_GT => open,
            o_LT => open,
            o_EQ => int_eq_rs
        );

    comp_rt: entity work.comparatornbit
        generic map(bits => 5)
        port map(
            i_A  => i_IDEX_Rt,
            i_B  => i_IFID_Rt,
            o_GT => open,
            o_LT => open,
            o_EQ => int_eq_rt
        );

    int_match <= int_eq_rs OR int_eq_rt;
    o_stall   <= i_IDEX_MemRead AND int_match;

end rtl;
