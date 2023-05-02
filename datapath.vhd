library ieee;
use ieee.std_logic_1164.all;

entity datapath is
	port(
		state : in std_logic_vector(3 downto 0);
		clk, rst : in std_logic;
		
		opcode : out std_logic_vector(3 downto 0);
		CZ_user : out std_logic_vector(1 downto 0);
		C, Z, eq : out std_logic);
end entity;

architecture behav of datapath is
component Priority_Encoder is 
	port (d: in std_logic_vector(7 downto 0);
			temp : out std_logic;
			dnext: out std_logic_vector(7 downto 0);
			q: out std_logic_vector(2 downto 0));
end component;
component SignExtender9 is 
	port (datain: in std_logic_vector(8 downto 0);
			
			dataout: out std_logic_vector(15 downto 0));
end component;

component threeto8_decoder is 
	port (s: in std_logic_vector(2 downto 0);
			y: out std_logic_vector(7 downto 0));
end component;


component memory is
	port (
		clk : in std_logic;
		rst : in std_logic;
		mem_rd : in std_logic;
		mem_wr : in std_logic;
		address : in std_logic_vector(15 downto 0);
   
		datain : in std_logic_vector(15 downto 0);
		dataout : out std_logic_vector(15 downto 0)) ;
end component ;

component onebitregister is 
	port( 
			d : in std_logic;
			rst: in std_logic;
			clk: in std_logic;
									
			q: out std_logic);
end component;

component sixteenbitregister is 
	port(         
			d : in std_logic_vector(15 downto 0);
			rst: in std_logic;
			clk: in std_logic;
			wr_en: in std_logic;
									
			q: out std_logic_vector(15 downto 0));
end component;


component sevenbitshifter is 
	port( datain : in std_logic_vector(8 downto 0);
									
									
			dataout: out std_logic_vector(15 downto 0));			
end component;

component SignExtender6 is 
	port (datain: in std_logic_vector(5 downto 0);
			
			dataout: out std_logic_vector(15 downto 0));
end component;



component SignExtender8 is 
	port (datain: in std_logic_vector(7 downto 0);
			
			dataout: out std_logic_vector(15 downto 0));
end component;


component register_file is 
    port(
      --address
      A1 : in std_logic_vector(2 downto 0);
      A2 : in std_logic_vector(2 downto 0);
      A3 : in std_logic_vector(2 downto 0);

      --datain
      D3 : in std_logic_vector(15 downto 0);
		--enables
      wr_en : in std_logic;
      rd_en : in std_logic;

      rst : in std_logic;
		clk : in std_logic;

      --dataout
      D1 : out std_logic_vector(15 downto 0);
      D2 : out std_logic_vector(15 downto 0);
		PC : out std_logic_vector(15 downto 0));
end component;

component ALU is
port( A: in std_logic_vector(15 downto 0);
      B: in std_logic_vector(15 downto 0);
		sel: in std_logic_vector(1 downto 0);
		
		C: out std_logic_vector(15 downto 0);
		Carry: out std_logic;
		Zero: out std_logic
		);
end component;
	signal ALU_A,ALU_B,ALU_C,Mem_Addr,Mem_Din,Mem_Dout,RF_D1,RF_D2,RF_D3,R7,PCin,PCout,IRin,IR,T1in,T1out,T2in,T2out,T3in,T3out,se9,se6,se8 : std_logic_vector(15 downto 0) := (others => '0');  --16 bit
	signal ALU_C0, ALU_Z, Z_flag, tempeq, tp: std_logic ;     --1 bit
	signal RF_A1, RF_A2, RF_A3, Pout : std_logic_vector(2 downto 0) := (others => '0');
	signal bit9in, unshifted : std_logic_vector(8 downto 0);
	signal bit8in, Pin, Pnext: std_logic_vector(7 downto 0);
	signal bit6in : std_logic_vector(5 downto 0);
	signal wr : std_logic_vector(6 downto 0) :="1111111"; --(others => '0');
	signal rd : std_logic_vector(1 downto 0) := (others => '1');
	signal ALU_sel : std_logic_vector(1 downto 0):="00";
	signal shifted : std_logic_vector (15 downto 0);
	signal s : std_logic_Vector(2 downto 0);
	signal y : std_logic_vector(7 downto 0);

begin

