----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: EX_MEM_register.vhd
-- Description: EX/MEM pipeline register for 5-stage pipelined MIPS
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity EX_MEM_register is
    port(
        i_clk          : in std_logic;
        i_rstBAR       : in std_logic;
        i_stall        : in std_logic;
        i_flush        : in std_logic;

        -- WB control
        i_RegWrite     : in std_logic;
        i_MemToReg     : in std_logic;
        -- MEM control
        i_Branch       : in std_logic;
        i_MemRead      : in std_logic;
        i_MemWrite     : in std_logic;

        -- Data
        i_BranchTarget : in std_logic_vector(7 downto 0);
        i_Zero         : in std_logic;
        i_ALUResult    : in std_logic_vector(31 downto 0);
        i_WriteData    : in std_logic_vector(31 downto 0);
        i_WriteReg     : in std_logic_vector(4 downto 0);

        -- WB control out
        o_RegWrite     : out std_logic;
        o_MemToReg     : out std_logic;
        -- MEM control out
        o_Branch       : out std_logic;
        o_MemRead      : out std_logic;
        o_MemWrite     : out std_logic;

        -- Data out
        o_BranchTarget : out std_logic_vector(7 downto 0);
        o_Zero         : out std_logic;
        o_ALUResult    : out std_logic_vector(31 downto 0);
        o_WriteData    : out std_logic_vector(31 downto 0);
        o_WriteReg     : out std_logic_vector(4 downto 0)
    );
end EX_MEM_register;

architecture rtl of EX_MEM_register is
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

    -- MEM control signals
    u_Branch: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_Branch,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_Branch,
            o_qBar     => open
        );

    u_MemRead: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_MemRead,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_MemRead,
            o_qBar     => open
        );

    u_MemWrite: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_MemWrite,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_MemWrite,
            o_qBar     => open
        );

    -- Data fields
    u_BranchTarget: entity work.piponbit
        generic map(bits => 8)
        port map(
            i_in     => i_BranchTarget,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_BranchTarget
        );

    u_Zero: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_Zero,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_Zero,
            o_qBar     => open
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

    u_WriteData: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_WriteData,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_WriteData
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
