----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: ID_EX_register.vhd
-- Description: ID/EX pipeline register for 5-stage pipelined MIPS
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity ID_EX_register is
    port(
        i_clk        : in std_logic;
        i_rstBAR     : in std_logic;
        i_stall      : in std_logic;
        i_flush      : in std_logic;

        -- WB control
        i_RegWrite   : in std_logic;
        i_MemToReg   : in std_logic;
        -- MEM control
        i_Branch     : in std_logic;
        i_MemRead    : in std_logic;
        i_MemWrite   : in std_logic;
        -- EX control
        i_RegDst     : in std_logic;
        i_ALUOp      : in std_logic_vector(1 downto 0);
        i_ALUSrc     : in std_logic;

        -- Data
        i_PC_plus4   : in std_logic_vector(7 downto 0);
        i_ReadData1  : in std_logic_vector(31 downto 0);
        i_ReadData2  : in std_logic_vector(31 downto 0);
        i_SignExtImm : in std_logic_vector(31 downto 0);
        i_rs         : in std_logic_vector(4 downto 0);
        i_rt         : in std_logic_vector(4 downto 0);
        i_rd         : in std_logic_vector(4 downto 0);
        i_func       : in std_logic_vector(5 downto 0);

        -- WB control out
        o_RegWrite   : out std_logic;
        o_MemToReg   : out std_logic;
        -- MEM control out
        o_Branch     : out std_logic;
        o_MemRead    : out std_logic;
        o_MemWrite   : out std_logic;
        -- EX control out
        o_RegDst     : out std_logic;
        o_ALUOp      : out std_logic_vector(1 downto 0);
        o_ALUSrc     : out std_logic;

        -- Data out
        o_PC_plus4   : out std_logic_vector(7 downto 0);
        o_ReadData1  : out std_logic_vector(31 downto 0);
        o_ReadData2  : out std_logic_vector(31 downto 0);
        o_SignExtImm : out std_logic_vector(31 downto 0);
        o_rs         : out std_logic_vector(4 downto 0);
        o_rt         : out std_logic_vector(4 downto 0);
        o_rd         : out std_logic_vector(4 downto 0);
        o_func       : out std_logic_vector(5 downto 0)
    );
end ID_EX_register;

architecture rtl of ID_EX_register is
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

    -- EX control signals
    u_RegDst: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_RegDst,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_RegDst,
            o_qBar     => open
        );

    u_ALUOp: entity work.piponbit
        generic map(bits => 2)
        port map(
            i_in     => i_ALUOp,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_ALUOp
        );

    u_ALUSrc: entity work.dff_ar
        port map(
            i_resetBar => int_rstBAR,
            i_d        => i_ALUSrc,
            i_enable   => int_ld,
            i_clock    => i_clk,
            o_q        => o_ALUSrc,
            o_qBar     => open
        );

    -- Data fields
    u_PC_plus4: entity work.piponbit
        generic map(bits => 8)
        port map(
            i_in     => i_PC_plus4,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_PC_plus4
        );

    u_ReadData1: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_ReadData1,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_ReadData1
        );

    u_ReadData2: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_ReadData2,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_ReadData2
        );

    u_SignExtImm: entity work.piponbit
        generic map(bits => 32)
        port map(
            i_in     => i_SignExtImm,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_SignExtImm
        );

    u_rs: entity work.piponbit
        generic map(bits => 5)
        port map(
            i_in     => i_rs,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_rs
        );

    u_rt: entity work.piponbit
        generic map(bits => 5)
        port map(
            i_in     => i_rt,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_rt
        );

    u_rd: entity work.piponbit
        generic map(bits => 5)
        port map(
            i_in     => i_rd,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_rd
        );

    u_func: entity work.piponbit
        generic map(bits => 6)
        port map(
            i_in     => i_func,
            i_rstBAR => int_rstBAR,
            i_clk    => i_clk,
            i_ld     => int_ld,
            o_out    => o_func
        );

end rtl;
