----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: controlunitsignalgenerator.vhd
-- Description: uses opcode decoder and zero status signal to generate control signals
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity controlunitsignalgenerator is
    port(
        i_zero : in std_logic;
        i_Rtype        : in std_logic;
        i_Itype        : in std_logic;
        i_lw           : in std_logic;
        i_sw           : in std_logic;
        i_Jtype        : in std_logic;
        i_Jump         : in std_logic;
        i_opcode_bit_0 : in std_logic;
        o_RegDst : out std_logic;
        o_MemRead : out std_logic;
        o_MemToReg : out std_logic;
        o_MemWrite : out std_logic;
        o_ALUSrc : out std_logic;
        o_RegWrite : out std_logic;
        o_Branch : out std_logic;
        o_ALUOp : out std_logic_vector(1 downto 0);
        o_Jump : out std_logic);
end controlunitsignalgenerator;

architecture rtl of controlunitsignalgenerator is
-- Signals

    begin

    o_RegDst <= i_Rtype;
    o_ALUSrc <= i_Itype;
    o_MemToReg <= i_Itype;
    o_RegWrite <= i_Rtype or i_lw;
    o_MemRead <= i_lw;
    o_MemWrite <= i_sw;
    -- supports BNE and BEQ
    o_Branch <= i_Jtype and (i_zero xor i_opcode_bit_0);
    o_ALUOp(1) <= i_Rtype;
    o_ALUOp(0) <= i_Jtype;
    o_Jump <= i_Jump;


end rtl;