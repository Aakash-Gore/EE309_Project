library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity mux_2to1 is
 port(
     A : in STD_LOGIC_VECTOR(1 downto 0);
     S0: in STD_LOGIC;
     Z: out STD_LOGIC
  );
end mux_2to1;
 
architecture bhv of mux_2to1 is
begin
process (A,S0) is
begin
  if (S0 ='0') then
      Z <= A(1);
  else
      Z <= A(0);
  end if;
 
end process;
end bhv;