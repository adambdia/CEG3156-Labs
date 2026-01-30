library ieee;
use ieee.std_logic_1164.all;

entity zero_flag is
    generic (WIDTH : positive := 10);
    port (
        i_data      : in  std_logic_vector(WIDTH-1 downto 0);
        o_zero_flag : out std_logic
    );
end zero_flag;

architecture structural of zero_flag is
    signal or_chain : std_logic_vector(WIDTH-1 downto 0);
begin

    or_chain(0) <= i_data(0);

    gen_or : for i in 1 to WIDTH-1 generate
        or_chain(i) <= or_chain(i-1) or i_data(i);
    end generate;

    o_zero_flag <= not or_chain(WIDTH-1);

end structural;
