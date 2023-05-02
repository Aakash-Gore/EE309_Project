library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity mux_4to1 is
 port(
     A : in STD_LOGIC_VECTOR(3 downto 0);
     S0,S1: in STD_LOGIC;
     Z: out STD_LOGIC
  );
end mux_4to1;
 
architecture bhv of mux_4to1 is
begin
process (A,S0,S1) is
begin
  if (S0 ='0' and S1 = '0') then
      Z <= A(3);
  elsif (S0 ='1' and S1 = '0') then
      Z <= A(2);
  elsif (S0 ='0' and S1 = '1') then
      Z <= A(1);
  else
      Z <= A(0);
  end if;
 
end process;
end bhv;
