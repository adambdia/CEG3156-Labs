----------------------------------------------------------------------
-- Authors: Adam Dia and Karim Elsawi
-- Name: forwardingunit.vhd
-- Description: forwarding unit
----------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity forwardingunit is
    port(
        i_EXMEM_RegWrite : in std_logic;
        i_MEMWB_RegWrite : in std_logic;

        i_EXMEM_Rd       : in std_logic_vector(4 downto 0);
        i_MEMWB_Rd       : in std_logic_vector(4 downto 0);
        
        i_IDEX_Rs        : in std_logic_vector(4 downto 0);
        i_IDEX_Rt        : in std_logic_vector(4 downto 0);
        
        o_ForwardA       : out std_logic_vector(1 downto 0);
        o_ForwardB       : out std_logic_vector(1 downto 0)
    );
end forwardingunit;

architecture structural of forwardingunit is

    -- Comparison result signals
    signal int_EXRd_eq_IDRs : std_logic;
    signal int_EXRd_eq_IDRt : std_logic;
    signal int_EXRd_eq_zero : std_logic;
    
    signal int_MEMRd_eq_IDRs : std_logic;
    signal int_MEMRd_eq_IDRt : std_logic;
    signal int_MEMRd_eq_zero : std_logic;

    -- Intermediate logic signals
    signal int_rule1_active : std_logic;
    signal int_rule2_active : std_logic;
    signal int_rule3_base   : std_logic;
    signal int_rule3_active : std_logic;
    signal int_rule4_base   : std_logic;
    signal int_rule4_active : std_logic;

    -- Constant zero for Rd != 0 check
    signal int_zero_vec     : std_logic_vector(4 downto 0) := "00000";

begin


    -- EX Stage Comparisons
    comp_ex_rs: entity work.comparatornbit generic map(5) port map(i_EXMEM_Rd, i_IDEX_Rs, open, open, int_EXRd_eq_IDRs);
    comp_ex_rt: entity work.comparatornbit generic map(5) port map(i_EXMEM_Rd, i_IDEX_Rt, open, open, int_EXRd_eq_IDRt);
    comp_ex_z:  entity work.comparatornbit generic map(5) port map(i_EXMEM_Rd, int_zero_vec, open, open, int_EXRd_eq_zero);

    -- MEM Stage Comparisons
    comp_mem_rs: entity work.comparatornbit generic map(5) port map(i_MEMWB_Rd, i_IDEX_Rs, open, open, int_MEMRd_eq_IDRs);
    comp_mem_rt: entity work.comparatornbit generic map(5) port map(i_MEMWB_Rd, i_IDEX_Rt, open, open, int_MEMRd_eq_IDRt);
    comp_mem_z:  entity work.comparatornbit generic map(5) port map(i_MEMWB_Rd, int_zero_vec, open, open, int_MEMRd_eq_zero);


    -- Rule 1: EX Hazard for Rs (ForwardA = 10)
    int_rule1_active <= i_EXMEM_RegWrite and (not int_EXRd_eq_zero) and int_EXRd_eq_IDRs;

    -- Rule 2: EX Hazard for Rt (ForwardB = 10)
    int_rule2_active <= i_EXMEM_RegWrite and (not int_EXRd_eq_zero) and int_EXRd_eq_IDRt;

    -- Rule 3: MEM Hazard for Rs (ForwardA = 01)
    -- Must check priority: Only true if Rule 1 is NOT active
    int_rule3_base   <= i_MEMWB_RegWrite and (not int_MEMRd_eq_zero) and int_MEMRd_eq_IDRs;
    int_rule3_active <= int_rule3_base and (not int_rule1_active);

    -- Rule 4: MEM Hazard for Rt (ForwardB = 01)
    -- Must check priority: Only true if Rule 2 is NOT active
    int_rule4_base   <= i_MEMWB_RegWrite and (not int_MEMRd_eq_zero) and int_MEMRd_eq_IDRt;
    int_rule4_active <= int_rule4_base and (not int_rule2_active);

    o_ForwardA(1) <= int_rule1_active;
    o_ForwardA(0) <= int_rule3_active;
    o_ForwardB(1) <= int_rule2_active;
    o_ForwardB(0) <= int_rule4_active;

end structural;