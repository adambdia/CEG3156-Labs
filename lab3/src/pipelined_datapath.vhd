----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: pipelined_datapath.vhd
-- Description: 5-stage pipelined MIPS datapath with forwarding,
--              hazard detection, and branch/jump flush logic
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity pipelined_datapath is
    port(
        i_clk            : in  std_logic;
        i_rstBAR         : in  std_logic;

        -- Instruction Memory Interface
        o_instr_addr     : out std_logic_vector(7 downto 0);
        i_instruction    : in  std_logic_vector(31 downto 0);

        -- Data Memory Interface
        o_mem_addr       : out std_logic_vector(7 downto 0);
        o_mem_data_out   : out std_logic_vector(31 downto 0);
        o_mem_wren       : out std_logic;
        i_mem_data_in    : in  std_logic_vector(31 downto 0);

        -- Monitoring outputs
        o_pc             : out std_logic_vector(7 downto 0);
        o_alu_result     : out std_logic_vector(7 downto 0);
        o_read_data1     : out std_logic_vector(7 downto 0);
        o_read_data2     : out std_logic_vector(7 downto 0);
        o_zero           : out std_logic;
        o_branch_sig     : out std_logic;
        o_memwrite_sig   : out std_logic;
        o_regwrite_sig   : out std_logic;

        -- Instruction at each pipeline stage
        o_instr_if       : out std_logic_vector(31 downto 0);
        o_instr_id       : out std_logic_vector(31 downto 0);
        o_instr_ex       : out std_logic_vector(31 downto 0);
        o_instr_mem      : out std_logic_vector(31 downto 0);
        o_instr_wb       : out std_logic_vector(31 downto 0);

        -- Write-back data low byte
        o_wb_data        : out std_logic_vector(7 downto 0)
    );
end pipelined_datapath;

architecture rtl of pipelined_datapath is

    -- IF stage
    signal int_clk_bar       : std_logic;
    signal int_pc_out        : std_logic_vector(7 downto 0);
    signal int_pc_in         : std_logic_vector(7 downto 0);
    signal int_pc_plus4      : std_logic_vector(7 downto 0);
    signal int_stall         : std_logic;
    signal int_pc_ld         : std_logic;
    signal int_branch_mux_out: std_logic_vector(7 downto 0);

    -- IF/ID register outputs
    signal ifid_pc_plus4     : std_logic_vector(7 downto 0);
    signal ifid_instruction  : std_logic_vector(31 downto 0);

    -- ID stage control
    signal int_ctrl_regwrite : std_logic;
    signal int_ctrl_memtoreg : std_logic;
    signal int_ctrl_branch   : std_logic;
    signal int_ctrl_memread  : std_logic;
    signal int_ctrl_memwrite : std_logic;
    signal int_ctrl_regdst   : std_logic;
    signal int_ctrl_aluop    : std_logic_vector(1 downto 0);
    signal int_ctrl_alusrc   : std_logic;
    signal int_ctrl_jump     : std_logic;

    -- ID stage data
    signal int_r1_data       : std_logic_vector(31 downto 0);
    signal int_r2_data       : std_logic_vector(31 downto 0);
    signal int_r1_fwd        : std_logic_vector(31 downto 0);
    signal int_r2_fwd        : std_logic_vector(31 downto 0);
    signal int_wb_fwd_r1     : std_logic;
    signal int_wb_fwd_r2     : std_logic;
    signal int_cmp_wb_rs     : std_logic;
    signal int_cmp_wb_rt     : std_logic;
    signal int_memwb_wr_nz   : std_logic;
    signal int_sign_ext      : std_logic_vector(31 downto 0);
    signal int_jump_addr     : std_logic_vector(7 downto 0);

    -- Flush / stall
    signal int_branch_taken  : std_logic;
    signal int_ifid_flush    : std_logic;
    signal int_idex_flush    : std_logic;
    signal int_ifid_stall    : std_logic;

    -- Gated control signals for ID/EX (NOP bubble on flush/stall)
    signal int_idex_regwrite_in  : std_logic;
    signal int_idex_memtoreg_in  : std_logic;
    signal int_idex_branch_in    : std_logic;
    signal int_idex_memread_in   : std_logic;
    signal int_idex_memwrite_in  : std_logic;
    signal int_idex_regdst_in    : std_logic;
    signal int_idex_aluop_in     : std_logic_vector(1 downto 0);
    signal int_idex_alusrc_in    : std_logic;

    -- ID/EX register outputs
    signal idex_regwrite     : std_logic;
    signal idex_memtoreg     : std_logic;
    signal idex_branch       : std_logic;
    signal idex_memread      : std_logic;
    signal idex_memwrite     : std_logic;
    signal idex_regdst       : std_logic;
    signal idex_aluop        : std_logic_vector(1 downto 0);
    signal idex_alusrc       : std_logic;
    signal idex_pc_plus4     : std_logic_vector(7 downto 0);
    signal idex_readdata1    : std_logic_vector(31 downto 0);
    signal idex_readdata2    : std_logic_vector(31 downto 0);
    signal idex_signextimm   : std_logic_vector(31 downto 0);
    signal idex_rs           : std_logic_vector(4 downto 0);
    signal idex_rt           : std_logic_vector(4 downto 0);
    signal idex_rd           : std_logic_vector(4 downto 0);
    signal idex_func         : std_logic_vector(5 downto 0);

    -- EX stage
    signal int_writereg_ex   : std_logic_vector(4 downto 0);
    signal int_forward_a     : std_logic_vector(1 downto 0);
    signal int_forward_b     : std_logic_vector(1 downto 0);
    signal int_alu_input1    : std_logic_vector(31 downto 0);
    signal int_fwd_rd2       : std_logic_vector(31 downto 0);
    signal int_alu_input2    : std_logic_vector(31 downto 0);
    signal int_alu_result    : std_logic_vector(31 downto 0);
    signal int_alu_zero      : std_logic;
    signal int_shifted_imm   : std_logic_vector(31 downto 0);
    signal int_branch_target : std_logic_vector(7 downto 0);
    signal int_wb_data       : std_logic_vector(31 downto 0);

    -- EX/MEM register outputs
    signal exmem_regwrite    : std_logic;
    signal exmem_memtoreg    : std_logic;
    signal exmem_branch      : std_logic;
    signal exmem_memread     : std_logic;
    signal exmem_memwrite    : std_logic;
    signal exmem_branchtarget: std_logic_vector(7 downto 0);
    signal exmem_zero        : std_logic;
    signal exmem_aluresult   : std_logic_vector(31 downto 0);
    signal exmem_writedata   : std_logic_vector(31 downto 0);
    signal exmem_writereg    : std_logic_vector(4 downto 0);

    -- MEM/WB register outputs
    signal memwb_regwrite    : std_logic;
    signal memwb_memtoreg    : std_logic;
    signal memwb_readdata    : std_logic_vector(31 downto 0);
    signal memwb_aluresult   : std_logic_vector(31 downto 0);
    signal memwb_writereg    : std_logic_vector(4 downto 0);

