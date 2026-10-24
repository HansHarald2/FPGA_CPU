library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu_tb is
end entity;

architecture sim of alu_tb is

    signal a      : std_logic_vector(7 downto 0) := (others => '0');
    signal b      : std_logic_vector(7 downto 0) := (others => '0');
    signal op     : std_logic_vector(1 downto 0) := "00";
    signal result : std_logic_vector(7 downto 0);
    signal z      : std_logic;
    signal c      : std_logic;

begin

    dut: entity work.alu
        generic map (
            WIDTH => 8
        )
        port map (
            a      => a,
            b      => b,
            op     => op,
            result => result,
            z      => z,
            c      => c
        );

    stimulus: process
        variable expected : unsigned(8 downto 0);
    begin
        -- Test 1: ADD 3 + 4 = 7
        a <= x"03"; b <= x"04"; op <= "00";
        wait for 10 ns;
        assert result = x"07" and z = '0' and c = '0'
            report "Test 1 failed: ADD 3 + 4" severity error;
                    -- Test 2: ADD 255 + 1 = 0 with carry
        a <= x"FF"; b <= x"01"; op <= "00";
        wait for 10 ns;
        assert result = x"00" and z = '1' and c = '1'
            report "Test 2 failed: ADD 255 + 1" severity error;

        -- Test 3: SUB 5 - 5 = 0
        a <= x"05"; b <= x"05"; op <= "01";
        wait for 10 ns;
        assert result = x"00" and z = '1' and c = '0'
            report "Test 3 failed: SUB 5 - 5" severity error;

        -- Test 4: SUB 1 - 2 = 255 with borrow
        a <= x"01"; b <= x"02"; op <= "01";
        wait for 10 ns;
        assert result = x"FF" and z = '0' and c = '1'
            report "Test 4 failed: SUB 1 - 2" severity error;

        -- Test 5: AND F0 and 3C = 30
        a <= x"F0"; b <= x"3C"; op <= "10";
        wait for 10 ns;
        assert result = x"30" and z = '0' and c = '0'
            report "Test 5 failed: AND" severity error;

        -- Test 6: OR F0 or 3C = FC
        a <= x"F0"; b <= x"3C"; op <= "11";
        wait for 10 ns;
        assert result = x"FC" and z = '0' and c = '0'
            report "Test 6 failed: OR" severity error;

        report "Directed tests done" severity note;
        -- Test 7: ADD, all 256 x 256 combinations
        op <= "00";
        for i in 0 to 255 loop
            for j in 0 to 255 loop
                a <= std_logic_vector(to_unsigned(i, 8));
                b <= std_logic_vector(to_unsigned(j, 8));
                wait for 1 ns;
                expected := to_unsigned(i + j, 9);
                assert unsigned(result) = expected(7 downto 0) and c = expected(8)
                    report "ADD failed: " & integer'image(i) & " + " & integer'image(j)
                    severity error;
            end loop;
        end loop;
        report "All tests done" severity note;
        wait;
    end process;

end architecture;