Mem : memory port map (clk => clk, rst => rst, mem_rd => rd(0), mem_wr => wr(0), address => Mem_Addr, datain => Mem_Din, dataout => Mem_Dout);
RegFile : register_file port map (A1 => RF_A1 , A2 => RF_A2, A3 => RF_A3, D3 => RF_D3, wr_en => wr(1), rd_en => rd(1), rst => rst, clk => clk, D1 => RF_D1, D2 => RF_D2, PC => R7);											
InstnReg : sixteenbitregister port map (d => IRin, rst => rst, clk => clk, wr_en => wr(2), q => IR);
PC : sixteenbitregister port map (d => PCin, rst => rst, clk => clk, wr_en => wr(6), q => PCout);
-- temporary registers
T1 : sixteenbitregister port map (d => T1in, rst => rst, clk => clk, wr_en => wr(3), q => T1out);
T2 : sixteenbitregister port map (d => T2in, rst => rst, clk => clk, wr_en => wr(4), q => T2out);
T3 : sixteenbitregister port map (d => T3in, rst => rst, clk => clk, wr_en => wr(5), q => T3out);
-- One bit registers
--C_flag : onebitregister port map (d, rst => rst, clk => clk, wr_en, q);
--Z_Flag : onebitregister port map (d, rst => rst, clk => clk, wr_en, q);
--Z : onebitregister port map (d, rst => rst, clk => clk, wr_en, q);
-- Components
ALU_fn : ALU port map (A => ALU_A, B => ALU_B, sel => ALU_sel, C => ALU_C, Carry => ALU_C0, Zero => ALU_Z);
shifter : sevenbitshifter port map (datain => unshifted, dataout => shifted);
PE : Priority_Encoder port map (d => Pin, temp => tp, dnext =>Pnext, q => Pout);
decoder : threeto8_decoder port map (s => s, y => y);
SE_9 : SignExtender9 port map (datain => bit9in , dataout => se9);
SE_6 : SignExtender6 port map (datain => bit6in , dataout => se6);
SE_8 : SignExtender8 port map (datain => bit8in, dataout => se8);

