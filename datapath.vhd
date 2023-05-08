library ieee;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Datapath is
port(
		
		clk, rst : in std_logic);
end entity Datapath;


architecture struct of Datapath is

component ALU1 is
port(	  
         A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
	 );
end component;

component mux_2x1 is
	port( A,B: in std_logic_vector(15 downto 0);
			S: in std_logic;
			F: out std_logic_vector(15 downto 0));
end component;

component ALU2  is

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
		
end component ALU2;

component sbitregister is
port (
         d : in std_logic_vector(15 downto 0);
			ld : in std_logic;
			clk : in std_logic;
			clr : in std_logic;
			q : out std_logic_vector(15 downto 0));
		
end component;
component ALU3  is

  port(	
			A: in std_logic_vector(15 downto 0); 
			B: buffer std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
		);
		
end component;

component rf is
port (
			a1 : in std_logic_vector(2 downto 0);
			a2 : in std_logic_vector(2 downto 0);
			a3 : in std_logic_vector(2 downto 0);
			d1 : out std_logic_vector(15 downto 0);
			d2 : out std_logic_vector(15 downto 0);
			d3 : in std_logic_vector(15 downto 0);
			pc : out std_logic_vector(15 downto 0);
			clk : in std_logic;
			rst : in std_logic;
			wr : in std_logic;
			rd : in std_logic
		);
		
end component;

component se6 is
	port( 
          din:in std_logic_vector(5 downto 0);
		  dout:out std_logic_vector(15 downto 0)
        );
end component;

component se9 is
port(
      din:in std_logic_vector(8 downto 0);
      dout:out std_logic_vector(15 downto 0)
    );
end component;

component twobitregister is
port (
	   d : in std_logic_vector(1 downto 0);
	   ld : in std_logic;
	   clk : in std_logic;
	   clr : in std_logic;
	    q : out std_logic_vector(1 downto 0)
	 );
end component;

