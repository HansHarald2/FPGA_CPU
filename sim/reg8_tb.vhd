library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg8_tb is
end entity;

architecture sim of reg8_tb is

    constant CLK_PERIOD : time := 10 ns;

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '0';
    signal load : std_logic := '0';
    signal d    : std_logic_vector(7 downto 0) := (others => '0');
    signal q    : std_logic_vector(7 downto 0);

begin

    clk <= not clk after CLK_PERIOD / 2;

    dut: entity work.reg8
        generic map (
            WIDTH => 8
        )
        port map (
            clk  => clk,
            rst  => rst,
            load => load,
            d    => d,
            q    => q
        );

    stimulus: process
    begin
        -- Test 1: reset
        rst <= '1'; load <= '0'; d <= x"2A";
        wait until falling_edge(clk);
        assert q = x"00" report "Test 1 failed: reset" severity error;

        -- Test 2: no load, q keeps 0
        rst <= '0'; load <= '0'; d <= x"2A";
        wait until falling_edge(clk);
        assert q = x"00" report "Test 2 failed: no load" severity error;

        -- Test 3: load 42
        rst <= '0'; load <= '1'; d <= x"2A";
        wait until falling_edge(clk);
        assert q = x"2A" report "Test 3 failed: load" severity error;

        -- Test 4: no load, d is ignored
        rst <= '0'; load <= '0'; d <= x"63";
        wait until falling_edge(clk);
        assert q = x"2A" report "Test 4 failed: keep value" severity error;

        -- Test 5: load 99
        rst <= '0'; load <= '1'; d <= x"63";
        wait until falling_edge(clk);
        assert q = x"63" report "Test 5 failed: load" severity error;

        -- Test 6: reset beats load
        rst <= '1'; load <= '1'; d <= x"07";
        wait until falling_edge(clk);
        assert q = x"00" report "Test 6 failed: reset beats load" severity error;

        -- Test 7: q may only change on the rising edge
        rst <= '0'; load <= '1'; d <= x"55";
        wait for 2 ns;
        assert q = x"00" report "Test 7 failed: q changed before the edge" severity error;
        wait until falling_edge(clk);
        assert q = x"55" report "Test 7 failed: load after the edge" severity error;

        report "All tests done" severity note;
        std.env.finish;
    end process;

end architecture;
