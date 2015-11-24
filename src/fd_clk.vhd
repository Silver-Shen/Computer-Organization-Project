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
use IEEE.STD_LOGIC_unsigned.ALL;

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
signal cnt: std_logic_vector(1 downto 0):= "00";
begin
	main_clk <= cnt(0);
	process(clk)
	begin
		if(rising_edge(clk)) then
			cnt <= cnt + 1;
		end if;
	end process;
end Behavioral;

