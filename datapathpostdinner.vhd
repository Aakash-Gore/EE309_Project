library ieee;
use ieee.std_logic_1164.all;

entity Datapath is
port(
		state : in std_logic_vector(2 downto 0);
		clk, rst : in std_logic;
		
		C , Z : out std_logic;
	 );
end entity Datapath;


architecture struct of Datapath is

component ALU1 is
port(	  
         A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
	 );
end component;

component ALU2 is
port(	
  
         sel : in std_logic;
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			c_flag: out std_logic;
			z_flag: out std_logic;
			
			C: out std_logic_vector(15 downto 0)
	 );
end component;

component sbitregister is
port (
         d : in std_logic_vector(15 downto 0);
			ld : in std_logic;
			clk : in std_logic;
			clr : in std_logic;
			q : out std_logic_vector(15 downto 0));
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
	  A : in STD_LOGIC_VECTOR(3 downto 0);
      S0,S1: in STD_LOGIC;
      Z: out STD_LOGIC
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
        data : out std_logic_vector(15 downto 0);
    );
end component;

component clock_generator is
port(
        clk : out std_logic
    );
component demux is
    Port ( I,S : in  STD_LOGIC;
           O1, O2 : out  STD_LOGIC);
end component;

component data_mem is
  port(  clk : in std_logic;
	 mem_data_in : in std_logic_vector(15 downto 0); -- from P4-R4
	 mem_addr_in : in std_logic_vector(15 downto 0);  -- from demux
	 data_memread  : in std_logic;
	 data_memwrite : in std_logic;
	 mem_out : out std_logic_vector(15 downto 0);  -- to mux
       )
end component;
	  
component padder15 is
	port(din:in std_logic_vector(8 downto 0);
		  dout:out std_logic_vector(15 downto 0));
end component;

 

signal ALU_1_A,ALU_1_B,ALU_1_C,ALU_2_A,ALU_2_B,ALU_2_C,ALU_3_A,ALU_3_B,ALU_3_C,
       Data_Mem_Addr,Data_Mem_Din,Data_Mem_Dout,Inst_Mem_addr,Inst_Mem_out,
	   P1_R1_out,P1_R2_out, P2_R1_out
	   RF_D1,RF_D2,RF_D3,R7,PCin,PCout,se9_in,se9_out,se6_in,se6_out : std_logic_vector(15 downto 0) := (others => '0');
signal ALU2_out, MUX2_out, MUX3_out, P4_R2_out, P4_R1_out, P4_R4_out, P4_R3_out, demux2_o2

signal P4_R2_wr, P4_R1_wr, cflag, zflag, P4_R4_wr, P4_R3_wr--  Execute

signal Inst_Mem_rd, P1_R1_wr,P1_R2_wr, clr, rst, PC_write, P2_R1_wr,P5_R1_wr,P5_R2_wr,demux1_s, demux2_s,demux_o1,demux_o2,dm_out,dm_rd, dm_wr, Mux2_control

       P5_R1_wr, mux3_wr, mux3_out, P5_R3_wr, P5_R3_out
      
