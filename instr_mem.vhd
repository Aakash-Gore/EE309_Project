library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity instr_mem is
  port(clk : in std_logic;
       addr : in std_logic_vector(15 downto 0);
       memread : in std_logic;
       --memwrite: in std_logic;
       --datapointer: in std_logic_vector(15 downto 0);
        data : out std_logic_vector(15 downto 0));
end instr_mem;

architecture bhv of instr_mem is
type imemory_storage is array(0 to 255) of std_logic_vector(15 downto 0);
signal istorage: imemory_storage;

begin
  process(clk, addr, memread, istorage)
	 begin
	    if (clk'event and clk = '0') then 

	   istorage(0) <= "0001010101011000"; -- ADA
		istorage(1) <= "0001110011010010"; -- ADC	
		istorage(2) <= "0001011001101001"; -- ADZ
		istorage(3) <= "0001110010101011"; -- AWC
		istorage(4) <= "0001001001010100"; -- ACA
		istorage(5) <= "0001110110100110"; -- ACC
		istorage(6) <= "0001110011001101"; -- ACZ
		istorage(7) <= "0001001001010111"; -- ACW
		
		istorage(8) <= "0000110110110010"; -- ADI
		
		istorage(9) <= "0010101010101000"; -- NDU
		istorage(10) <= "0010101010101010"; -- NDC
		istorage(11) <= "0010110011001001"; -- NDZ
		istorage(12) <= "0010101010100100"; -- NCU
		istorage(13) <= "0010010101100110"; -- NCC
		istorage(14) <= "0010100101010101"; -- NCZ
		
		istorage(15) <= "0011110101010101"; -- LLI
		istorage(16) <= "0100110101011001"; -- LW
		istorage(17) <= "0101001100110100"; -- SW
		istorage(18) <= "0110100100100100"; -- LM
		istorage(19) <= "0111001001111001"; -- SM
		istorage(20) <= "1000100100111001"; -- BEQ
		istorage(21) <= "1001101001001110"; -- BLT
		istorage(22) <= "1001100100110010"; -- BLE
		istorage(23) <= "1100100110110010"; -- JAL
		istorage(24) <= "1101101010000000"; -- JLR
		istorage(25) <= "1111001001110011"; -- JRI



		if memread = '1' then
		    data <= istorage(to_integer(unsigned(addr)));
		end if;
	   end if;		
  end process;
end bhv;
