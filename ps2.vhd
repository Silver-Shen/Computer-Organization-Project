----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:32:06 11/21/2015 
-- Design Name: 
-- Module Name:    ps2 - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ps2 is
    Port ( fclk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
			  out_data : out STD_LOGIC_VECTOR(7 downto 0);	--指令码，控制屏幕输出
			  data_ready : out STD_LOGIC := '1');				--0表示有一个新的输出
end ps2;

architecture Behavioral of ps2 is
	signal data, clk, clk1, clk2: STD_LOGIC;
	signal wholedata: STD_LOGIC_VECTOR(10 downto 0) :="00000000000";
	signal used_data :STD_LOGIC_VECTOR(7 downto 0) := x"00";
	type SM is (s0,b,d);		--准备，获取断码状态，获取通码状态
	signal state : SM := s0;
	signal tmp_clk : std_logic:= '0';
begin
	clk1 <= ps2clk when rising_edge(fclk);
	clk2 <= clk1 when rising_edge(fclk);
	clk <= (not clk1) and clk2;
	data <= ps2data when rising_edge(fclk);

	--无差别获取键盘输入
	process(rst,clk)
	variable counter : integer range 0 to 10 := 0;
	begin
		if (rst = '0')then
			wholedata <= "00000000000";
			counter := 0;
		elsif (rising_edge(clk)) then
			wholedata(counter) <= data;
			if (counter = 10) then
				counter := 0;
				used_data <= wholedata(8 downto 1);
				tmp_clk <= '0';
			else
				counter := counter + 1;
				if (counter = 5) then
					tmp_clk <= '1';
				end if;
			end if;
		end if;
	end process;
	
	process(clk)
	variable tmp_data : std_logic_vector(7 downto 0);
	begin
		if (clk'event and clk = '1') then
		case state is
		when s0 =>
			if(used_data = x"F0")then
				state <= b;
			else
				tmp_data := used_data;
				out_data <= used_data;
				data_ready <= '1';
			end if;
		when b =>
			data_ready <= '0';
			state <= d;
		when d =>
			if (tmp_data = used_data) then
				state <= s0;
				tmp_data := "00000000";
				out_data <= "00000000";
			end if;
		end case;
		end if;
	end process;
end Behavioral;

