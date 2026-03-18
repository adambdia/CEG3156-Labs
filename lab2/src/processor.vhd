----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: processor.vhd
-- Description: datapath + control unit + ram + rom
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor IS
    PORT(
        i_clk    : IN std_logic;
        i_rstBAR : IN std_logic;
        
        -- Top-level Monitoring Taps
        o_instruction_tap : OUT std_logic_vector(31 downto 0); -- Current instruction
        o_zero_flag       : OUT std_logic;
        o_branch_tap      : OUT std_logic;
        o_memwrite_tap    : OUT std_logic;
        o_regwrite_tap    : OUT std_logic;
        o_jump_tap : out std_logic;
        o_jump_addr : out std_logic_vector(7 downto 0)
    );
END processor;

ARCHITECTURE structural OF processor IS

    -- Instruction Bus Signals
    signal int_instr_addr  : std_logic_vector(7 downto 0);
    signal int_instruction : std_logic_vector(31 downto 0);
    signal int_opcode      : std_logic_vector(5 downto 0);

    -- Control Signals
    signal int_RegDst      : std_logic;
    signal int_MemRead     : std_logic;
    signal int_MemToReg    : std_logic;
    signal int_MemWrite    : std_logic;
    signal int_ALUSrc      : std_logic;
    signal int_RegWrite    : std_logic;
    signal int_Branch      : std_logic;
    signal int_ALUOp       : std_logic_vector(1 downto 0);
    signal int_Jump : std_logic;
    signal int_zero        : std_logic;
    

    -- Data Memory Bus Signals
    signal int_mem_addr_32 : std_logic_vector(31 downto 0);
    signal int_mem_data_w  : std_logic_vector(31 downto 0);
    signal int_mem_data_q  : std_logic_vector(31 downto 0);

BEGIN

    -- Structural Signal Routing (Wiring)
    int_opcode        <= int_instruction(31 downto 26);
    o_instruction_tap <= int_instruction; -- Direct wire to top level
    o_zero_flag       <= int_zero;
    o_jump_tap <= int_Jump;

    ------------------------------------------------------------------
    -- Instruction Memory
    ------------------------------------------------------------------
    u_instr_mem: entity work.instruction_memory(rtl)
        PORT MAP (
            address => int_instr_addr,
            clock   => i_clk,
            q       => int_instruction
        );

    ------------------------------------------------------------------
    -- Control Unit
    ------------------------------------------------------------------
    u_control: entity work.controlunit(structural)
        PORT MAP (
            i_opcode   => int_opcode,
            i_zero     => int_zero,
            o_RegDst   => int_RegDst,
            o_MemRead  => int_MemRead,
            o_MemToReg => int_MemToReg,
            o_MemWrite => int_MemWrite,
            o_ALUSrc   => int_ALUSrc,
            o_RegWrite => int_RegWrite,
            o_Branch   => int_Branch,
            o_ALUOp    => int_ALUOp,
            o_Jump => int_Jump
        );

    o_memwrite_tap <= int_MemWrite;
    o_regwrite_tap <= int_RegWrite;
    o_branch_tap <= int_Branch;

    ------------------------------------------------------------------
    -- Datapath
    ------------------------------------------------------------------
    u_datapath: entity work.datapath(rtl)
        PORT MAP (
            i_clk          => i_clk,
            i_rstBAR       => i_rstBAR,
            i_instruction  => int_instruction,
            o_instr_addr   => int_instr_addr,
            
            i_RegDst       => int_RegDst,
            i_MemToReg     => int_MemToReg,
            i_ALUSrc       => int_ALUSrc,
            i_RegWrite     => int_RegWrite,
            i_Branch       => int_Branch,
            i_ALUOp        => int_ALUOp,
            i_Jump => int_Jump,

            i_mem_data_in  => int_mem_data_q,
            o_mem_addr     => int_mem_addr_32,
            o_mem_data_out => int_mem_data_w,

            o_zero         => int_zero,
            o_jump_addr => o_jump_addr
        );

    ------------------------------------------------------------------
    -- Data Memory
    ------------------------------------------------------------------
    u_data_mem: entity work.data_memory(rtl)
        PORT MAP (
            address => int_mem_addr_32(7 downto 0),
            clock   => i_clk,
            data    => int_mem_data_w,
            wren    => int_MemWrite,
            q       => int_mem_data_q
        );

END structural;