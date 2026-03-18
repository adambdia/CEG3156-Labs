----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: datapath.vhd
-- Description: datapath file
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity datapath is
    port(
        -- Clock and Reset
        i_clk            : in  std_logic;
        i_rstBAR         : in  std_logic;

        -- Instruction Memory Interface
        i_instruction    : in  std_logic_vector(31 downto 0);
        o_instr_addr     : out std_logic_vector(7 downto 0);  -- 8-bit Address for Instruction Memory
        
        -- Control Signals (Inputs from Control Unit)
        i_RegDst         : in  std_logic;
        i_MemToReg       : in  std_logic;
        i_ALUSrc         : in  std_logic;
        i_RegWrite       : in  std_logic;
        i_Branch         : in  std_logic;
        i_ALUOp          : in  std_logic_vector(1 downto 0);

        -- Data Memory Interface
        i_mem_data_in    : in  std_logic_vector(31 downto 0); -- Word read from Data Memory
        o_mem_addr       : out std_logic_vector(31 downto 0); -- Address to Data Memory
        o_mem_data_out   : out std_logic_vector(31 downto 0); -- Word to be written to Data Memory
        

        -- Status Flags and Debug Outputs
        o_zero           : out std_logic;
        o_mux_out        : out std_logic_vector(31 downto 0); -- Final Write-Back Mux result
        
        -- Control Signal Status Outputs
        o_branch_sig     : out std_logic;                     -- Tap of the Branch signal
        o_memwrite_sig   : out std_logic;                     -- Tap of the MemWrite signal
        o_regwrite_sig   : out std_logic                      -- Tap of the RegWrite signal
    );
end datapath;

architecture rtl of datapath is
-- Signals

    signal int_pc_in : std_logic_vector(7 downto 0);
    signal int_pc_out : std_logic_vector(7 downto 0);
    signal int_next_instr_addr : std_logic_vector(7 downto 0); -- Output of (PC + 4) adder

    signal int_sign_ext_out     : std_logic_vector(31 downto 0); -- Result of the 16-to-32 bit sign extender
    signal int_shifted_out      : std_logic_vector(31 downto 0); -- Result of (Sign-Extended Immediate << 2)
    signal int_branch_addr      : std_logic_vector(7 downto 0);  -- Target address: (PC + 4) + (Offset << 2)

    signal int_w_addr : std_logic_vector(4 downto 0);
    signal int_r1_data : std_logic_vector(31 downto 0);
    signal int_r2_data : std_logic_vector(31 downto 0);
    
    signal int_alu_src_mux_out : std_logic_vector(31 downto 0);
    signal int_alu_result : std_logic_vector(31 downto 0);
    
    signal int_wb_mux_out : std_logic_vector(31 downto 0);


    signal 

    begin

    u_program_counter: entity work.piponbit()
    generic map(
        bits => 8
    )
    port map(
        i_in => int_pc_in,
        i_rstBAR => i_rstBAR,
        i_clk => i_clk,
        i_ld => '1', -- always loading
        o_out => int_pc_out
    );

    o_instr_addr <= int_pc_out;

    u_pc_adder: entity work.fulladdernbit(rtl)
        generic map (
            bits => 8
        )
        port map (
            i_a        => int_pc_out,
            i_b        => x"04",        -- Literal 4 in 8-bit hex
            i_carry    => '0',
            i_subtract => '0',
            o_sum      => int_next_instr_addr,
            o_carry    => open          -- Not required for PC logic
        );

    u_branch_shifter: entity work.shift_left_2(structural)
        port map (
            i_data => int_sign_ext_out, -- Input from sign extender
            o_data => int_shifted_out   -- 32-bit shifted output
        );

    -- This calculates the target address for branch instructions
    u_branch_adder: entity work.fulladdernbit(rtl)
        generic map (
            bits => 8
        )
        port map (
            i_a        => int_next_instr_addr,         -- Result of PC + 4
            i_b        => int_shifted_out(7 downto 0), -- Lower 8 bits of shifted offset
            i_carry    => '0',
            i_subtract => '0',
            o_sum      => int_branch_addr,
            o_carry    => open
        );

    u_branch_mux: entity work.mux2x1nbit(rtl)
        generic map (
            bits => 8
        )
        port map (
            i_a   => int_next_instr_addr,
            i_b   => int_branch_addr,
            i_sel => i_Branch,
            o_out => int_pc_input
        );

    u_regdst_mux: entity work.mux2x1nbit(rtl)
        generic map (
            bits => 5
        )
        port map (
            i_a   => i_instruction(20 downto 16),
            i_b   => i_instruction(15 downto 11),
            i_sel => i_RegDst,
            o_out => int_w_addr
        );

    u_reg_file: entity work.register_file(structural)
        port map (
            i_clk      => i_clk,
            i_rstBAR   => i_rstBAR,
            i_regWrite => i_RegWrite,
            i_w_addr   => int_w_addr,             -- Selected by mux above
            i_w_data   => int_wb_mux_out,         -- Data from Write-Back Mux
            i_r1_addr  => i_instruction(25 downto 21), -- 'rs' field
            i_r2_addr  => i_instruction(20 downto 16), -- 'rt' field
            o_r1_data  => int_r1_data,
            o_r2_data  => int_r2_data
        );

     u_sign_ext: entity work.sign_extender(structural)
        port map (
            i_data => i_instruction(15 downto 0),
            o_data => int_sign_ext_out
        );

    u_alusrc_mux: entity work.mux2x1nbit(rtl)
        generic map (
            bits => 32
        )
        port map (
            i_a   => int_r2_data,
            i_b   => int_sign_ext_out,
            i_sel => i_ALUSrc,
            o_out => int_alu_src_mux_out
        );

    u_alu: entity work.alu(rtl)
        generic map (
            bits => 32
        )
        port map (
            i_input1   => int_r1_data,
            i_input2   => int_alu_src_mux_out,
            i_ALUOP    => i_ALUOp,
            i_func     => i_instruction(5 downto 0),
            o_output   => int_alu_result,
            o_zero     => o_zero,           -- Map to top-level port
            o_carryOut => open              -- Carry out not used in control flow
        );

    -- Route ALU result to top-level Data Memory address port
    o_mem_addr <= int_alu_result;

    u_wb_mux: entity work.mux2x1nbit(rtl)
        generic map (
            bits => 32
        )
        port map (
            i_a   => i_mem_data_in,
            i_b   => int_alu_result,
            i_sel => i_MemToReg,
            o_out => int_wb_mux_out
        );


end rtl;