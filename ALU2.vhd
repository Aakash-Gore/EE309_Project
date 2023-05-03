library ieee;
use ieee.std_logic_1164.all;

entity ALU2  is

  port(	
  
         sel : in std_logic;
	                carry_encoding: in std_logic;
	                zero_encoding: in std_logic;
	                ext_carry: in std_logic_vector(15 downto 0);
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			c_flag: out std_logic;
			z_flag: out std_logic;
			
			C: out std_logic_vector(15 downto 0)
		);
		
end entity ALU2;

architecture Struct of ALU2 is

	function add(A: in std_logic_vector(15 downto 0); B: in std_logic_vector(15 downto 0))
	   return std_logic_vector is
		
			variable sum : std_logic_vector(16 downto 0):=(others => '0');
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
					  
	sum(16):=carry(15);
					  
	return sum;
	end add;
			
	begin
		
		     alu : process( A, B)
			  variable D: std_logic_vector(15 downto 0);
			  variable temp1 : std_logic_vector(16 downto 0);
			  variable temp2 : std_logic_vector(16 downto 0);

			  begin
			     if carry_encoding = '1' and zero_encoding = '1' then

				case sel is
				   when '0' =>   --addition

				      temp1 := add(A,B);
						D <= temp1(15 downto 0);
                                      temp2 := add(D,ext_carry);
						c_flag <= temp1(16);

						if temp2(15 downto 0) = "0000000000000000" then
						    z_flag <= '1';
						else
						    z_flag <= '0';
						 end if;
				   when '1' =>  --nand

					   l3 : for i in 0 to 15 loop
				 temp1(i) := A(i) nand B(i);
					    end loop l3;

				  C <= temp1(15 downto 0);
							  if temp1(15 downto 0) = "0000000000000000" then
							z_flag <= '1';
						     else
							z_flag <= '0';
								end if;


					 when others =>
					    C <= "0000000000000000";
			     else 
				 case sel is
				   when '0' =>   --addition

				      temp1 := add(A,B);
						D <= temp1(15 downto 0);
                                      temp2 := add(D,ext_carry);
						c_flag <= temp1(16);

						if temp2(15 downto 0) = "0000000000000000" then
						    z_flag <= '1';
						else
						    z_flag <= '0';
						 end if;
				   when '1' =>  --nand

					   l3 : for i in 0 to 15 loop
				 temp1(i) := A(i) nand B(i);
					    end loop l3;

				  C <= temp1(15 downto 0);
							  if temp1(15 downto 0) = "0000000000000000" then
							z_flag <= '1';
						     else
							z_flag <= '0';
								end if;


					 when others =>
					    C <= "0000000000000000";
                              end if;

			 end case;
			
		   end process;
			
	end Struct;
		
		
		
			
					  
					
						
