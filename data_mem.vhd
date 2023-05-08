library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
entity data_mem is
  port(
    clk           : in  std_logic;
    mem_data_in   : in  std_logic_vector(15 downto 0); -- from P4-R4
    mem_addr_in   : in  std_logic_vector(15 downto 0); -- from demux
    data_memread  : in  std_logic;
    data_memwrite : in  std_logic;
    mem_out       : out std_logic_vector(15 downto 0) -- to mux
  );
end data_mem;

architecture data_mem of data_mem is 
  type dmemory_storage is array(0 to 255) of std_logic_vector(15 downto 0);
  signal dstorage : dmemory_storage := (others => "0000000000000000");
	 
begin
  process(clk, mem_data_in, mem_addr_in, data_memread, data_memwrite, dstorage)
  begin 
    if (falling_edge(clk)) then 
      if (data_memwrite = '1') then
        dstorage(to_integer(unsigned(mem_addr_in))) <= mem_data_in;
      end if;
    end if;
  
	
  if data_memread = '1' then	
    mem_out <= dstorage(to_integer(unsigned(mem_addr_in)));
  end if;	
	end process;	
end architecture;
