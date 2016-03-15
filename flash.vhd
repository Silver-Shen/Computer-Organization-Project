----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:59:19 11/24/2015 
-- Design Name: 
-- Module Name:    flash - Behavioral 
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flash is
    Port ( flash_clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           --flash_addr_in : in  STD_LOGIC_VECTOR(15 downto 0);
           flash_data : inout  STD_LOGIC_VECTOR(15 downto 0);
           flash_addr_out : out  STD_LOGIC_VECTOR(22 downto 0);
			  
			  --state_show : out  STD_LOGIC_VECTOR(3 downto 0);
           --flash_data_show : out  STD_LOGIC_VECTOR(15 downto 0);
           flash_byte :out	STD_LOGIC;
			  flash_vpen :out	STD_LOGIC;
			  flash_ce : out	STD_LOGIC;
			  flash_rp :out	STD_LOGIC;
			  flash_we : out	STD_LOGIC;
			  flash_oe : out	STD_LOGIC;
			  --flash_ram_oe : out	STD_LOGIC;
			  --flash_ram_we : out	STD_LOGIC;
			  --flash_ram_en : out	STD_LOGIC;
           flash_data_to_ram : out  STD_LOGIC_VECTOR(15 downto 0);
           flash_addr_to_ram : out  STD_LOGIC_VECTOR(17 downto 0);
			  flash_cpu_en : out	STD_LOGIC);
end flash;

architecture Behavioral of flash is
	
	type flash_state is (s1, s2, s3, s4);
	signal now_state : flash_state;
	signal flash_addr : STD_LOGIC_VECTOR(22 downto 0);
	signal flash_addr_ram : STD_LOGIC_VECTOR(15 downto 0);
begin
	process (flash_clk, rst)
		variable next_state : flash_state;
	begin
		if (rst = '0')then
			flash_we <= '0';
			flash_data <= x"00ff";
			flash_byte <= '1';
			flash_vpen <= '1';
			flash_ce <= '0';
			flash_rp <= '1';
			--flash_ram_oe <= '1';
			--flash_ram_we <= '1';
			flash_addr <= "00000000000000000000000";
			flash_addr_ram <= x"0000";
			flash_cpu_en <= '1';
			next_state := s2;
		else
			if (flash_addr_ram < x"0800")then
				flash_cpu_en <= '1';
				if (flash_clk'event and flash_clk = '1')then
					case (now_state) is
						when s1 =>
							flash_we <= '0';
							flash_data <= x"00ff";
							flash_byte <= '1';
							flash_vpen <= '1';
							flash_ce <= '0';
							flash_rp <= '1';
							flash_addr <= "00000000000000000000000";
							flash_addr_ram <= x"0000";
							next_state := s2;
							--state_show <= "0010";
						when s2 =>
							flash_we <= '1';
							next_state := s3;
							--state_show <= "0100";
						when s3 =>
							flash_oe <= '0';
							flash_addr <= flash_addr + 2;
							flash_addr_out <= flash_addr + 2;
							flash_addr_ram <= flash_addr_ram + 1;
							flash_addr_to_ram <= "00" & flash_addr_ram;
							flash_data <= "ZZZZZZZZZZZZZZZZ";
							next_state := s4;
							--state_show <= "1000";
						when s4 =>
							flash_oe <= '1';
							flash_data_to_ram <= flash_data;
							next_state := s2;
							--state_show <= "0001";
					end case;
				end if;
			else
				flash_cpu_en <= '0';
			end if;
		end if;
		now_state <= next_state;
		--flash_addr_show <= flash_addr(15 downto 0);
	end process;


end Behavioral;

