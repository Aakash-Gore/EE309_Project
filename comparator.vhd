library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity comparator is
    Port ( A,B : in std_logic_vector(15 downto 0);
           G,S,E: out std_logic_vector(15 downto 0)
			  );
end comparator;

architecture comp_arch of comparator is
  begin
  l: for i in 0 to 15 loop
		G(i) <= A(i) and (not B(i));
		S(i) <= (not A(i)) and B(i);
		E(i) <= A(i) xnor B(i);
end comp_arch;
