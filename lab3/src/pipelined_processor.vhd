----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: pipelined_processor.vhd
-- Description: Top-level 5-stage pipelined MIPS processor
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity pipelinedProc is
    port(
        GClock         : in  std_logic;
        GReset         : in  std_logic;
        ValueSelect    : in  std_logic_vector(2 downto 0);
        InstrSelect    : in  std_logic_vector(2 downto 0);
        MuxOut         : out std_logic_vector(7 downto 0);
        InstructionOut : out std_logic_vector(31 downto 0);
        BranchOut      : out std_logic;
        ZeroOut        : out std_logic;
        MemWriteOut    : out std_logic;
        RegWriteOut    : out std_logic
    );
end pipelinedProc;

architecture rtl of pipelinedProc is
    signal int_instr_addr  : std_logic_vector(7 downto 0);
    signal int_instruction : std_logic_vector(31 downto 0);
    signal int_mem_addr    : std_logic_vector(7 downto 0);
    signal int_mem_data_w  : std_logic_vector(31 downto 0);
    signal int_mem_data_q  : std_logic_vector(31 downto 0);
    signal int_mem_wren    : std_logic;
    signal int_pc          : std_logic_vector(7 downto 0);
    signal int_alu_result  : std_logic_vector(7 downto 0);
    signal int_read_data1  : std_logic_vector(7 downto 0);
    signal int_read_data2  : std_logic_vector(7 downto 0);
    signal int_wb_data     : std_logic_vector(7 downto 0);
    signal int_zero        : std_logic;
    signal int_branch      : std_logic;
    signal int_memwrite    : std_logic;
    signal int_regwrite    : std_logic;
    signal int_instr_if    : std_logic_vector(31 downto 0);
    signal int_instr_id    : std_logic_vector(31 downto 0);
begin

    u_instr_mem: entity work.instruction_memory(rtl)
        port map(
            address => int_instr_addr,
            clock   => GClock,
            q       => int_instruction
        );

    u_datapath: entity work.pipelined_datapath
        port map(
            i_clk          => GClock,
            i_rstBAR       => GReset,
            o_instr_addr   => int_instr_addr,
            i_instruction  => int_instruction,
            o_mem_addr     => int_mem_addr,
            o_mem_data_out => int_mem_data_w,
            o_mem_wren     => int_mem_wren,
            i_mem_data_in  => int_mem_data_q,
            o_pc           => int_pc,
            o_alu_result   => int_alu_result,
            o_read_data1   => int_read_data1,
            o_read_data2   => int_read_data2,
            o_zero         => int_zero,
            o_branch_sig   => int_branch,
            o_memwrite_sig => int_memwrite,
            o_regwrite_sig => int_regwrite,
            o_instr_if     => int_instr_if,
            o_instr_id     => int_instr_id,
            o_instr_ex     => open,
            o_instr_mem    => open,
            o_instr_wb     => open,
            o_wb_data      => int_wb_data
        );

    u_data_mem: entity work.data_memory(rtl)
        port map(
            address => int_mem_addr,
            clock   => GClock,
            data    => int_mem_data_w,
            wren    => int_mem_wren,
            q       => int_mem_data_q
        );

    BranchOut   <= int_branch;
    ZeroOut     <= int_zero;
    MemWriteOut <= int_memwrite;
    RegWriteOut <= int_regwrite;

    with ValueSelect select MuxOut <=
        int_pc                                                    when "000",
        int_alu_result                                            when "001",
        int_read_data1                                            when "010",
        int_read_data2                                            when "011",
        int_wb_data                                               when "100",
        "0000" & int_branch & int_memwrite & "00"                 when others;

    with InstrSelect select InstructionOut <=
        int_instr_if  when "000",
        int_instr_id  when "001",
        (others=>'0') when others;

end rtl;
