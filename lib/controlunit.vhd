----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: controlunit.vhd
-- Description: Top-level Control Unit that structurally connects the 
--              opcode decoder and the control signal generator.
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity controlunit is
    port(
        i_opcode   : in  std_logic_vector(5 downto 0);
        i_zero     : in  std_logic;
        o_RegDst   : out std_logic;
        o_MemRead  : out std_logic;
        o_MemToReg : out std_logic;
        o_MemWrite : out std_logic;
        o_ALUSrc   : out std_logic;
        o_RegWrite : out std_logic;
        o_Branch   : out std_logic;
        o_ALUOp    : out std_logic_vector(1 downto 0);
        o_Jump : out std_logic
    );
end controlunit;

architecture structural of controlunit is

    -- Internal signals to connect the decoder to the generator
    signal int_Rtype        : std_logic;
    signal int_Itype        : std_logic;
    signal int_lw           : std_logic;
    signal int_sw           : std_logic;
    signal int_Jtype        : std_logic;
    signal int_Jump         : std_logic;
    signal int_opcode_bit_0 : std_logic;

begin

    -- Instantiate the Decoder
    u_decoder: entity work.controlunitdecoder(rtl)
        port map (
            i_opcode       => i_opcode,
            o_Rtype        => int_Rtype,
            o_Itype        => int_Itype,
            o_lw           => int_lw,
            o_sw           => int_sw,
            o_Jtype        => int_Jtype,
            o_Jump         => int_Jump,
            o_opcode_bit_0 => int_opcode_bit_0
        );

    -- Instantiate the Signal Generator
    u_generator: entity work.controlunitsignalgenerator(rtl)
        port map (
            i_zero         => i_zero,
            i_Rtype        => int_Rtype,
            i_Itype        => int_Itype,
            i_lw           => int_lw,
            i_sw           => int_sw,
            i_Jtype        => int_Jtype,
            i_Jump         => int_Jump,
            i_opcode_bit_0 => int_opcode_bit_0,
            o_RegDst       => o_RegDst,
            o_MemRead      => o_MemRead,
            o_MemToReg     => o_MemToReg,
            o_MemWrite     => o_MemWrite,
            o_ALUSrc       => o_ALUSrc,
            o_RegWrite     => o_RegWrite,
            o_Branch       => o_Branch,
            o_ALUOp        => o_ALUOp,
            o_Jump => o_Jump
        );


end structural;