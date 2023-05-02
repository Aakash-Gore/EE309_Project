library ieee;
use ieee.std_logic_1164.all;

entity ALU3  is

  port(	
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
		);
		
end entity ALU3;

architecture Struct of ALU3 is
signal temp : std_logic_vector(15 downto 0);
  begin
     process(A, B)
       B <= std_logic_vector(signed(temp)*2);

				begin
				 l1:  for i in 0 to 15 loop
							if i=0 then
								sum(i) := A(i) Xor B(i) Xor '0';
								carry(i) := A(i) and B(i);
							else
								sum(i) := A(i) xor B(i) Xor carry(i-1);
								carry(i) := (A(i) and B(i)) or (carry(i-1) and (A(i) or B(i)));
							end if;
				end loop l1;

end add;
						
end process;
		
end Struct;