opcode <= IR(15 downto 12);
CZ_user <= IR(1 downto 0);
C <= ALU_C0;
Z <= Z_flag;
eq <= tempeq;
process(state)
	begin	
		case state is 
			when "0000" => 
				-- s0
				RF_A1 <= "111";
				
				if (IR(15 downto 12) = "0000" or IR(15 downto 12) = "0010") then --s1
				   wr <= "1011100";
					rd <= "10";
					mem_Addr <= PCout; 
					IRin <= Mem_Dout;
					RF_A1 <= IR(11 downto 9);
					T1in <= RF_D1;
					RF_A2 <= IR(8 downto 6);
					T2in <= RF_D2;
					PCin <= R7;
					
				elsif (IR(15 downto 12) = "0001" or IR(15 downto 12) =  "0100" or IR(15 downto 12) =  "0101" or IR(15 downto 12) =  "1100" or IR(15 downto 12) =  "1001") then --s2
					wr <= "1011100";
					rd <= "10";
					mem_Addr <= PCout; 
					IRin <= Mem_Dout;
					RF_A2 <= IR(8 downto 6);
					T1in <= RF_D2;
					bit6in <= IR(5 downto 0);
					T2in <= se6;
					PCin <= R7;
					
				elsif (IR(15 downto 12) = "0110" or IR(15 downto 12) = "0111") then --s3
					wr <= "1101100";
					rd <= "10";
					mem_Addr <= PCout; 
					IRin <= Mem_Dout;
					bit9in <= IR(8 downto 0);
					T1in <= se9;
					RF_A1 <= IR(11 downto 9);
					T3in <= RF_D1;
					PCin <= R7;
					
				elsif (IR(15 downto 12) = "0011") then --s12
					wr <= "1000110";
					rd <= "00";
					mem_Addr <= PCout; 
					IRin <= Mem_Dout;
					unshifted <= IR(8 downto 0);
					RF_A3 <= IR(11 downto 9);
					RF_D3 <= shifted;
					PCin <= R7;
					
				end if;	
					
				
			when "0001" => --s4 (NAND)
				wr <= "0100010";
				rd <= "00";
				ALU_sel <= "10";
				ALU_A <= T1out;
				ALU_B <= T2out;
				T3in <= ALU_C;
				RF_A3 <= IR(5 downto 3);
				RF_D3 <= T3out;
				
			when "0010" => --s5 (ADD)
				wr <= "0100010";
				rd <= "00";
				ALU_A <= T1out;
				ALU_B <= T2out;
				ALU_sel <= "00";
				T3in <= ALU_C;
				RF_A3 <= IR(5 downto 3);
				RF_D3 <= T3out;
				
				
				
				
			when "0011" => --s6 (ADD)
				wr <= "0101010";
				rd <= "10";
				RF_A1 <= IR(11 downto 9);
				T1in <= RF_D1;
				ALU_A <= T1out;
				ALU_B <= T2out;
				ALU_sel <= "00";
				T3in <= ALU_C;
				RF_A3 <= IR(8 downto 6);
				RF_D3 <= T3out;
				
				
				
			when "0100" => -- s7 (PURE ADD)
				wr <= "0100010";
				rd <= "10";
				ALU_A <= T1out;
				ALU_B <= T2out;
				ALU_sel <= "11";
				T3in <= ALU_C;
				Mem_Addr <= T3out;
				RF_A3 <= IR(11 downto 9);
				RF_D3 <= Mem_Dout;
				
				
				
				
			when "0101" => --s8 (ADD)
				wr <= "0101001";
				rd <= "10";
				ALU_A <= T1out;
				ALU_B <= T2out;
				ALU_sel <= "00";
				T3in <= ALU_C;
				RF_A1 <= IR(11 downto 9);
				T1in <= RF_D1;
				Mem_Addr <= T3out;
				Mem_Din <= T1in;
				
				
				
			when "0110" => --s9 (SUB)
			   wr <= "0010000";
				rd <= "10";
				RF_A1 <= IR(11 downto 9);
				T2in <= RF_D1;
				ALU_A <= T1out;
				ALU_B <= T2out;
				ALU_sel <= "01";
				if (ALU_C = "0000000000000000") then
					tempeq <= '1';
				else
					tempeq <= '0';
				end if;	
				
			when "0111" => --s10 (ADD)
				wr <= "1000010";
				rd <= "00";
				RF_A3 <= IR(11 downto 9);
				RF_D3 <= PCout;
				ALU_A <= PCout;
				bit9in <= IR(8 downto 0);
				ALU_B <= se9;
				PCin <= ALU_C;
				ALU_sel <= "00";
				
			when "1000" => --s11
				wr <= "1000010";
				rd <= "00";
				RF_A3 <= IR(11 downto 9);
				RF_D3 <= PCout;
				PCin <= T1in;
				
				
			when "1001" => --s13
				wr <= "1000000";
				rd <= "00";
				Pin <= T1out(7 downto 0);
				
			when "1010" => --s14
				wr <= "0000010";
				rd <= "01";
				Mem_Addr <= T3out;
				RF_A3 <= Pout;
				RF_D3 <= Mem_Dout;
				
			when "1011" => --s15
				wr <= "0000001";
				rd <= "10";
				Mem_Addr <= T3out;
				RF_A2 <= Pout;
				Mem_Din <= RF_D2;
				
				

				
			when "1100" => --s16 (SUB)
				wr <= "0001000";
				rd <= "00";
				s <= Pout;
				bit8in <= y;
				ALU_B <= se8;
				ALU_A <= T1out;
				ALU_sel <= "01";
				T1in <= ALU_C;
				if (T1out = "0000000000000000") then
					tempeq <= '1';
				else
					tempeq <= '0';
				end if;	
				
				
			--when "1101" =>
				--ALU_A <= T1out;
				--ALU_B <= T2out;
				--T3in <= ALU_C;
				--RF_A1 <= IR(11 downto 9);
				--T1in <= RF_D1;
				--Mem_Addr <= T3out;
				--Mem_Din <= T1;
				--ALU_sel <= "00";
				--wr <= "";
				--rd <= "";
			when "1101" => --s17
			      wr <= "0000000";
					rd <= "00";
				if (IR(15 downto 12) = "0100") then
					if (T3out = "0000000000000000") then
						Z_flag <= '1';
					else 
						Z_flag <= '0';
					end if;
				else
					Z_flag <= ALU_Z;
				end if;	
					
					
				
			when "1110" => --s16' (PURELY ADD)
				wr <= "0100000";
				rd <= "00";
				ALU_A <= T3out;
				ALU_B <= "0000000000010000";
				T3in <= ALU_C;
				ALU_sel <= "11";
				
			when "1111" => 
			   wr <= "1000000";
				rd <= "00";
				ALU_A <= PCout; --s19 (PURELY ADD)
				if (tempeq = '1') then
					bit6in <= IR(5 downto 0);
					ALU_B <= se6;
				else 
					ALU_B <= "0000000000000001";
				end if;
				ALU_sel <= "11";
				PCin <= ALU_C;

			when others =>
				
		end case;
	end process;

end behav;