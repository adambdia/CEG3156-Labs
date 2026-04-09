----------------------------------------------------------------------
-- Authors: Karim Elsawi and Adam Dia
-- Name: data_memory.vhd
-- Description: Behavioral data memory stub for GHDL simulation.
--              Replaces the Quartus LPM RAM DQ IP core.
--              Synchronous read/write.
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port(
        address : in  std_logic_vector(7 downto 0);
        clock   : in  std_logic;
        data    : in  std_logic_vector(31 downto 0);
        wren    : in  std_logic;
        q       : out std_logic_vector(31 downto 0)
    );
end data_memory;

architecture rtl of data_memory is
    type ram_t is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_t := (
        0 => x"00000005",  -- dmem[0x00] = 5
        1 => x"00000003",  -- dmem[0x04] = 3
        2 => x"0000000A",  -- dmem[0x08] = 10
        others => x"00000000"
    );
begin
    process(clock)
        variable idx : integer;
    begin
        if rising_edge(clock) then
            idx := to_integer(unsigned(address)) / 4;
            if idx >= 0 and idx < 64 then
                if wren = '1' then
                    ram(idx) <= data;
                end if;
                q <= ram(idx);
            else
                q <= x"00000000";
            end if;
        end if;
    end process;
end rtl;
