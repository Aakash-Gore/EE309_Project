library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ALU3  is

  port(	
			A: in std_logic_vector(15 downto 0); 
			B: buffer std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
		);
		
end entity ALU3;

architecture Struct of ALU3 is
signal temp: std_logic_vector(15 downto 0);
signal temp_main: std_logic_vector(31 downto 0);
shared variable sum,carry : std_logic_vector(15 downto 0);
shared variable two: std_logic_vector(15 downto 0):="1111111111111110";
  begin  
  process(A, B)
     begin 
	  
		temp <= B;
       temp_main <= std_logic_vector(signed(temp)*signed(two));
		 B<=temp_main(15 downto 0);

				 l1:  for i in 0 to 15 loop
							if i=0 then
								sum(i) := A(i) Xor B(i) Xor '0';
								carry(i) := A(i) and B(i);
							else
								sum(i) := A(i) xor B(i) Xor carry(i-1);
								carry(i) := (A(i) and B(i)) or (carry(i-1) and (A(i) or B(i)));
							end if;
				end loop l1;

						
end process;
		
end Struct;
