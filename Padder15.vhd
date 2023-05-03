library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
entity padder15 is
	port(din:in std_logic;
		  dout:out std_logic_vector(15 downto 0));
end entity;
architecture struct of padder15 is
begin
dout(15)<=0;
dout(14)<=0;
dout(13)<=0;
dout(12)<=0;
dout(11)<=0;
dout(10)<=0;
dout(9)<=0;
dout(8)<=0;
dout(7)<=0;
dout(6)<=0;
dout(5)<=0;
dout(4)<=0;
dout(3)<=0;
dout(2)<=0;
dout(1)<=0;
dout(0)<=din(0);
end struct;
