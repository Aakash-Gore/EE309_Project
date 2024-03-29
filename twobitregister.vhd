library ieee;
use ieee.std_logic_1164.all;
entity twobitregister is
	port (d : in std_logic_vector(1 downto 0);
			ld : in std_logic;
			clk : in std_logic;
			clr : in std_logic;
			q : out std_logic_vector(1 downto 0));
end entity;


architecture description of twobitregister is
		begin
			process (clk, clr)
				begin
					if clr = '1' then
						q <= (others => '0');
					elsif rising_edge(clk) then
						if ld = '1' then
							q <= d;
						end if;
						end if;
				end process;
end description;
