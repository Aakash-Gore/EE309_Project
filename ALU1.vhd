library ieee;
use ieee.std_logic_1164.all;

entity ALU1  is

  port(	
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
		);
		
end entity ALU1;

architecture Struct of ALU1 is

	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	   return std_logic_vector is
		
			variable sum : std_logic_vector(15 downto 0):=(others => '0');
			variable carry : std_logic_vector(15 downto 0):=(others=> '0');
  
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
					  
	return sum;
	end add;
							
				
	begin
		alu : process( A, B)
		  
		  begin
		   
			 C <= add(A,B);
			
		   end process;
			
	end Struct;
		
		
		
			
					  
					
						
