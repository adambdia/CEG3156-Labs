----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: IF_ID_register.vhd
-- Description: IF/ID pipeline register for 5-stage pipelined MIPS
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity IF_ID_register is
    port(
        i_clk         : in std_logic;
        i_rstBAR      : in std_logic;
        i_stall       : in std_logic;
        i_flush       : in std_logic;
        i_PC_plus4    : in std_logic_vector(7 downto 0);
        i_instruction : in std_logic_vector(31 downto 0);
        o_PC_plus4    : out std_logic_vector(7 downto 0);
        o_instruction : out std_logic_vector(31 downto 0)
    );
end IF_ID_register;

architecture rtl of IF_ID_register is
    signal int_rstBAR    : std_logic;
    signal int_ld        : std_logic;
    signal int_pc_in     : std_logic_vector(7 downto 0);
    signal int_instr_in  : std_logic_vector(31 downto 0);
begin

    int_rstBAR <= i_rstBAR;
    int_ld     <= (NOT i_stall) OR i_flush;

    u_flush_mux_pc: entity work.mux2x1nbit
        generic map(bits => 8)
        port map(
            i_a   => i_PC_plus4,
            i_b   => x"00",
            i_sel => i_flush,
            o_out => int_pc_in
        );

    u_flush_mux_instr: entity work.mux2x1nbit
        generic map(bits => 32)
        port map(
            i_a   => i_instruction,
            i_b   => x"00000000",
            i_sel => i_flush,
            o_out => int_instr_in
        );

    u_PC_plus4: entity work.piponbit
        generic map(bits => 8)
        port map(
            i_in     => int_pc_in,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_PC_plus4
        );

    u_instruction: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => int_instr_in,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_instruction
        );

end rtl;
