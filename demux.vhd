library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity demux is
    Port ( I : in std_logic_vector(15 downto 0);
	        S : in std_logic;
           O1, O2 : out std_logic_vector(15 downto 0));
end entity;

architecture bhv of demux is

begin
process(I, S)
begin
if S <= '0' then
   O1 <= I;
	O2 <= "0000000000000000";
elsif S <= '1' then
   O2 <= I;
	O1 <= "0000000000000000";
end if;

end process;
end bhv;
