library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DatapathMultiplier is
    generic(
        mantissa_bits : positive := 8;
        exponent_bits : positive := 7
    );
    port(
        i_rstBAR, i_clk             : in std_logic;
        i_mantissaA, i_mantissaB    : in std_logic_vector(mantissa_bits-1 downto 0);
        i_exponentA, i_exponentB    : in std_logic_vector(exponent_bits-1 downto 0);
        i_signA, i_signB            : in std_logic;

        i_ldInputs                  : in std_logic;
        o_mantissaOutput            : out std_logic_vector(mantissa_bits-1 downto 0);
        o_exponentOutput            : out std_logic_vector(exponent_bits-1 downto 0);
        o_signOutput                : out std_logic;



        i_ldSignificandOutput       : in std_logic;
        i_clrSignificandOutput      : in std_logic;
        i_shiftSignificandOutput    : in std_logic;

        i_sel_adder_input1          : in std_logic;
        i_sel_adder_input2          : in std_logic_vector(1 downto 0);
        control_subtract            : in std_logic;

        i_ldExponentOutput          : in std_logic;
        i_clrExponentOutput         : in std_logic;

        status_significandMSB       : out std_logic;
        status_input_0              : out std_logic
    );
end DatapathMultiplier;

architecture rtl of DatapathMultiplier is
    signal int_significandA_input, int_significandB_input       : std_logic_vector(mantissa_bits downto 0);
    signal int_significandA, int_significandB                   : std_logic_vector(mantissa_bits downto 0);

    signal int_exponentA, int_exponentB                         : std_logic_vector(exponent_bits-1 downto 0);

    signal int_sign                                             : std_logic;

    signal int_test_A_zero, int_test_B_zero                     : std_logic_vector(mantissa_bits+exponent_bits-1 downto 0);
    signal int_A_zero, int_B_zero                               : std_logic;

    signal int_product                                          : std_logic_vector(2*mantissa_bits+1 downto 0);


    signal int_adder_input1, int_adder_input2                   : std_logic_vector(exponent_bits-1 downto 0);
    signal int_sum                                              : std_logic_vector(exponent_bits-1 downto 0);

    signal int_significandOutput                                : std_logic_vector(2*mantissa_bits+1 downto 0);
    signal int_exponentOutput                                   : std_logic_vector(exponent_bits-1 downto 0);




    constant BIAS_INT : integer := 2**(Exponent_bits-1) - 2;
    constant BIAS     : std_logic_vector(exponent_bits-1 downto 0) := std_logic_vector(to_unsigned(BIAS_INT, exponent_bits));
    constant ONE      : std_logic_vector := std_logic_vector(to_unsigned(1,exponent_bits));


begin


    -- Input Registers

    -- Significand Registers --
    mantissaA_reg: entity work.piponbit
    generic map (
      bits => mantissa_bits+1
    )
    port map (
      i_in     => int_significandA_input,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ldInputs,
      o_out    => int_significandA
    );

    mantissaB_reg: entity work.piponbit
    generic map (
      bits => mantissa_bits+1
    )
    port map (
      i_in     => int_significandB_input,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ldInputs,
      o_out    => int_significandB
    );

    -- Exponent Registers --
    exponentA_reg: entity work.piponbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_in     => i_exponentA,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ldInputs,
      o_out    => int_exponentA
    );

    exponentB_reg: entity work.piponbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_in     => i_exponentB,
      i_rstBAR => i_rstBAR,
      i_clk    => i_clk,
      i_ld     => i_ldInputs,
      o_out    => int_exponentB
    );

    -- Sign register --
    signOutput_reg: entity work.dff_ar
    port map (
      i_resetBar => i_rstBAR,
      i_d        => int_sign,
      i_enable   => i_ldInputs,
      i_clock    => i_clk,
      o_q        => o_signOutput,
      o_qBar     => open 
    );

    -- Zero Flags
    zero_flag_A: entity work.zero_flag
    generic map (
      WIDTH => mantissa_bits+exponent_bits
    )
    port map (
      i_data      => int_test_A_zero,
      o_zero_flag => int_A_zero
    );

    zero_flag_B: entity work.zero_flag
    generic map (
      WIDTH => mantissa_bits+exponent_bits
    )
    port map (
      i_data      => int_test_B_zero,
      o_zero_flag => int_B_zero
    );


    -- Product
    arraymultiplier_inst: entity work.arraymultiplier
    generic map (
      bits => mantissa_bits+1
    )
    port map (
      i_M       => int_significandA,
      i_Q       => int_significandB,
      o_product => int_product
    );

    -- SignificandOutput
    significandoutputmultiplier_inst: entity work.significandOutputMultiplier
    generic map (
      product_bits => 2*(mantissa_bits+1)
    )
    port map (
      i_rstBAR            => i_rstBAR,
      i_clk               => i_clk,
      i_product           => int_product,
      i_ld                => i_ldSignificandOutput,
      i_clr               => i_clrSignificandOutput,
      i_shift             => i_shiftSignificandOutput,
      o_significandOutput => int_significandOutput,
      status_MSB          => status_significandMSB
    );


    -- Full adder

    -- adder_input1
    mux2x1nbit_inst: entity work.mux2x1nbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a   => int_exponentA,
      i_b   => int_exponentOutput,
      i_sel => i_sel_adder_input1,
      o_out => int_adder_input1
    );
    -- adder_input2
    adder_input2: entity work.mux3x1nbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a   => int_exponentB,
      i_b   => BIAS,
      i_c   => ONE,
      i_sel => i_sel_adder_input2,
      o_out => int_adder_input2
    );
    fulladdernbit_inst: entity work.fulladdernbit
    generic map (
      bits => exponent_bits
    )
    port map (
      i_a        => int_adder_input1,
      i_b        => int_adder_input2,
      i_carry    => control_subtract,
      i_subtract => control_subtract,
      o_sum      => int_sum,
      o_carry    => open
    );

    exponentoutput_inst: entity work.exponentOutput
    generic map (
      bits => exponent_bits
    )
    port map (
      i_rstBAR         => i_rstBAR,
      i_clk            => i_clk,
      i_input          => int_sum,
      i_ld             => i_ldExponentOutput,
      i_clr            => i_clrExponentOutput,
      o_exponentOutput => int_exponentOutput
    );


    -- Concurrent Signals
    int_significandA_input <= '1' & i_mantissaA;
    int_significandB_input <= '1' & i_mantissaB;

    int_sign <= i_signA xor i_signB;

    int_test_A_zero <= i_mantissaA & i_exponentA;
    int_test_B_zero <= i_mantissaB & i_exponentB;



    -- Output driver
    status_input_0 <= int_A_zero or int_B_zero;

    o_mantissaOutput <= int_significandOutput(2*mantissa_bits downto mantissa_bits+1);

    o_exponentOutput <= int_exponentOutput;
end rtl;