signal PC,RF_D1,RF_D2,RF_D3,P2_R1_out,P2_R2_out,P3_R2_out,P3_R1_out,P3_RA_out,P3_RB_out:std_logic_vector(15 downto 0);
signal RF_A1,RF_A2,RF_A3:std_logic_vector(2 downto 0);
signal P3_R1_wr,P3_R2_wr,P3_RA_wr,P3_RB_wr,RF_wr,RF_rd:std_logic:=0;

 begin
   
   PC : sbitregister port map(clk => clk, d=>PCin, q=>PCout, ld=> PC_write, clr => clr);
   IM : instr_mem port map(clk => clk, addr => PC_out, memread => Inst_Mem_rd, data=>Inst_Mem_out); 
   P1_R1 : sbitregister port map(d => Inst_Mem_out, ld => P1_R1_wr, clk => clk, q => P1_R1_out, clr => clr);
	
	
	MUX1  : mux2x1 port map(A => P1_R2_out, B => ALU_3_C, C => PCin);
	P1_R2 : sbitregister port map(d => ALU_1_C, ld => P1_R2_wr, clk => clk, q => P1_R2_out, clr => clr);
	ALU_1 : ALU1 port map( A => PCout, B => '0000000000000100', C => ALU_1_C);
	
	-------------------------------ID---------------------------
	
	
	P2_R1 : sbitregister port map(d=>P1_R1_out, ld=> P2_R1_wr, clk => clk, clr => clr, q=> P2_R1_out);
	SE9 : se9 port map(din => P1_R1_out(8 downto 0), dout => se9_out);	--add a select line for se to for padding too
	SE6: se6 port map(din => P1_R1_out(5 downto 0), dout => se6_out);
	MUX2 : mux2x1 port map(A(0) => se9_out, A(1) => se6_out, S0=> Mux2_control, Z=>ALU_3_B);
	ALU_3 : ALU3 port map(A => P1_R2_out, B=> ALU_3_B, C=>ALU_3_C);
	P2_R2 : sbitregister port map(d=>P1_R2_out, ld=> P2_R2_wr, clk => clk, clr => clr, q=> P2_R2_out)
	---------------------------------IF----------------------------
	--varunav

	RF_RR : rf port map(clk=>clk,rst=>rst,a1=>RF_A1,a2=>RF_A2,a3=>RF_A3,D1=>RF_D1,D2=>RF_D2,D3=>RF_D3,wr=>RF_wr,rd=>RF_rd,pc=>PC)
	P3_R1 : sbitregister port map(d => P2_R1_out, ld => P3_R1_wr, clk => clk, q => P3_R1_out);
	P3_R2 : sbitregister port map(d => P2_R2_out, ld => P3_R1_wr, clk => clk, q => P3_R2_out);
	P3_RA : sbitregister port map(d => RF_D1, ld => P3_RA_wr, clk => clk, q => P3_RA_out);
	P3_RB : sbitregister port map(d => RF_D2, ld => P3_RB_wr, clk => clk, q => P3_RB_out);
	
	
	----------------------------------OR-----------------------------
	
	
	
   P4_R1 : sbitregister port map(d => P3_R1_out, ld => P4_R1_wr, clk => clk, q => P4_R1_out, clr => clr);
	P4_R2 : sbitregister port map(d => P3_R2_out, ld => P4_R2_wr, clk => clk, q => P4_R2_out, clr => clr);
	ALU_2 : ALU2 port map(A=>MUX2_out, B=> MUX3_out, c_flag=>cflag, z_flag=>zflag , C=> ALU2_out);
	MUX2_exe : mux_4to1 port map(S0 => , S1=> , A(0) => P3_RA_out, A(1) => ALU2_out, A(2)=> P5_R2_out, A(3) => dm_out, Z=>MUX2_out);
   MUX3_exe : mux_4to1 port map(S0 => , S1=> , A(0) => P3_RB_out, A(1) => ALU2_out, A(2)=> P5_R2_out, A(3) => dm_out, Z=>MUX3_out);
	P4_R4 : sbitregister port map(d => P3_RB_out, ld => P4_R4_wr, clk => clk, q => P4_R4_out, clr => clr);
	P4_R3 : sbitregister port map(d => ALU2_out, ld => P4_R3_wr, clk => clk, q => P4_R3_out, clr => clr);
	
	
	----------------------------EX---------------------------------
	
	P5_R1 : sbitregister port map(d =>P4_R1_out , ld =>P5_R1_wr, q => P5_R1_out, clk => clk, clr => clr);
	P5_R2 : sbitregister port map(d => P4_R2_out, ld => P5_R2_wr, q=> P5_R2_out, clk => clk, clr => clr);
	DEMUX1 : demux port map(I => P4_R3_out , S => demux1_s,O1 => demux_o1 , O2 => demux_o2); 
	DM : data_mem port map(mem_addr_in => demux_o1, mem_out => dm_out, clk => clk, mem_data_in => P4_R4_out  , data_memread => dm_rd, data_memwrite => dm_wr);
	MUX3 : mux2x1 port map( A(0) => demux_o2, A(1) => dm_out, Z => mux3_out, S0 => mux3_wr);
	P5_R3 : port map(d => mux3_out, ld = P5_R3_wr, q => P5_R3_out, clr => clr, clk => clk);
	
	---------------------------------MEM-------------------------------
	
	DEMUX2 : demux port map( I => P5_R3_out, S => demux2_s, O1 => RF_D3, O2 => demux2_o2);
	
	
	---------------------------------WB-------------------------------