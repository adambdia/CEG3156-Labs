LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY fpDemo IS
    PORT (
        GClock      : IN  STD_LOGIC;
        GReset      : IN  STD_LOGIC;
        SignOut     : OUT STD_LOGIC;
        ExponentOut : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        MantissaOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE s_fpDemo OF fpDemo IS
    -- Signals for the inputs
    SIGNAL int_SignA    : STD_LOGIC;
    SIGNAL int_ExpA     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL int_ManA     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL int_SignB    : STD_LOGIC;
    SIGNAL int_ExpB     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL int_ManB     : STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN

    -- INSTRUCTIONS:
    -- Uncomment ONE of the test cases below to simulate. 
    -- Ensure all other test cases are commented out.

    ------------------------------------------------------------------
    -- TEST CASE 1: A + B = 3.75
    -- A   =  +1.25 = 0 0111111 01000000
    -- B   =  +2.5  = 0 1000000 01000000
    -- Out =  +3.75 = 0 1000000 11100000
    ------------------------------------------------------------------
    int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    int_SignB <= '1'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    ------------------------------------------------------------------
    -- TEST CASE 2: A - B = -1.25
    -- A   =  +1.25 = 0 0111111 01000000
    -- B   =  -2.5  = 1 1000000 01000000
    -- Out =  -1.25 = 1 0111111 01000000
    -- (Requires Left Normalization)

    -- (If Left Normalization is skipped):
    -- Out =  -3.25 = 1 1000000 10100000
    ------------------------------------------------------------------
    -- int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    -- int_SignB <= '1'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    ------------------------------------------------------------------
    -- TEST CASE 3: A * B = 3.125
    -- A   =  +1.25  = 0 0111111 01000000
    -- B   =  +2.5   = 0 1000000 01000000
    -- Out =  +3.125 = 0 1000000 10010000
    ------------------------------------------------------------------
    -- int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    -- int_SignB <= '0'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    ------------------------------------------------------------------
    -- TEST CASE 4: A * (-B) = -3.125
    -- A   =  +1.25  = 0 0111111 01000000
    -- B   =  -2.5   = 1 1000000 01000000
    -- Out =  -3.125 = 1 1000000 10010000
    ------------------------------------------------------------------
    -- int_SignA <= '0'; int_ExpA <= "0111111"; int_ManA <= "01000000";
    -- int_SignB <= '1'; int_ExpB <= "1000000"; int_ManB <= "01000000";

    toplevel_inst: entity work.topLevel
    generic map (
      mantissa_bits => 8,
      exponent_bits => 7
    )
    port map (
      i_rstBAR         => GReset,
      i_clk            => GClock,
      i_signA          => int_SignA,
      i_signB          => int_SignB,
      i_mantissaA      => int_ManA,
      i_mantissaB      => int_ManB,
      i_exponentA      => int_ExpA,
      i_exponentB      => int_ExpB,
      o_signOutput     => SignOut,
      o_mantissaOutput => MantissaOut,
      o_exponentOutput => ExponentOut
    );


END s_fpDemo;