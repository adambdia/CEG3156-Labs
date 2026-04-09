----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: pipelined_controlunit.vhd
-- Description: Control unit for pipelined MIPS. Same as controlunit
--              but without i_zero; Branch is the raw branch-type flag.
--              The branch-taken decision (Branch AND Zero) is deferred
--              to the MEM stage in the datapath.
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity pipelined_controlunit is
    port(
        i_opcode   : in  std_logic_vector(5 downto 0);
        o_RegDst   : out std_logic;
        o_MemRead  : out std_logic;
        o_MemToReg : out std_logic;
        o_MemWrite : out std_logic;
        o_ALUSrc   : out std_logic;
        o_RegWrite : out std_logic;
        o_Branch   : out std_logic;
        o_ALUOp    : out std_logic_vector(1 downto 0);
        o_Jump     : out std_logic
    );
end pipelined_controlunit;

architecture rtl of pipelined_controlunit is
    signal int_Rtype        : std_logic;
    signal int_Itype        : std_logic;
    signal int_lw           : std_logic;
    signal int_sw           : std_logic;
    signal int_Jtype        : std_logic;
    signal int_Jump         : std_logic;
    signal int_opcode_bit_0 : std_logic;
begin

    u_decoder: entity work.controlunitdecoder
        port map(
            i_opcode       => i_opcode,
            o_Rtype        => int_Rtype,
            o_Itype        => int_Itype,
            o_lw           => int_lw,
            o_sw           => int_sw,
            o_Jtype        => int_Jtype,
            o_Jump         => int_Jump,
            o_opcode_bit_0 => int_opcode_bit_0
        );

    o_RegDst   <= int_Rtype;
    o_ALUSrc   <= int_Itype;
    o_MemToReg <= int_Itype;
    o_RegWrite <= int_Rtype OR int_lw;
    o_MemRead  <= int_lw;
    o_MemWrite <= int_sw;
    o_Branch   <= int_Jtype;
    o_ALUOp(1) <= int_Rtype;
    o_ALUOp(0) <= int_Jtype;
    o_Jump     <= int_Jump;

end rtl;
