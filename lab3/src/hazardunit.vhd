----------------------------------------------------------------------
-- Authors: Adam Dia Karim Elsawi
-- Name: hazardunit.vhd
-- Description: MIPS Hazard Detection Unit (BEQ Only)
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity hazardunit is
    port(
        i_IDEX_MemRead   : in  std_logic;
        i_IDEX_Rt        : in  std_logic_vector(4 downto 0);
        i_IFID_Rs        : in  std_logic_vector(4 downto 0);
        i_IFID_Rt        : in  std_logic_vector(4 downto 0);
        
        i_Branch         : in  std_logic;
        i_OpA            : in  std_logic_vector(31 downto 0);
        i_OpB            : in  std_logic_vector(31 downto 0);

        o_PCWrite        : out std_logic;
        o_IFIDWrite      : out std_logic;
        o_StallMuxSel    : out std_logic;
        o_IFIDFlush      : out std_logic 
    );
end hazardunit;

architecture structural of hazardunit is

    -- Intermediate comparison signals
    signal int_rs_match      : std_logic;
    signal int_rt_match      : std_logic;
    signal int_branch_eq     : std_logic;
    
    -- Logic signals
    signal int_stall         : std_logic;
    signal int_flush         : std_logic;

begin

    ------------------------------------------------------------------
    -- Data Hazard Comparators (5-bit)
    ------------------------------------------------------------------
    
    -- Check if ID/EX.Rt matches IF/ID.Rs
    comp_rs: entity work.comparatornbit
        generic map (bits => 5)
        port map (i_A => i_IDEX_Rt, i_B => i_IFID_Rs, o_EQ => int_rs_match);

    -- Check if ID/EX.Rt matches IF/ID.Rt
    comp_rt: entity work.comparatornbit
        generic map (bits => 5)
        port map (i_A => i_IDEX_Rt, i_B => i_IFID_Rt, o_EQ => int_rt_match);

    ------------------------------------------------------------------
    -- Control Hazard Comparator (32-bit)
    ------------------------------------------------------------------
    
    -- Check equality for BEQ decision
    comp_beq: entity work.comparatornbit
        generic map (bits => 32)
        port map (i_A => i_OpA, i_B => i_OpB, o_EQ => int_branch_eq);

    ------------------------------------------------------------------
    -- Structural Logic (Binary Operators)
    ------------------------------------------------------------------

    -- 1. Stall Logic: Stall if EX stage is a Load AND there is an address match
    int_stall <= i_IDEX_MemRead and (int_rs_match or int_rt_match);

    -- 2. Flush Logic: Branch is active and operands are equal
    int_flush <= i_Branch and int_branch_eq;

    ------------------------------------------------------------------
    -- Output Driver Mapping
    ------------------------------------------------------------------

    o_PCWrite     <= not int_stall;
    o_IFIDWrite   <= not int_stall;
    o_StallMuxSel <= int_stall;
    o_IFIDFlush   <= int_flush;

end structural;