begin

    ---------------------------------------------------------------
    -- Glue logic (concurrent assignments)
    ---------------------------------------------------------------
    int_clk_bar      <= NOT i_clk;
    int_pc_ld        <= NOT int_stall;
    int_branch_taken <= exmem_branch AND exmem_zero;
    int_ifid_flush   <= int_branch_taken OR int_ctrl_jump;
    int_idex_flush   <= int_branch_taken OR int_stall OR int_ctrl_jump;
    int_ifid_stall   <= int_stall;
    int_jump_addr    <= ifid_instruction(5 downto 0) & "00";

    -- Gate control signals entering ID/EX: force to 0 on flush (NOP bubble)
    int_idex_regwrite_in <= int_ctrl_regwrite AND (NOT int_idex_flush);
    int_idex_memtoreg_in <= int_ctrl_memtoreg AND (NOT int_idex_flush);
    int_idex_branch_in   <= int_ctrl_branch   AND (NOT int_idex_flush);
    int_idex_memread_in  <= int_ctrl_memread  AND (NOT int_idex_flush);
    int_idex_memwrite_in <= int_ctrl_memwrite AND (NOT int_idex_flush);
    int_idex_regdst_in   <= int_ctrl_regdst   AND (NOT int_idex_flush);
    int_idex_aluop_in(1) <= int_ctrl_aluop(1) AND (NOT int_idex_flush);
    int_idex_aluop_in(0) <= int_ctrl_aluop(0) AND (NOT int_idex_flush);
    int_idex_alusrc_in   <= int_ctrl_alusrc   AND (NOT int_idex_flush);

    ---------------------------------------------------------------
    -- PC next-address muxes
    ---------------------------------------------------------------
    u_branch_mux: entity work.mux2x1nbit
        generic map(bits => 8)
        port map(
            i_a   => int_pc_plus4,
            i_b   => exmem_branchtarget,
            i_sel => int_branch_taken,
            o_out => int_branch_mux_out
        );

    u_jump_mux: entity work.mux2x1nbit
        generic map(bits => 8)
        port map(
            i_a   => int_branch_mux_out,
            i_b   => int_jump_addr,
            i_sel => int_ctrl_jump,
            o_out => int_pc_in
        );

    ---------------------------------------------------------------
    -- IF Stage
    ---------------------------------------------------------------
    u_pc: entity work.piponbit
        generic map(bits => 8)
        port map(
            i_in     => int_pc_in,
            i_rstBAR => i_rstBAR,
            i_clk    => int_clk_bar,
            i_ld     => int_pc_ld,
            o_out    => int_pc_out
        );

    u_pc_adder: entity work.fulladdernbit
        generic map(bits => 8)
        port map(
            i_a        => int_pc_out,
            i_b        => x"04",
            i_carry    => '0',
            i_subtract => '0',
            o_sum      => int_pc_plus4,
            o_carry    => open
        );

    o_instr_addr <= int_pc_out;
    o_pc         <= int_pc_out;

    ---------------------------------------------------------------
    -- IF/ID Register
    ---------------------------------------------------------------
    u_ifid: entity work.IF_ID_register
        port map(
            i_clk         => i_clk,
            i_rstBAR      => i_rstBAR,
            i_stall       => int_ifid_stall,
            i_flush       => int_ifid_flush,
            i_PC_plus4    => int_pc_plus4,
            i_instruction => i_instruction,
            o_PC_plus4    => ifid_pc_plus4,
            o_instruction => ifid_instruction
        );

    ---------------------------------------------------------------
    -- ID Stage
    ---------------------------------------------------------------
    u_ctrl: entity work.pipelined_controlunit
        port map(
            i_opcode   => ifid_instruction(31 downto 26),
            o_RegDst   => int_ctrl_regdst,
            o_MemRead  => int_ctrl_memread,
            o_MemToReg => int_ctrl_memtoreg,
            o_MemWrite => int_ctrl_memwrite,
            o_ALUSrc   => int_ctrl_alusrc,
            o_RegWrite => int_ctrl_regwrite,
            o_Branch   => int_ctrl_branch,
            o_ALUOp    => int_ctrl_aluop,
            o_Jump     => int_ctrl_jump
        );

    u_hazard: entity work.hazarddetectionunit
        port map(
            i_IDEX_MemRead => idex_memread,
            i_IDEX_Rt      => idex_rt,
            i_IFID_Rs      => ifid_instruction(25 downto 21),
            i_IFID_Rt      => ifid_instruction(20 downto 16),
            o_stall        => int_stall
        );

    u_reg_file: entity work.register_file
        port map(
            i_clk      => i_clk,
            i_rstBAR   => i_rstBAR,
            i_regWrite => memwb_regwrite,
            i_w_addr   => memwb_writereg,
            i_w_data   => int_wb_data,
            i_r1_addr  => ifid_instruction(25 downto 21),
            i_r2_addr  => ifid_instruction(20 downto 16),
            o_r1_data  => int_r1_data,
            o_r2_data  => int_r2_data
        );

    u_sign_ext: entity work.sign_extender
        port map(
            i_data => ifid_instruction(15 downto 0),
            o_data => int_sign_ext
        );

    -- WB-to-ID forwarding: if MEM/WB writes to a register that ID
    -- reads in the same cycle, forward int_wb_data to avoid the
    -- register-file write/read race on the same clock edge.
    int_memwb_wr_nz <= memwb_writereg(4) OR memwb_writereg(3) OR
                        memwb_writereg(2) OR memwb_writereg(1) OR
                        memwb_writereg(0);

    u_cmp_wb_rs: entity work.comparatornbit
        generic map(bits => 5)
        port map(
            i_a  => memwb_writereg,
            i_b  => ifid_instruction(25 downto 21),
            o_eq => int_cmp_wb_rs
        );

    u_cmp_wb_rt: entity work.comparatornbit
        generic map(bits => 5)
        port map(
            i_a  => memwb_writereg,
            i_b  => ifid_instruction(20 downto 16),
            o_eq => int_cmp_wb_rt
        );

    int_wb_fwd_r1 <= memwb_regwrite AND int_cmp_wb_rs AND int_memwb_wr_nz;
    int_wb_fwd_r2 <= memwb_regwrite AND int_cmp_wb_rt AND int_memwb_wr_nz;

    u_wb_fwd_r1_mux: entity work.mux2x1nbit
        generic map(bits => 32)
        port map(
            i_a   => int_r1_data,
            i_b   => int_wb_data,
            i_sel => int_wb_fwd_r1,
            o_out => int_r1_fwd
        );

    u_wb_fwd_r2_mux: entity work.mux2x1nbit
        generic map(bits => 32)
        port map(
            i_a   => int_r2_data,
            i_b   => int_wb_data,
            i_sel => int_wb_fwd_r2,
            o_out => int_r2_fwd
        );

    ---------------------------------------------------------------
    -- ID/EX Register
    ---------------------------------------------------------------
    u_idex: entity work.ID_EX_register
        port map(
            i_clk        => i_clk,
            i_rstBAR     => i_rstBAR,
            i_stall      => '0',
            i_flush      => '0',
            i_RegWrite   => int_idex_regwrite_in,
            i_MemToReg   => int_idex_memtoreg_in,
            i_Branch     => int_idex_branch_in,
            i_MemRead    => int_idex_memread_in,
            i_MemWrite   => int_idex_memwrite_in,
            i_RegDst     => int_idex_regdst_in,
            i_ALUOp      => int_idex_aluop_in,
            i_ALUSrc     => int_idex_alusrc_in,
            i_PC_plus4   => ifid_pc_plus4,
            i_ReadData1  => int_r1_fwd,
            i_ReadData2  => int_r2_fwd,
            i_SignExtImm => int_sign_ext,
            i_rs         => ifid_instruction(25 downto 21),
            i_rt         => ifid_instruction(20 downto 16),
            i_rd         => ifid_instruction(15 downto 11),
            i_func       => ifid_instruction(5 downto 0),
            o_RegWrite   => idex_regwrite,
            o_MemToReg   => idex_memtoreg,
            o_Branch     => idex_branch,
            o_MemRead    => idex_memread,
            o_MemWrite   => idex_memwrite,
            o_RegDst     => idex_regdst,
            o_ALUOp      => idex_aluop,
            o_ALUSrc     => idex_alusrc,
            o_PC_plus4   => idex_pc_plus4,
            o_ReadData1  => idex_readdata1,
            o_ReadData2  => idex_readdata2,
            o_SignExtImm => idex_signextimm,
            o_rs         => idex_rs,
            o_rt         => idex_rt,
            o_rd         => idex_rd,
            o_func       => idex_func
        );

    ---------------------------------------------------------------
    -- EX Stage
    ---------------------------------------------------------------

    -- RegDst mux: sel=0 -> Rt, sel=1 -> Rd
    u_regdst_mux: entity work.mux2x1nbit
        generic map(bits => 5)
        port map(
            i_a   => idex_rt,
            i_b   => idex_rd,
            i_sel => idex_regdst,
            o_out => int_writereg_ex
        );

    -- Forwarding unit
    u_fwd: entity work.forwardingunit
        port map(
            i_EXMEM_RegWrite => exmem_regwrite,
            i_MEMWB_RegWrite => memwb_regwrite,
            i_EXMEM_Rd       => exmem_writereg,
            i_MEMWB_Rd       => memwb_writereg,
            i_IDEX_Rs        => idex_rs,
            i_IDEX_Rt        => idex_rt,
            o_ForwardA       => int_forward_a,
            o_ForwardB       => int_forward_b
        );

    -- ForwardA mux (ALU input 1)
    -- "00"->reg file, "01"->WB data, "10"->EX/MEM ALU result
    u_fwda_mux: entity work.mux3x1nbit
        generic map(bits => 32)
        port map(
            i_a   => idex_readdata1,
            i_b   => int_wb_data,
            i_c   => exmem_aluresult,
            i_sel => int_forward_a,
            o_out => int_alu_input1
        );

    -- ForwardB mux (forwarded ReadData2)
    -- "00"->reg file, "01"->WB data, "10"->EX/MEM ALU result
    u_fwdb_mux: entity work.mux3x1nbit
        generic map(bits => 32)
        port map(
            i_a   => idex_readdata2,
            i_b   => int_wb_data,
            i_c   => exmem_aluresult,
            i_sel => int_forward_b,
            o_out => int_fwd_rd2
        );

    -- ALUSrc mux: sel=0 -> forwarded RD2, sel=1 -> sign-extended imm
    u_alusrc_mux: entity work.mux2x1nbit
        generic map(bits => 32)
        port map(
            i_a   => int_fwd_rd2,
            i_b   => idex_signextimm,
            i_sel => idex_alusrc,
            o_out => int_alu_input2
        );

    -- Branch target computation
    u_branch_shifter: entity work.shift_left_2
        port map(
            i_data => idex_signextimm,
            o_data => int_shifted_imm
        );

    u_branch_adder: entity work.fulladdernbit
        generic map(bits => 8)
        port map(
            i_a        => idex_pc_plus4,
            i_b        => int_shifted_imm(7 downto 0),
            i_carry    => '0',
            i_subtract => '0',
            o_sum      => int_branch_target,
            o_carry    => open
        );

    -- ALU
    u_alu: entity work.alu
        generic map(bits => 32)
        port map(
            i_input1   => int_alu_input1,
            i_input2   => int_alu_input2,
            i_ALUOP    => idex_aluop,
            i_func     => idex_func,
            o_output   => int_alu_result,
            o_zero     => int_alu_zero,
            o_carryOut => open
        );

    ---------------------------------------------------------------
    -- EX/MEM Register
    ---------------------------------------------------------------
    u_exmem: entity work.EX_MEM_register
        port map(
            i_clk          => i_clk,
            i_rstBAR       => i_rstBAR,
            i_stall        => '0',
            i_flush        => '0',
            i_RegWrite     => idex_regwrite,
            i_MemToReg     => idex_memtoreg,
            i_Branch       => idex_branch,
            i_MemRead      => idex_memread,
            i_MemWrite     => idex_memwrite,
            i_BranchTarget => int_branch_target,
            i_Zero         => int_alu_zero,
            i_ALUResult    => int_alu_result,
            i_WriteData    => int_fwd_rd2,
            i_WriteReg     => int_writereg_ex,
            o_RegWrite     => exmem_regwrite,
            o_MemToReg     => exmem_memtoreg,
            o_Branch       => exmem_branch,
            o_MemRead      => exmem_memread,
            o_MemWrite     => exmem_memwrite,
            o_BranchTarget => exmem_branchtarget,
            o_Zero         => exmem_zero,
            o_ALUResult    => exmem_aluresult,
            o_WriteData    => exmem_writedata,
            o_WriteReg     => exmem_writereg
        );

    ---------------------------------------------------------------
    -- MEM Stage
    ---------------------------------------------------------------
    o_mem_addr     <= exmem_aluresult(7 downto 0);
    o_mem_data_out <= exmem_writedata;
    o_mem_wren     <= exmem_memwrite;

    ---------------------------------------------------------------
    -- MEM/WB Register
    ---------------------------------------------------------------
    u_memwb: entity work.MEM_WB_register
        port map(
            i_clk       => i_clk,
            i_rstBAR    => i_rstBAR,
            i_stall     => '0',
            i_flush     => '0',
            i_RegWrite  => exmem_regwrite,
            i_MemToReg  => exmem_memtoreg,
            i_ReadData  => i_mem_data_in,
            i_ALUResult => exmem_aluresult,
            i_WriteReg  => exmem_writereg,
            o_RegWrite  => memwb_regwrite,
            o_MemToReg  => memwb_memtoreg,
            o_ReadData  => memwb_readdata,
            o_ALUResult => memwb_aluresult,
            o_WriteReg  => memwb_writereg
        );

    ---------------------------------------------------------------
    -- WB Stage
    ---------------------------------------------------------------
    -- sel=0 -> ALU result (R-type), sel=1 -> mem read data (lw)
    u_wb_mux: entity work.mux2x1nbit
        generic map(bits => 32)
        port map(
            i_a   => memwb_aluresult,
            i_b   => memwb_readdata,
            i_sel => memwb_memtoreg,
            o_out => int_wb_data
        );

    ---------------------------------------------------------------
    -- Monitoring output assignments
    ---------------------------------------------------------------
    o_alu_result   <= int_alu_result(7 downto 0);
    o_read_data1   <= int_r1_data(7 downto 0);
    o_read_data2   <= int_r2_data(7 downto 0);
    o_zero         <= exmem_zero;
    o_branch_sig   <= exmem_branch;
    o_memwrite_sig <= exmem_memwrite;
    o_regwrite_sig <= memwb_regwrite;
    o_wb_data      <= int_wb_data(7 downto 0);

    o_instr_if  <= i_instruction;
    o_instr_id  <= ifid_instruction;
    o_instr_ex  <= (others => '0');
    o_instr_mem <= (others => '0');
    o_instr_wb  <= (others => '0');

end rtl;
