library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Mux2x1 is
	port( A,B,S: in std_logic;
			F: out std_logic);
end Mux2x1;

architecture Behavioral of Mux2x1 is
begin
	Process(A,B,S)
	begin
		if(S='0')then
				F<=A;
		 else
		F<=B;
		 end if;
	end Process;
end Behavioral;