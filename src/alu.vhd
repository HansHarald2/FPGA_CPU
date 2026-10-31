library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        WIDTH : positive := 8                                 -- data width in bits (design-time constant, default 8)
    );
    port (
        a      : in  std_logic_vector(WIDTH - 1 downto 0);    -- first operand, comes from the ACC
        b      : in  std_logic_vector(WIDTH - 1 downto 0);    -- second operand, comes from memory
        op     : in  std_logic_vector(1 downto 0);            -- op is the operation code, 00 = add, 01 = sub, 10 = and, 11 = or (from control unit)
        result : out std_logic_vector(WIDTH - 1 downto 0);    -- calculation result, goes back into the ACC
        z      : out std_logic;                               -- zero flag: 1 if result = 0, goes to the FLAGS register
        c      : out std_logic                                -- carry flag: carry (add) or borrow (sub), goes to the FLAGS register
    );
end entity;

architecture rtl of alu is

    -- internal wire: the calculation result with one extra bit on top.
    -- lower WIDTH bits = result, top bit = carry out (9 bits for WIDTH = 8)
    signal wide_result : unsigned(WIDTH downto 0);

begin

    -- calculation: op picks which result goes into wide_result
    process (all)
    begin
        case op is
            when "00" => --add
                wide_result <= resize(unsigned(a), WIDTH + 1) + resize(unsigned(b), WIDTH + 1);
            when "01" => --sub
                wide_result <= resize(unsigned(a), WIDTH + 1) - resize(unsigned(b), WIDTH + 1);
            when "10" => --and
                wide_result <= resize(unsigned(a), WIDTH + 1) and resize(unsigned(b), WIDTH + 1);
            when "11" => --or
                wide_result <= resize(unsigned(a), WIDTH + 1) or resize(unsigned(b), WIDTH + 1);
            when others =>
                wide_result <= (others => '0');
        end case;
    end process;

    -- split wide_result into the three outputs
    result <= std_logic_vector(wide_result(WIDTH - 1 downto 0));
    z      <= '1' when wide_result(WIDTH - 1 downto 0) = 0 else '0';
    c      <= wide_result(WIDTH);

end architecture;
