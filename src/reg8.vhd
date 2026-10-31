library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg8 is
    generic (
        WIDTH : positive := 8                                 -- data width in bits (design-time constant, default 8)
    );

    port (
        clk : in  std_logic;
        rst : in  std_logic;
        load : in  std_logic;
        d   : in  std_logic_vector(WIDTH - 1 downto 0);
        q   : out std_logic_vector(WIDTH - 1 downto 0)    -- last line: no semicolon
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
