library ieee;
use ieee.std_logic_1164.all;

entity ALU2  is

  port(	
  
         sel : in std_logic;
	  		opcode: in std_logic_vector(3 downto 0);
	      comp_bit: in std_logic;
	      carry_encoding: in std_logic;
	      zero_encoding: in std_logic;
	      ext_carry: in std_logic_vector(15 downto 0);
			A: in std_logic_vector(15 downto 0); 
			B: buffer std_logic_vector(15 downto 0);
			c_flag: buffer std_logic;
			z_flag: buffer std_logic;
			C: out std_logic_vector(15 downto 0);
	      branch_right_out : out std_logic_vector(1 downto 0));
		
end entity ALU2;

architecture Struct of ALU2 is
       shared variable B_not:std_logic_vector(15 downto 0);
		 shared variable D: std_logic_vector(15 downto 0):=(others => '0');
		 shared variable check: std_logic_vector(15 downto 0);
		 shared variable temp1 : std_logic_vector(16 downto 0):=(others => '0');
		 shared variable temp2 : std_logic_vector(16 downto 0):=(others => '0');
	
	--signal B_not1:std_logic_vector(16 downto 0);
	--signal B1:std_logic_vector(16 downto 0);
	
	function add(A: in std_logic_vector(15 downto 0):= (others => '0'); 
	   B: in std_logic_vector(15 downto 0):= (others => '0'))
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
	
	
	function subb(A: in std_logic_vector(15 downto 0):= (others => '0'); 
	   B: in std_logic_vector(15 downto 0):= (others => '0'))
	   return std_logic_vector is
		 variable sum : std_logic_vector(16 downto 0):=(others => '0');
	    variable carry : std_logic_vector(15 downto 0):=(others=> '0');
       
		     begin
					
					 l2:  for i in 0 to 15 loop
								if i=0 then
									sum(i) := A(i) Xor (not B(i)) Xor '1';
									carry(i) := A(i) and (not B(i));
								else
									sum(i) := A(i) xor (not B(i)) Xor carry(i-1);
									carry(i) := (A(i) and (not B(i))) or (carry(i-1) and (A(i) or (not B(i))));
									
								end if;
					  end loop l2;
					  
	sum(16):=carry(15);
					  
	return sum;
	end subb;
			
	begin
		
		     alu : process(A,B,sel,comp_bit,opcode,carry_encoding,zero_encoding,ext_carry,c_flag,z_flag)
			  
			  --variable A1 : std_logic_vector(16 downto 0);
			  

			  begin	
			     if not (opcode = "1000" and opcode = "1001" and opcode = "1010") then
				     branch_right_out <= "10";
				  end if;
			  	  -- A1(16):='0';
			     -- A1(15 downto 0):=A(15 downto 0);
			     -- B1(16)<='0';
			     -- B1(15 downto 0)<=B(15 downto 0);
			     check := "0000000000000000";
				  
				  c_flag <= '0';
				  z_flag <= '0';
				  
			     if opcode = "0000" then    --ADI
				     --temp1(16):='0';
					  --temp1(15 downto 0) := B(15 downto 0);
				     l6 : for i in 6 to 15 loop
					     temp1(i) := '0';
                  end loop l6;  
						
			         temp2 := add(A, temp1(15 downto 0));
						C <= temp2(15 downto 0);
						c_flag <= temp2(16);
						if temp2(15 downto 0) = "0000000000000000" then
	                  z_flag <= '1';
				      else
					      z_flag <= '0';
				      end if;
						
			     end if;
                             
			     if opcode = "1000" then   -----BEQ
				     l2: for i in 0 to 15 loop
					     if A(i) = B(i) then
						     check(i) := '1';
					     end if;
				     end loop l2;
			             if check = "1111111111111111" then
					       branch_right_out <= "01";
							 else
							 branch_right_out <= "00";
							 
				          end if;
			     end if;
				  
			     if opcode = "1001" then -------BLT
				        B_not := not B;
				        temp1 := add(A, B_not);
				        c_flag <= temp1(16);
				        if temp1(15 downto 0) = "0000000000000000" then
					        z_flag <= '1';
					     else
					        z_flag <= '0';
					     end if;
					     
						  if c_flag = '1' and z_flag = '0' then
						     branch_right_out <= "01";
							else
							  branch_right_out <= "00";
					     end if;
			     end if;
			     
			     if opcode = "1010" then  --------BLE
				      B_not := not B;
				      temp1 := add(A, B_not);
				      c_flag <= temp1(16);
				      if temp1(15 downto 0) = "0000000000000000" then
					      z_flag <= '1';
					   else
					      z_flag <= '0';
					   end if;
					   
						if c_flag = '1' or z_flag = '1' then
						   branch_right_out <= "01";
						else
							  branch_right_out <= "00";
					   end if;
			     end if;
					     
			     if carry_encoding = '1' and zero_encoding = '1' then  --AWC and ACW
				     if comp_bit = '1' then
					     l1: for i in 0 to 15 loop
						     B(i) <= not B(i);
				             end loop l1;
				     end if;

				case sel is
				   when '0' =>   --addition

				      temp1 := add(A,B);
						
						D := temp1(15 downto 0);
                  temp2 := add(D,ext_carry);
                  C <= temp2(15 downto 0);
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
				  end case;
			  else 
				 if comp_bit = '1' then
					     l4: for i in 0 to 15 loop
						     B(i) <= not B(i);
				        end loop l4;
				  else 
					     B <= B;
				  end if;
				 
					     
				 case sel is
				   when '0' =>   --addition

				      temp1 := add(A,B);
						C <= temp1(15 downto 0);

						if temp1(15 downto 0) = "0000000000000000" then
						    z_flag <= '1';
						else
						    z_flag <= '0';
						end if;
				   when '1' =>  --nand

					   l5 : for i in 0 to 15 loop
				         temp1(i) := A(i) nand B(i);
					   end loop l5;

				         C <= temp1(15 downto 0);
							if temp1(15 downto 0) = "0000000000000000" then
							   z_flag <= '1';
						   else
							   z_flag <= '0';
							end if;


					 when others =>
					    C <= "0000000000000000";
                              

			 end case;
			end if;
		   end process;
			
	end Struct;
