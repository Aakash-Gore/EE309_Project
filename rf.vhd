library ieee;
use ieee.std_logic_1164.all;
entity rf is
	port (a1 : in std_logic_vector(3 downto 0);
			a2 : in std_logic_vector(3 downto 0);
			a3 : in std_logic_vector(3 downto 0);
			d1 : out std_logic_vector(15 downto 0);
			d2 : out std_logic_vector(15 downto 0);
			d3 : in std_logic_vector(15 downto 0);
			pc : out std_logic_vector(15 downto 0);
			clk : in std_logic;
			rst : in std_logic;
			wr : in std_logic;
			rd : in std_logic);
end entity;


architecture behav of rf is
signal r0,r1,r2,r3,r4,r5,r6,r7,t1,t2:std_logic_vector(15 downto 0);
begin 
	pc<= r0;
	d1<=t1 when (rd='1');
	d2<=t2 when (rd='1');
	wrenable: process(wr,clk,rst,a3)
		begin 
		if (rst='1') then
			r0<=(others => '0');
			r1<=(others => '0');
			r2<=(others => '0');
			r3<=(others => '0');
			r4<=(others => '0');
			r5<=(others => '0');
			r6<=(others => '0');
			r7<=(others => '0');
		elsif (clk'event and clk='1') then
			if (wr='1') then
				case a3 is 
					when "000"=>
						r0<=d3;
				   when "001"=>
						r1<=d3;
					when "010"=>
						r2<=d3;
					when "011"=>
						r3<=d3;
					when "100"=>
						r4<=d3;
					when "101"=>
						r5<=d3;
					when "110"=>
						r6<=d3;
					when "111"=>
						r7<=d3;
				end case;
			end if;
		end if;
		end process;
	rdenable: process(rd,clk,rst,a1,a2)
		begin 
		if (rd='1') then
			case a1 is 
					when "000"=>
						t1<=r0;
				   when "001"=>
						t1<=r1;
					when "010"=>
						t1<=r2;
					when "011"=>
						t1<=r3;
					when "100"=>
						t1<=r4;
					when "101"=>
						t1<=r5;
					when "110"=>
						t1<=r6;
					when "111"=>
						t1<=r7;
			end case;
			case a2 is 
					when "000"=>
						t2<=r0;
				   when "001"=>
					   t2<=r1;
					when "010"=>
						t2<=r2;
					when "011"=>
						t2<=r3;
					when "100"=>
						t2<=r4;
					when "101"=>
						t2<=r5;
					when "110"=>
						t2<=r6;
					when "111"=>
						t2<=r7;
			end case;
		end if;
	end process;
end behav;