component mux_4to1 is
port(     
	 A : in STD_LOGIC_VECTOR(15 downto 0);
	  B : in STD_LOGIC_VECTOR(15 downto 0);
	  C : in STD_LOGIC_VECTOR(15 downto 0);
	  D : in STD_LOGIC_VECTOR(15 downto 0);
     S0, S1 : in STD_LOGIC;
      Z: out STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

component decoder3_8 is
port ( 
	   sel : in STD_LOGIC_VECTOR (2 downto 0);
       y : out STD_LOGIC_VECTOR (7 downto 0)
	  );
end component;

component instr_mem is
port(
	    clk : in std_logic;
	    addr : in std_logic_vector(15 downto 0);
        memread : in std_logic;
	    --memwrite: 	in std_logic;
	    --datapointer: in std_logic_vector(7 downto 0);
        data : out std_logic_vector(15 downto 0)
    );
end component;

component clock_generator is
port(
        clk : out std_logic
    );
end component;

component demux is
    Port ( I : in std_logic_vector(15 downto 0);
	        S : in std_logic;
           O1, O2 : out std_logic_vector(15 downto 0));
end component;

component data_mem is
  port(  clk : in std_logic;
	 mem_data_in : in std_logic_vector(15 downto 0); -- from P4-R4
	 mem_addr_in : in std_logic_vector(15 downto 0);  -- from demux
	 data_memread  : in std_logic;
	 data_memwrite : in std_logic;
	 mem_out : out std_logic_vector(15 downto 0)  -- to mux
       );
end component;
component padder15 is
	port(din:in std_logic;
		  dout:out std_logic_vector(15 downto 0));
end component;
shared variable stall_1,stall_2,stall_3,stall_4,stall_5 : std_logic:='0';
shared variable flush_1,flush_2,flush_3,flush_4,flush_5 : std_logic:='0';
signal i : integer;
signal temp : integer;
signal a : integer;
signal temp1 : integer;

signal opcode:std_logic_vector(3 downto 0);
signal ALU_1_A,ALU_1_B,ALU_1_C,ALU_2_A,ALU_2_B,ALU_2_C,ALU_3_A,ALU_3_B,ALU_3_C,
       Data_Mem_Addr,Data_Mem_Din,Data_Mem_Dout,Inst_Mem_addr,Inst_Mem_out,P1_R1_out,P5_R1_out,ext_c_flag,PCin,PCout,se9_in,se9_out,se6_in,se6_out,P1_R2_out,P2_R3_out, P4_R1_in, P4_R3_in: std_logic_vector(15 downto 0) := (others => '0');
signal P5_R2_out,ALU2_out, MUX2_out, MUX3_out, P4_R2_out, P4_R1_out, P4_R4_out, P4_R3_out,data_mem_in_add,data_mem_in_data,address_line_sm, demux_o1,demux_o2, dm_out, P5_R3_out: std_logic_vector(15 downto 0) := (others => '0');

signal zero_f,carry_f,P2_R2_wr,P2_R3_wr,P4_R2_wr, P4_R1_wr, cflag, zflag, P4_R4_wr, P4_R3_wr, selector, complement, carryflag, zeroflag, mux2_exe_1, Mux1_control1, Mux1_control2, mux2_exe_2:std_logic;--  Execute
signal con_code_reg_wr, con_code_reg_wr2:std_logic:='1';
signal mux3_exe_1,mux3_exe_2,Inst_Mem_rd, P1_R1_wr,P1_R2_wr, clr, PC_write, P2_R1_wr,P5_R1_wr,P5_R2_wr,demux1_s, dm_rd, dm_wr, Mux2_control, mux3_wr, P5_R3_wr:std_logic;
		 
signal padded,PC,RF_D1,RF_D2,RF_D3,P2_R1_out,P2_R2_out,P3_R2_out,P3_R1_out,P3_RA_out,P3_RB_out,PC_out:std_logic_vector(15 downto 0);
signal RF_A1,RF_A2,RF_A3,address_line:std_logic_vector(2 downto 0);
signal P3_R1_wr,P3_R2_wr,P3_RA_wr,P3_RB_wr,RF_wr,RF_rd, zero_fp5, carry_fp5:std_logic:='0';
signal PC1_clr, P1_R1_clr, P1_R2_clr, P2_R3_clr, P2_R2_clr, P2_R1_clr, P3_RB_clr, P3_RA_clr, P3_R1_clr, P3_R2_clr, P4_R1_clr, P4_R2_clr, P4_R3_clr, P4_R4_clr, P4_Rcz_clr, P5_R1_clr, P5_R2_clr, P5_R3_clr: std_logic;
signal branch_right : std_logic_vector(1 downto 0);
begin
 
  IF_control: process(clk,rst, branch_right)
    begin
    if (clk'event and clk='0') then
		  if(P1_R1_out(15) = '1' and (branch_right ="01" or branch_right ="10")) then
            Mux1_control1 <= '0';
				Mux1_control2 <= '1';
				
        elsif(P1_R1_out(15) = '0' and (branch_right ="01" or branch_right ="10")) then  --branch assumed to be right initially
            Mux1_control1 <= '0';
				Mux1_control2 <= '0';

				
		  else
            Mux1_control1 <= '1';
				Mux1_control2 <= '0';
				
        end if;
		end if;
    end process IF_control;
   
	PC1 : sbitregister port map(clk => clk, d=>PCin, q=>PCout, ld=> PC_write, clr => PC1_clr);
   IM : instr_mem port map(clk => clk, addr => PC_out, memread => Inst_Mem_rd, data=>Inst_Mem_out);
	P1_R1 : sbitregister port map(d => Inst_Mem_out, ld => P1_R1_wr, clk => clk, q => P1_R1_out, clr => P1_R1_clr);
	
   ALU_1 : ALU1 port map( A => PCout, B => "0000000000000010", C => ALU_1_C);
	MUX1 : Mux_4to1 port map(A => P3_R2_out, B => ALU_3_C,C => P3_R2_out, D => ALU_1_C, S0=> Mux1_control1, S1 => Mux1_control2, Z=>PCin);
	P1_R2 : sbitregister port map(d => ALU_1_C, ld => P1_R2_wr, clk => clk, q => P1_R2_out, clr => P1_R2_clr);
--	RF_A3<="000";
--	RF_D3<=PC_out;
--	RF_wr<='1';
	
   --MUX1  : _2to1 port map(A => P1_R2_out, B => ALU_3_C, C => PCin);
	--MUX1 : Mux_4to1 port map(A => P3_R2_out, B => P2_R3_out,C => P3_R2_out, D => ALU_1_C, S=> Mux1_control, F=>PCin);
	--P1_R2 : sbitregister port map(d => ALU_1_C, ld => P1_R2_wr, clk => clk, q => P1_R2_out, clr => P1_R2_clr);
	--ALU_1 : ALU1 port map( A => PCout, B => "0000000000000010", C => ALU_1_C);
	
	-------------------------------IF---------------------------
	
	
	ID_control: process(P2_R2_out, Mux2_control)
   begin
	if (clk'event and clk='0') then
       if(P2_R2_out(15 downto 12) = "0000" or
       P2_R2_out(15 downto 12) = "0100" or
       P2_R2_out(15 downto 12) = "0101" or
       P2_R2_out(15 downto 12) = "1000" or
       P2_R2_out(15 downto 12) = "1001" or
       P2_R2_out(15 downto 12) = "1010")then 
        Mux2_control <= '1';
       else
        Mux2_control <= '0';
       end if;
    end if;
	 end process ID_control;
	
	P2_R1 : sbitregister port map(d=>P1_R1_out, ld=> P2_R1_wr, clk => clk, clr => P2_R1_clr, q=> P2_R1_out);
	SE9_main : se9 port map(din => P1_R1_out(8 downto 0), dout => se9_out);	--add a select line for se to for padding too
	SE6_main: se6 port map(din => P1_R1_out(5 downto 0), dout => se6_out);
	MUX2 : mux_2x1 port map(A => se9_out, B => se6_out, S=> Mux2_control, F=>ALU_3_B);
	ALU_3 : ALU3 port map(A => P1_R2_out, B=> ALU_3_B, C=>ALU_3_C);
	P2_R2 : sbitregister port map(d=>P1_R2_out, ld=> P2_R2_wr, clk => clk, clr => P2_R2_clr, q=> P2_R2_out);
	P2_R3 : sbitregister port map(d=>ALU_3_C, ld=> P2_R3_wr, clk => clk, clr => P2_R3_clr, q=> P2_R3_out);
	
	
	
	
	--------------------------------ID----------------------------
	
	
		


	--varunav
	
	
	
	RRproc:process(clk,rst, P2_R1_out)	
	 begin
	 if (clk'event and clk='0') then
		if (P2_R1_out(15 downto 12)= "0000" or P2_R1_out(15 downto 12)= "0001" or P2_R1_out(15 downto 12)= "0010" or
			P2_R1_out(15 downto 12)= "0110" or P2_R1_out(15 downto 12)= "0111" or P2_R1_out(15 downto 12)= "1000" or
			P2_R1_out(15 downto 12)= "1001" or P2_R1_out(15 downto 12)= "1010" or P2_R1_out(15 downto 12)= "1111" or
			P2_R1_out(15 downto 12)= "0100" or P2_R1_out(15 downto 12)= "0101" or P2_R1_out(15 downto 12)= "1101") then
			RF_rd<='1';
		else
			RF_rd<='0';
		end if;
		
		if (P2_R1_out(15 downto 12)= "0000" or P2_R1_out(15 downto 12)= "0001" or P2_R1_out(15 downto 12)= "0010" or
			P2_R1_out(15 downto 12)= "0110" or P2_R1_out(15 downto 12)= "0111" or P2_R1_out(15 downto 12)= "1000" or
			P2_R1_out(15 downto 12)= "1001" or P2_R1_out(15 downto 12)= "1010" or P2_R1_out(15 downto 12)= "1111") then
			RF_A1<=P2_R1_out(11 downto 9);
		else
			RF_A1<="000";
		end if;
		if (P2_R1_out(15 downto 12)= "0100" or P2_R1_out(15 downto 12)= "0101" or P2_R1_out(15 downto 12)= "1101" or
			P2_R1_out(15 downto 12)= "0001" or P2_R1_out(15 downto 12)= "0010" or P2_R1_out(15 downto 12)= "1000") then
			RF_A2<=P2_R1_out(8 downto 6);
		else
			RF_A2<="000";
		end if;
--		if (P2_R1_out(15 downto 12)= "0011" ) then
--			RF_wr<='1';
--			RF_A3<=P2_R1_out(11 downto 9);
--			RF_D3<=padded;
--		else 
--			RF_wr<='0';
--			RF_A3<="000";
--			RF_D3<="0000000000000000";
--		end if;
		end if;
		end process;
	RF_RR : rf port map(clk=>clk,rst=>rst,a1=>RF_A1,a2=>RF_A2,a3=>P5_R1_out(11 downto 9),D1=>RF_D1,D2=>RF_D2,D3=>RF_D3,wr=>RF_wr,rd=>RF_rd,pc=>PC);
	P3_R1 : sbitregister port map(d => P2_R1_out, ld => P3_R1_wr, clk => clk, q => P3_R1_out,clr=>P3_R1_clr);
	P3_R2 : sbitregister port map(d => P2_R2_out, ld => P3_R1_wr, clk => clk, q => P3_R2_out,clr=>P3_R2_clr);
	P3_RA : sbitregister port map(d => RF_D1, ld => P3_RA_wr, clk => clk, q => P3_RA_out,clr=>P3_RA_clr);
	P3_RB : sbitregister port map(d => RF_D2, ld => P3_RB_wr, clk => clk, q => P3_RB_out,clr=>P3_RB_clr);
	
	
	----------------------------------OR-----------------------------
	
	
	
   P4_R1 : sbitregister port map(d => P4_R1_in, ld => P4_R1_wr, clk => clk, q => P4_R1_out, clr => P4_R1_clr);
	
	P4_R2 : sbitregister port map(d => P3_R2_out, ld => P4_R2_wr, clk => clk, q => P4_R2_out, clr => P4_R2_clr);
	
	ALU_2 : ALU2 port map(comp_bit=>P3_R1_out(2), ext_carry=>ext_c_flag, carry_encoding=> P3_R1_out(1), zero_encoding=>P3_R1_out(0),sel=>selector, A=>MUX2_out, B=> MUX3_out, c_flag=>cflag, z_flag=>zflag , C=> ALU2_out, branch_right_out=>branch_right,opcode=>P3_R1_out(15 downto 12));
	MUX2_exe : mux_4to1 port map(S0 => mux2_exe_1, S1=> mux2_exe_2, D => P3_RA_out, B => P4_R3_out, C=> P5_R2_out, A => "0000000000000000" , Z=>MUX2_out);
   MUX3_exe : mux_4to1 port map(S0 => mux3_exe_1, S1=> mux3_exe_2, D => P3_RB_out, B => P4_R3_out, C=> P5_R2_out, A => P3_R1_out , Z=>MUX3_out);
	P4_R4 : sbitregister port map(d => P3_RB_out, ld => P4_R4_wr, clk => clk, q => P4_R4_out, clr => P4_R4_clr);
	
	P4_R3 : sbitregister port map(d => P4_R3_in, ld => P4_R3_wr, clk => clk, q => P4_R3_out, clr => P4_R3_clr);
	
	P4_Rcz : twobitregister port map(d(0) => cflag, d(1) => zflag, ld => con_code_reg_wr, clk => clk, q(0) => carry_f, q(1) => zero_f, clr => P4_Rcz_clr);
	padder : Padder15 port map(din=>cflag, dout=>ext_c_flag);
	----------------------------EX---------------------------------
opcode<=P3_R1_out(15 downto 12);
exproc: process(clk,rst, opcode, P3_R1_out, P2_R1_out, P4_R1_out, P5_R2_out)
begin
if (clk'event and clk='0') then

if( P5_R1_out(15 downto 12) = "0110") then
   P4_R1_in <= P5_R1_out;
	P4_R3_in <= P5_R3_out;
else
   P4_R1_in <= P3_R1_out;
	P4_R3_in <= ALU_2_C;
end if;


 
if opcode="0001" then
    selector <= '0';
elsif opcode="0010" then 
    selector <= '1';
end if;	 
--carryflag<= Inst_Mem_out(1);
--zeroflag<= Inst_Mem_out(0);
--complement<= Inst_Mem_out(2);
	
--mux2_exe_1
mux2_exe_1 <= '0';
mux2_exe_2 <= '0';
if ((P3_R1_out(11 downto 9) or (P3_R1_out(8 downto 6))) = P4_R1_out(5 downto 3)	and (not((opcode = "1000") or (opcode = "1001") or (opcode = "1010")))) then
   mux2_exe_1 <= '0';
	mux2_exe_2<= '1';
elsif ((P3_R1_out(11 downto 9) or (P3_R1_out(8 downto 6))) = P5_R2_out(5 downto 3) and (not((opcode = "1000") or (opcode = "1001") or (opcode = "1010")))) then
   mux2_exe_1 <= '1';
	mux2_exe_2 <= '0';
else
   mux2_exe_1 <= '1';
   mux2_exe_2 <= '1';
end if;


--mux2_exe_1
mux3_exe_1 <= '0';
mux3_exe_2 <= '0';
if ((P3_R1_out(11 downto 9) or (P3_R1_out(8 downto 6))) = P4_R1_out(5 downto 3)	and (not((opcode = "1000") or (opcode = "1001") or (opcode = "1010")))) then
   mux2_exe_1 <= '0';
	mux2_exe_2<= '1';
elsif ((P3_R1_out(11 downto 9) or (P3_R1_out(8 downto 6))) = P5_R2_out(5 downto 3) and (not((opcode = "1000") or (opcode = "1001") or (opcode = "1010")))) then
   mux2_exe_1 <= '1';
	mux2_exe_2 <= '0';
elsif opcode="0000" then
   mux3_exe_1 <= '1';
	mux3_exe_2 <= '1';
end if;
end if;
end process;	
	----------------------------EX---------------------------------
	
	

	Mem_Control: process(clk, rst, P4_R1_out, P5_R1_out)
	 begin
	 if (clk'event and clk='0') then
	  a<=7;
	  temp1<=0;
      
	  
	  
	  
	  if P4_R1_out(15 downto 12) = "0100" or P4_R1_out(15 downto 12) = "0110" then
	    demux1_s <= '0'; 
		 mux3_wr <= '1';
		 dm_rd <= '1';
		 dm_wr <= '0';
		 
	  elsif P4_R1_out(15 downto 12) = "0101" or P4_R1_out(15 downto 12) = "0111" then
	     demux1_s <= '0';
		  mux3_wr <= '1';
		  dm_wr <= '1';
	     dm_rd <= '0';
		  
		else
		  demux1_s <= '1';
		  mux3_wr <= '0';
		  dm_wr <= '0';
	     dm_rd <= '0';
		  
		if (P4_R1_out(15 downto 12)="0111") then
		   if((a /= -1 )and P4_R1_out(a) = '1') then
			    temp1 <= 7-a;
				 address_line_sm <= std_logic_vector(to_unsigned(temp1, address_line_sm'length));
				 data_mem_in_add <= address_line_sm;
				 data_mem_in_data <= P5_R3_out;
                         a <= a-1;
				
			   
			   -- stall_5 := '1';
				 
			elsif(a = -1) then
			    --4_R3_clr <= '1';
				 --P4_R1_clr <= '1';
				 --stall_5 := '0';
			    a <= 7;
				 
				 data_mem_in_add <= demux_o2;
				 data_mem_in_data <= P4_R4_out;
				 
			
			 end if;
			 
			
		
			end if;
		  
		end if;
	end if;
	end process Mem_Control; 
	
	
	
	P5_R1 : sbitregister port map(d =>P4_R1_out , ld =>P5_R1_wr, q => P5_R1_out, clk => clk, clr => P5_R1_clr);
	P5_R2 : sbitregister port map(d => P4_R2_out, ld => P5_R2_wr, q=> P5_R2_out, clk => clk, clr => P5_R2_clr);
	P5_Rcz : twobitregister port map(d(0) => carry_f, d(1) => zero_f, ld => con_code_reg_wr2, clk => clk, q(0) => carry_fp5, q(1) => zero_fp5, clr => clr);
	DEMUX1 : demux port map(I => P4_R3_out , S => demux1_s, O1 => demux_o1 , O2 => demux_o2); 
	
	DM : data_mem port map(mem_addr_in =>  data_mem_in_add , mem_out => dm_out, clk => clk, mem_data_in => data_mem_in_data  , data_memread => dm_rd, data_memwrite => dm_wr);
	
	
	
	MUX3 : mux_2x1 port map( A => demux_o2, B => dm_out, F => mux3_out, S => mux3_wr);
	P5_R3 : sbitregister port map(d => mux3_out, ld => P5_R3_wr, q => P5_R3_out, clr => P5_R3_clr, clk => clk);

	---------------------------------MEM-------------------------------
	
	wbproc:process(clk,rst, P5_R1_out, carry_fp5, zero_fp5, P5_R3_out, PC_out)
	
	
	begin 

	if (clk'event and clk='0') then
	  i <= 7;
     temp <= 0;
		if(P5_R1_out(15 downto 12)= "0000" or P5_R1_out(15 downto 12)= "0011" or
		(P5_R1_out(15 downto 12)= "0001" and (P5_R1_out(1 downto 0)="00" or (P5_R1_out(1 downto 0)="10" and carry_fp5='1') or (P5_R1_out(1 downto 0)="01" and zero_fp5='1') )) or 
		(P5_R1_out(15 downto 12)= "0010" and (P5_R1_out(1 downto 0)="00" or (P5_R1_out(1 downto 0)="10" and carry_fp5='1') or (P5_R1_out(1 downto 0)="01" and zero_fp5='1') ))
		or P5_R1_out(15 downto 12)= "0100" or P5_R1_out(15 downto 12)= "0110") then
			RF_wr<='1';
		else
			RF_wr<='0';
		end if;
		if (P5_R1_out(15 downto 12)="0000") then
		RF_A3<= P5_R1_out(8 downto 6); RF_D3<=P5_R3_out;
		elsif(P5_R1_out(15 downto 12)= "0001" and (P5_R1_out(1 downto 0)="00" or (P5_R1_out(1 downto 0)="10" and carry_fp5='1') or (P5_R1_out(1 downto 0)="01" and zero_fp5='1'))) or
		(P5_R1_out(15 downto 12)= "0010" and (P5_R1_out(1 downto 0)="00" or (P5_R1_out(1 downto 0)="10" and carry_fp5='1') or (P5_R1_out(1 downto 0)="01" and zero_fp5='1'))) then
			RF_A3<=P5_R1_out(5 downto 3); RF_D3<=P5_R3_out;
		end if;
		if (P5_R1_out(15 downto 12)="0011") then
			padded(15 downto 9)<="0000000";
			padded(8 downto 0)<=P5_R1_out(8 downto 0);
			RF_A3<=P5_R1_out(11 downto 9);
			RF_wr<='1';
			RF_D3<=padded;
		end if;
		if (P5_R1_out(15 downto 12)="1100" or P5_R1_out(15 downto 12)="1101" or P5_R1_out(15 downto 12)="1111"
		or P5_R1_out(15 downto 12)="1000" or P5_R1_out(15 downto 12)="1001" or P5_R1_out(15 downto 12)="1010"
		or P5_R1_out(15 downto 12)="0111" ) then
		RF_A3<="000";
      RF_D3<=PC_out;
      RF_wr<='1';
		end if;
		
		if (P5_R1_out(15 downto 12)="0110") then
		   if((i /= -1 )and P5_R1_out(i) = '1') then
			    temp <= 7-i;
				 address_line <= std_logic_vector(to_unsigned(temp, address_line'length));
				 RF_A3 <= address_line;
				 RF_D3 <= P5_R3_out;
				 RF_wr<='1';
				 i <= i-1;
			   
			   -- stall_5 := '1';
				 
		 
				 
				 
			
			 end if;
			 if (P5_R1_out(15 downto 12)="0110" or P4_R1_out(15 downto 12)="0111") then
			    P4_R1_clr <= '1';
				 P4_R3_clr <= '1';
				end if;
			   
			 
			 
			
		
			end if;
			 
		
	 end if;
	end process; 
	
	
	---------------------------------WB--------------------------------
	
	process(rst,clk)
	
	begin
	if (clk'event and clk='0') then
	
	if (P5_R1_out(15 downto 12)="0110") then
		   if((i /= -1 )and P5_R1_out(i) = '1') then
			   stall_5:='1';
			elsif(i = -1) then
			   stall_5:='0';
			end if;
	end if;
	
	if (P4_R1_out(15 downto 12)="0111") then
		   if((a /= -1 ) and P4_R1_out(a) = '1') then
			   stall_4:='1';
			elsif(i = -1) then
			   stall_4:='0';
			end if;
	end if;
	
	if (P3_R1_out(15 downto 12)="0100" and 
		(P2_R1_out(15 downto 12)="0001" or P2_R1_out(15 downto 12)="0010" or P2_R1_out(15 downto 12)="0000" or
		 P2_R1_out(15 downto 12)="0101" or P2_R1_out(15 downto 12)="1010" or P2_R1_out(15 downto 12)="1000" or
		 P2_R1_out(15 downto 12)="1001")) then
		    if(P3_R1_out(11 downto 9)=P2_R1_out(11 downto 9) or P3_R1_out(11 downto 9)=P2_R1_out(8 downto 6)) then
					stall_1:='1';
					stall_2:='1';
					flush_3:='1';
			 else
					stall_1:='0';
					stall_2:='0';
					flush_3:='0';
	       end if;
	end if;
	
	if(P3_R1_out(15 downto 12) = "0110" or P4_R1_out(15 downto 12) = "0110") then
	   stall_1:='1';
		stall_2:='1';
	   flush_3:='1';
	 else
	      stall_1:='0';
			stall_2:='0';
			flush_3:='0';
    end if;
	 
	 
		
	if(P3_R1_out(15 downto 12) = "0111" or P4_R1_out(15 downto 12) = "0111") then
	   stall_1:='1';
		stall_2:='1';
	   flush_3:='1';
	 else
	      stall_1:='0';
			stall_2:='0';
			flush_3:='0';
    end if;
		 
		
	
	if branch_right ="01" then
	   flush_3 := '1';
	elsif branch_right ="00" then
	   flush_1 := '1';
		flush_2 := '1';
	else 
	   flush_3 := '0';
		flush_1 := '0';
		flush_2 := '0';
		
	end if;		
	

		  
				if stall_1 = '0' and flush_1 = '0' then
				   
					
					Inst_Mem_rd <= '1';
					P1_R1_wr <= '1';
					P1_R2_wr <= '1'; 
					PC_write <= '1';
			  
				 elsif stall_1 = '1' and flush_1 = '0' then
				
					Inst_Mem_rd <= '0';
					P1_R1_wr <= '0';
					P1_R2_wr <= '0';
					PC_write <= '0';
					
				 elsif stall_1= '0' and flush_1 = '1' then
				    Inst_Mem_rd <= '0';
					 P1_R1_wr <= '0';
					P1_R2_wr <= '0';
					P1_R1_clr <= '1';
					P1_R2_clr <= '1';
					PC_write <= '1';
				     
					
				 end if;
				
			
			  
				  if stall_2 = '0' and flush_2 = '0' then
				  	
					
					P2_R1_wr <= '1';
					P2_R2_wr <= '1';
					P2_R3_wr <= '1';
					--P1_R2_wr <= '1'; 
					
			  
				 elsif stall_2 = '1' and flush_2 = '0' then
				
					
					P2_R1_wr <= '0';
					P2_R2_wr <= '0';
					P2_R3_wr <= '0';
					--Mux2_control <= SE_select;
					
				 elsif stall_2= '0' and flush_2 = '1' then
				    
					P2_R1_clr <= '1';
					P2_R2_clr <= '1';
					P2_R3_clr <= '1';
					P2_R1_wr <= '0';
					P2_R2_wr <= '0';
					P2_R3_wr <= '0';
				end if;	
			
			      
					
				  if stall_3 = '0' and flush_3 = '0' then
				  	
					P3_R1_wr <= '1';
					P3_R2_wr <= '1';
					P3_RA_wr <= '1';
					P3_RB_wr <= '1';
					
			  
				 elsif stall_3 = '1' and flush_3 = '0' then
				
					P3_R1_wr <= '0';
					P3_R2_wr <= '0';
					P3_RA_wr <= '0';
					P3_RB_wr <= '0';
					
					
					--Mux2_control <= SE_select;
					
				 elsif stall_3= '0' and flush_3 = '1' then
				   P3_R1_wr <= '0';
					P3_R2_wr <= '0';
					P3_RA_wr <= '0';
					P3_RB_wr <= '0';
				   P3_R1_clr <= '1';
					P3_R2_clr <= '1';
					P3_RA_clr <= '1';
					P3_RB_clr <= '1';
				end if;
			 
			    
				 if stall_4 = '0' and flush_4 = '0' then
				  	
					P4_R1_wr <= '1';
					P4_R2_wr <= '1';
					P4_R3_wr <= '1';
					P4_R4_wr <= '1';
					
			  
				 elsif stall_4 = '1' and flush_4 = '0' then
				
					P4_R1_wr <= '0';
					P4_R2_wr <= '0';
					P4_R3_wr <= '0';
					P4_R4_wr <= '0';
					
					--Mux2_control <= SE_select;
					
				 elsif stall_4 = '0' and flush_4 = '1' then
				   P4_R1_wr <= '0';
					P4_R2_wr <= '0';
					P4_R3_wr <= '0';
					P4_R4_wr <= '0';
				   P4_R1_clr <= '1';
					P4_R2_clr <= '1';
					P4_R3_clr <= '1';
					P4_R4_clr <= '1';
				end if;	
			 
			    
				 if stall_5 = '0' and flush_5 = '0' then
				  	
					P5_R1_wr <= '1';
					P5_R2_wr <= '1';
					P5_R2_wr <= '1';
					--P4_R3_wr <= '1';
					--P4_R4_wr <= '1';
					
			  
				 elsif stall_5 = '1' and flush_5 = '0' then
				
					P5_R1_wr <= '0';
					P5_R2_wr <= '0';
					P5_R2_wr <= '0';
					--P4_R3_wr <= '0';
					--P4_R4_wr <= '0';
					
					--Mux2_control <= SE_select;
					
				 elsif stall_5 = '0' and flush_5 = '1' then
				 P5_R1_wr <= '0';
					P5_R2_wr <= '0';
					P5_R2_wr <= '0';
				   P5_R1_clr <= '1';
					P5_R2_clr <= '1';
					P5_R2_clr <= '1';
				end if;	
			
			
			 
		end if;	 
		end process;
end struct;
