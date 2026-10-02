library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        WIDTH : positive := 8
    );
    port (
        a      : in  std_logic_vector(WIDTH - 1 downto 0);
        b      : in  std_logic_vector(WIDTH - 1 downto 0);
        op     : in  std_logic_vector(1 downto 0);
        result : out std_logic_vector(WIDTH - 1 downto 0);
        z      : out std_logic;
        c      : out std_logic
    );
end entity;

architecture rtl of alu is

    signal wide_result : unsigned(WIDTH downto 0);-- because we want 9 bits for the carry out

begin

    -- TODO: your logic

end architecture;
