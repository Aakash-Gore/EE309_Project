library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instr_mem is
  port(addr : in std_logic_vector(15 downto 0);
       memread : in std_logic;
       memwrite: in std_logic;
       datapointer: in std_logic_vector(15 downto 0);
        data : out std_logic_vector(15 downto 0);
       )
end instr_mem;

architecture bhv of instr_mem is
type memory_storage is array(0 to 255) of std_logic_vector(15 downto 0);
signal storage: memory_storage;

begin
  process(PC_in, memread, memwrite, pipe1_reg1)
	 begin
	   storage(0) <= "0001xxxxxxxxx000"; -- ADA
		storage(1) <= "0001xxxxxxxxx010"; -- ADC	
		storage(2) <= "0001xxxxxxxxx001"; -- ADZ
		storage(3) <= "0001xxxxxxxxx011"; -- AWC
		storage(4) <= "0001xxxxxxxxx100"; -- ACA
		storage(5) <= "0001xxxxxxxxx110"; -- ACC
		storage(6) <= "0001xxxxxxxxx101"; -- ACZ
		storage(7) <= "0001xxxxxxxxx111"; -- ACW
		
		storage(8) <= "0000xxxxxxxxxxxx"; -- ADI
		
		storage(9) <= "0010xxxxxxxxx000"; -- NDU
		storage(10) <= "0010xxxxxxxxx010"; -- NDC
		storage(11) <= "0010xxxxxxxxx001"; -- NDZ
		storage(12) <= "0010xxxxxxxxx100"; -- NCU
		storage(13) <= "0010000101100110"; -- NCC
		storage(14) <= "0010000101000101"; -- NCZ
		
		storage(15) <= "0011xxxxxxxxxxxx"; -- LLI
		storage(16) <= "0100xxxxxxxxxxxx"; -- LW
		storage(17) <= "0101xxxxxxxxxxxx"; -- SW
		storage(18) <= "0110xxxxxxxxxxxx"; -- LM
		storage(19) <= "0111xxxxxxxxxxxx"; -- SM
		storage(20) <= "1000xxxxxxxxxxxx"; -- BEQ
		storage(21) <= "1001xxxxxxxxxxxx"; -- BLT
		storage(22) <= "1001xxxxxxxxxxxx"; -- BLE
		storage(23) <= "1100xxxxxxxxxxxx"; -- JAL
		storage(24) <= "1101xxxxxx000000"; -- JLR
		storage(25) <= "1111xxxxxxxxxxxx"; -- JRI

		if memread = '1' then
		    pipe1_reg1 <= storage(to_integer(unsigned(datapointer)));
		end if;
		
		if memwrite = '1' then
		    storage(to_integer(unsigned(datapointer))) <= PC_in;
		end if;
		
  end process;
end bhv;
