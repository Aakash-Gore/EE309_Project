library ieee;
use ieee.std_logic_1164.all;

entity clock_generator is
    port (
        clk : out std_logic
    );
end entity;

architecture rtl of clock_generator is
    signal clk_internal : std_logic := '0';
begin
    process
    begin
        wait for 500 ns;
        clk_internal <= not clk_internal;
    end process;

    clk <= clk_internal;
end architecture;