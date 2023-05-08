library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity mux_4to1 is
 port(
     A : in STD_LOGIC_VECTOR(15 downto 0);
	  B : in STD_LOGIC_VECTOR(15 downto 0);
	  C : in STD_LOGIC_VECTOR(15 downto 0);
	  D : in STD_LOGIC_VECTOR(15 downto 0);
     S0,S1: in STD_LOGIC;
     Z: out STD_LOGIC_VECTOR(15 downto 0)
  );
end mux_4to1;
 
architecture bhv of mux_4to1 is
begin
process (A,B,C,D,S0,S1) is
begin
  if (S0 ='0' and S1 = '0') then
      Z <= D;
  elsif (S0 ='1' and S1 = '0') then
      Z <= C;
  elsif (S0 ='0' and S1 = '1') then
      Z <= B;
  else
      Z <= A;
  end if;
 
end process;
end bhv;
