library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
entity se6 is
	port(din:in std_logic_vector(5 downto 0);
		  dout:out std_logic_vector(15 downto 0));
end entity;
architecture struct of se6 is
begin
dout(15)<=din(5);
dout(14)<=din(5);
dout(13)<=din(5);
dout(12)<=din(5);
dout(11)<=din(5);
dout(10)<=din(5);
dout(9)<=din(5);
dout(8)<=din(5);
dout(7)<=din(5);
dout(6)<=din(5);
dout(5)<=din(5);
dout(4)<=din(4);
dout(3)<=din(3);
dout(2)<=din(2);
dout(1)<=din(1);
dout(0)<=din(0);
end struct;