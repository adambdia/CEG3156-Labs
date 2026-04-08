----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: MEM_WB_register.vhd
-- Description: MEM/WB pipeline register for 5-stage pipelined MIPS
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity MEM_WB_register is
    port(
        i_clk       : in std_logic;
        i_rstBAR    : in std_logic;
        i_stall     : in std_logic;
        i_flush     : in std_logic;

        -- WB control
        i_RegWrite  : in std_logic;
        i_MemToReg  : in std_logic;

        -- Data
        i_ReadData  : in std_logic_vector(31 downto 0);
        i_ALUResult : in std_logic_vector(31 downto 0);
        i_WriteReg  : in std_logic_vector(4 downto 0);

        -- WB control out
        o_RegWrite  : out std_logic;
        o_MemToReg  : out std_logic;

        -- Data out
        o_ReadData  : out std_logic_vector(31 downto 0);
        o_ALUResult : out std_logic_vector(31 downto 0);
        o_WriteReg  : out std_logic_vector(4 downto 0)
    );
end MEM_WB_register;

architecture rtl of MEM_WB_register is
    signal int_rstBAR : std_logic;
    signal int_ld     : std_logic;
begin

    int_rstBAR <= i_rstBAR AND (NOT i_flush);
    int_ld     <= NOT i_stall;

    -- WB control signals
    u_RegWrite: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_RegWrite,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_RegWrite,
            o_qBar     => open
        );

    u_MemToReg: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_MemToReg,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_MemToReg,
            o_qBar     => open
        );

    -- Data fields
    u_ReadData: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_ReadData,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_ReadData
        );

    u_ALUResult: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_ALUResult,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_ALUResult
        );

    u_WriteReg: entity work.piponbit
        generic map(bits => 5)
        port map(
            i_in     => i_WriteReg,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_WriteReg
        );

end rtl;
