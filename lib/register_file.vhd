----------------------------------------------------------------------
-- Authors: Akram Atassi and Adam Dia
-- Name: register_file.vhd
-- Description: 32x32 Register File, 1 Decoder, 32 PIPOs, 2 32x1 Muxes
----------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity register_file is
    port(
        i_clk        : in  std_logic;
        i_rstBAR     : in  std_logic;
        i_regWrite   : in  std_logic;
        i_w_addr     : in  std_logic_vector(4 downto 0);
        i_w_data     : in  std_logic_vector(31 downto 0);
        i_r1_addr    : in  std_logic_vector(4 downto 0);
        i_r2_addr    : in  std_logic_vector(4 downto 0);
        o_r1_data    : out std_logic_vector(31 downto 0);
        o_r2_data    : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture structural of register_file is

    -- Decoder output for write-load signals
    signal int_load : std_logic_vector(31 downto 0);

    -- 32 * 32 = 1024 bits
    signal int_all_reg_outputs : std_logic_vector(1023 downto 0);

begin

    -- Write Decoder: Enabled by i_regWrite
    u_decoder: entity work.decoder5bit(structural)
        port map (
            i_en  => i_regWrite,
            i_sel => i_w_addr,
            o_y   => int_load
        );

    ------------------------------------------------------------------
    -- Register Storage: 32 PIPO instances using a for-generate loop
    ------------------------------------------------------------------
    gen_regs: for i in 0 to 31 generate
        u_pipo: entity work.piponbit(rtl)
            generic map (bits => 32)
            port map (
                i_in     => i_w_data,
                i_rstBAR => i_rstBAR,
                i_clk    => i_clk,
                i_ld     => int_load(i),
                -- Mapping to the i-th 32-bit segment of the flattened bus
                o_out    => int_all_reg_outputs((i*32)+31 downto i*32)
            );
    end generate gen_regs;

    ------------------------------------------------------------------
    -- Read Port 1 Mux
    -- Mapping segments of the flattened bus to individual mux inputs
    ------------------------------------------------------------------
    u_mux_read1: entity work.mux32x1nbit(structural)
        generic map (bits => 32)
        port map (
            i_0  => int_all_reg_outputs(31 downto 0),
            i_1  => int_all_reg_outputs(63 downto 32),
            i_2  => int_all_reg_outputs(95 downto 64),
            i_3  => int_all_reg_outputs(127 downto 96),
            i_4  => int_all_reg_outputs(159 downto 128),
            i_5  => int_all_reg_outputs(191 downto 160),
            i_6  => int_all_reg_outputs(223 downto 192),
            i_7  => int_all_reg_outputs(255 downto 224),
            i_8  => int_all_reg_outputs(287 downto 256),
            i_9  => int_all_reg_outputs(319 downto 288),
            i_10 => int_all_reg_outputs(351 downto 320),
            i_11 => int_all_reg_outputs(383 downto 352),
            i_12 => int_all_reg_outputs(415 downto 384),
            i_13 => int_all_reg_outputs(447 downto 416),
            i_14 => int_all_reg_outputs(479 downto 448),
            i_15 => int_all_reg_outputs(511 downto 480),
            i_16 => int_all_reg_outputs(543 downto 512),
            i_17 => int_all_reg_outputs(575 downto 544),
            i_18 => int_all_reg_outputs(607 downto 576),
            i_19 => int_all_reg_outputs(639 downto 608),
            i_20 => int_all_reg_outputs(671 downto 640),
            i_21 => int_all_reg_outputs(703 downto 672),
            i_22 => int_all_reg_outputs(735 downto 704),
            i_23 => int_all_reg_outputs(767 downto 736),
            i_24 => int_all_reg_outputs(799 downto 768),
            i_25 => int_all_reg_outputs(831 downto 800),
            i_26 => int_all_reg_outputs(863 downto 832),
            i_27 => int_all_reg_outputs(895 downto 864),
            i_28 => int_all_reg_outputs(927 downto 896),
            i_29 => int_all_reg_outputs(959 downto 928),
            i_30 => int_all_reg_outputs(991 downto 960),
            i_31 => int_all_reg_outputs(1023 downto 992),
            i_sel => i_r1_addr,
            o_out => o_r1_data
        );

    ------------------------------------------------------------------
    -- Read Port 2 Mux
    ------------------------------------------------------------------
    u_mux_read2: entity work.mux32x1nbit(structural)
        generic map (bits => 32)
        port map (
            i_0  => int_all_reg_outputs(31 downto 0),
            i_1  => int_all_reg_outputs(63 downto 32),
            i_2  => int_all_reg_outputs(95 downto 64),
            i_3  => int_all_reg_outputs(127 downto 96),
            i_4  => int_all_reg_outputs(159 downto 128),
            i_5  => int_all_reg_outputs(191 downto 160),
            i_6  => int_all_reg_outputs(223 downto 192),
            i_7  => int_all_reg_outputs(255 downto 224),
            i_8  => int_all_reg_outputs(287 downto 256),
            i_9  => int_all_reg_outputs(319 downto 288),
            i_10 => int_all_reg_outputs(351 downto 320),
            i_11 => int_all_reg_outputs(383 downto 352),
            i_12 => int_all_reg_outputs(415 downto 384),
            i_13 => int_all_reg_outputs(447 downto 416),
            i_14 => int_all_reg_outputs(479 downto 448),
            i_15 => int_all_reg_outputs(511 downto 480),
            i_16 => int_all_reg_outputs(543 downto 512),
            i_17 => int_all_reg_outputs(575 downto 544),
            i_18 => int_all_reg_outputs(607 downto 576),
            i_19 => int_all_reg_outputs(639 downto 608),
            i_20 => int_all_reg_outputs(671 downto 640),
            i_21 => int_all_reg_outputs(703 downto 672),
            i_22 => int_all_reg_outputs(735 downto 704),
            i_23 => int_all_reg_outputs(767 downto 736),
            i_24 => int_all_reg_outputs(799 downto 768),
            i_25 => int_all_reg_outputs(831 downto 800),
            i_26 => int_all_reg_outputs(863 downto 832),
            i_27 => int_all_reg_outputs(895 downto 864),
            i_28 => int_all_reg_outputs(927 downto 896),
            i_29 => int_all_reg_outputs(959 downto 928),
            i_30 => int_all_reg_outputs(991 downto 960),
            i_31 => int_all_reg_outputs(1023 downto 992),
            i_sel => i_r2_addr,
            o_out => o_r2_data
        );

end structural;