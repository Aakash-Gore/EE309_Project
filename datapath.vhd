library ieee;
use ieee.std_logic_1164.all;

entity datapath is
	port(
		clk, rst : in std_logic;
		);
end entity;

architecture behav of datapath is
  
component clock_generator is
    port (
        clk : out std_logic
    );
end component;

component ALU1  is

  port(	
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			C: out std_logic_vector(15 downto 0)
		);
		
end component ALU1;

component ALU2  is

  port(	
  
         sel : in std_logic;
			A: in std_logic_vector(15 downto 0); 
			B: in std_logic_vector(15 downto 0);
			c_flag: out std_logic;
			z_flag: out std_logic;
			
			C: out std_logic_vector(15 downto 0)
		);
		
end component ALU2;

component mux_4to1 is
 port(
     A : in STD_LOGIC_VECTOR(3 downto 0);
     S0,S1: in STD_LOGIC;
     Z: out STD_LOGIC
  );
end component mux_4to1;

component data_mem is
  port(  clk : in std_logic;
	 mem_data_in : in std_logic_vector(15 downto 0); -- from P4-R4
	 mem_addr_in : in std_logic_vector(15 downto 0);  -- from demux
	 data_memread  : in std_logic;
	 data_memwrite : in std_logic;
	 mem_out : out std_logic_vector(15 downto 0);  -- to mux
       )
end component data_mem;

component decoder3_8 is
port ( sel : in STD_LOGIC_VECTOR (2 downto 0);
       y : out STD_LOGIC_VECTOR (7 downto 0));
component decoder3_8;

component demux is
    Port ( I,S : in  STD_LOGIC;
           O1, O2 : out  STD_LOGIC);
end component demux;

component instr_mem is
  port(clk : in std_logic;
       addr : in std_logic_vector(15 downto 0);
       memread : in std_logic;
       --memwrite: in std_logic;
       --datapointer: in std_logic_vector(15 downto 0);
        data : out std_logic_vector(15 downto 0);
       )
component instr_mem;

component sbitregister is
	port (d : in std_logic_vector(15 downto 0);
			ld : in std_logic;
			clk : in std_logic;
			clr : in std_logic;
			q : out std_logic_vector(15 downto 0));
end component sbitregister;

component se6 is
	port(din:in std_logic_vector(5 downto 0);
		  dout:out std_logic_vector(15 downto 0));
end component;

component se9 is
	port(din:in std_logic_vector(8 downto 0);
		  dout:out std_logic_vector(15 downto 0));
end component;

component twobitregister is
	port (d : in std_logic_vector(1 downto 0);
			ld : in std_logic;
			clk : in std_logic;
			clr : in std_logic;
			q : out std_logic_vector(1 downto 0));
end component;


signal ALU_1_A,ALU_1_B,ALU_1_C,ALU_2_A,ALU_2_B,ALU_2_C,ALU_3_A,ALU_3_B,ALU_3_C,
       Data_Mem_Addr,Data_Mem_Din,Data_Mem_Dout,Inst_Mem_addr,Inst_Mem_data,
	   P1_R1_out,P1_R2_out
	   RF_D1,RF_D2,RF_D3,R7,PCin,PCout,se9,se6 : std_logic_vector(15 downto 0) := (others => '0');
signal Inst_Mem_rd, P1_R1_wr,P1_R2_wr, clr, rst

       

 begin
   
   IM : instr_mem port map(clk => clk, addr => PC_out, memread => Inst_Mem_rd, data=>Inst_Mem_data);
	P1_R1 : sbitregister port map(d => Inst_Mem_Data, ld => P1_R1_wr, clk => clk, q => P1_R1_out);
	P1_R2 : sbitregister port map(d => ALU_1_C, ld => P1_R2_wr, clk => clk, q => P1_R2_out);
	ALU_1 : ALU1 port map(
	
	RegFile : rf port map(a1 => )