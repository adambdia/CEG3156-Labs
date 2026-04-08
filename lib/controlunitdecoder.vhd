----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: controlunitdecoder.vhd
-- Description: takes opcodes and figures out what the instruction is
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity controlunitdecoder is
    port(
        i_opcode : in std_logic_vector(5 downto 0);
        o_Rtype : out std_logic;
        o_Itype : out std_logic;
        o_lw : out std_logic;
        o_sw : out std_logic;
        o_Jtype : out std_logic;
        o_Jump : out std_logic;
        o_opcode_bit_0 : out std_logic
        );
end controlunitdecoder;

architecture rtl of controlunitdecoder is
-- Signals
    signal int_lw : std_logic;
    signal int_sw : std_logic;

    begin

    -- Rtype = opcode of 0
    o_Rtype <= not (i_opcode(5) or i_opcode(4) or i_opcode(3) or i_opcode(2) or i_opcode(1) or i_opcode(0));

    -- we need to differentiate between lw (opcode = 35) and sw (opcode = 43) when we generate certain control signals, so we give them their own variables
    int_lw <= i_opcode(5) and (not i_opcode(4)) and (not i_opcode(3)) and (not i_opcode(2)) and i_opcode(1) and i_opcode(0);
    int_sw <= i_opcode(5) and (not i_opcode(4)) and i_opcode(3) and (not i_opcode(2)) and i_opcode(1) and i_opcode(0);
    o_Itype <= int_lw or int_sw;
    o_lw <= int_lw;
    o_sw <= int_sw;

    -- opcode = 4 or 5,, which is why we omit the LSB.
    o_Jtype <= (not i_opcode(5)) and (not i_opcode(4)) and (not i_opcode(3)) and i_opcode(2) and (not i_opcode(1));

    -- opcode = 2
    o_Jump <= (not i_opcode(5)) and (not i_opcode(4)) and (not i_opcode(3)) and (not i_opcode(2)) and i_opcode(1) and (not i_opcode(0));

    -- we need the LSB of the opcode to differentiate between BNE and BEQ when we generate the branch signal later.
    o_opcode_bit_0 <= i_opcode(0);

end rtl;