----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:46:12 11/16/2015 
-- Design Name: 
-- Module Name:    fd_clk - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fd_clk is
    Port ( clk : in  STD_LOGIC;
           main_clk : out  STD_LOGIC);
end fd_clk;

architecture Behavioral of fd_clk is
begin
	process(clk)
		variable cnt: integer range 0 to 4:= 0;
	begin
		if(clk'event and clk = '1') then
			cnt := cnt + 1;
			if(cnt = 2) then
				main_clk <= '1';
			end if;
			if(cnt = 4) then
				main_clk <= '0';
				cnt := 0;
			end if;
		end if;
	end process;
end Behavioral;

