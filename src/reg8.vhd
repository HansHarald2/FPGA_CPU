library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8 is
    generic (
        WIDTH : positive := 8                                 -- data width in bits (design-time constant, default 8)
    );
    port (
        clk  : in  std_logic;                                 -- register changes only on the rising edge
        rst  : in  std_logic;                                 -- synchronous reset: 1 = set q to 0, beats load
        load : in  std_logic;                                 -- 1 = take d on this edge, 0 = keep the value (from control unit)
        d    : in  std_logic_vector(WIDTH - 1 downto 0);      -- new value
        q    : out std_logic_vector(WIDTH - 1 downto 0)       -- stored value
    );
end entity;

architecture rtl of reg8 is
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= (others => '0');
            elsif load = '1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture;
