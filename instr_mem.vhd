library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instr_mem is
  port(clk : in std_logic;
       addr : in std_logic_vector(15 downto 0);
       memread : in std_logic;
       --memwrite: in std_logic;
       --datapointer: in std_logic_vector(15 downto 0);
        data : out std_logic_vector(15 downto 0);
       )
end instr_mem;

architecture bhv of instr_mem is
type imemory_storage is array(0 to 255) of std_logic_vector(15 downto 0);
signal istorage: imemory_storage;

begin
  process(clk, addr, memread, memwrite, data)
	 begin
	    if (clk'event and clk = '1') then 

	        istorage(0) <= "0001xxxxxxxxx000"; -- ADA
		istorage(1) <= "0001xxxxxxxxx010"; -- ADC	
		istorage(2) <= "0001xxxxxxxxx001"; -- ADZ
		istorage(3) <= "0001xxxxxxxxx011"; -- AWC
		istorage(4) <= "0001xxxxxxxxx100"; -- ACA
		istorage(5) <= "0001xxxxxxxxx110"; -- ACC
		istorage(6) <= "0001xxxxxxxxx101"; -- ACZ
		istorage(7) <= "0001xxxxxxxxx111"; -- ACW
		
		istorage(8) <= "0000xxxxxxxxxxxx"; -- ADI
		
		istorage(9) <= "0010xxxxxxxxx000"; -- NDU
		istorage(10) <= "0010xxxxxxxxx010"; -- NDC
		istorage(11) <= "0010xxxxxxxxx001"; -- NDZ
		istorage(12) <= "0010xxxxxxxxx100"; -- NCU
		istorage(13) <= "0010000101100110"; -- NCC
		istorage(14) <= "0010000101000101"; -- NCZ
		
		istorage(15) <= "0011xxxxxxxxxxxx"; -- LLI
		istorage(16) <= "0100xxxxxxxxxxxx"; -- LW
		istorage(17) <= "0101xxxxxxxxxxxx"; -- SW
		istorage(18) <= "0110xxxxxxxxxxxx"; -- LM
		istorage(19) <= "0111xxxxxxxxxxxx"; -- SM
		istorage(20) <= "1000xxxxxxxxxxxx"; -- BEQ
		istorage(21) <= "1001xxxxxxxxxxxx"; -- BLT
		istorage(22) <= "1001xxxxxxxxxxxx"; -- BLE
		istorage(23) <= "1100xxxxxxxxxxxx"; -- JAL
		istorage(24) <= "1101xxxxxx000000"; -- JLR
		istorage(25) <= "1111xxxxxxxxxxxx"; -- JRI

		if memread = '1' then
		    data <= istorage(to_integer(unsigned(addr)));
		end if;
	   end if;		
  end process;
end bhv;
