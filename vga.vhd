----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:45 11/19/2015 
-- Design Name: 
-- Module Name:    vga - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga is
    Port (
				clk 	: in  STD_LOGIC;
           	rst 	: in  STD_LOGIC;
				R 		: out STD_LOGIC_VECTOR (2 downto 0);
				G 		: out STD_LOGIC_VECTOR (2 downto 0);
				B 		: out STD_LOGIC_VECTOR (2 downto 0);
				Hs 	: out STD_LOGIC ;
				Vs 	: out STD_LOGIC ;
				data : in STD_LOGIC_VECTOR(7 downto 0);
				data_ready : in STD_LOGIC);
end vga;

--x:30,y:20
architecture Behavioral of vga is
	signal fd_clk : STD_LOGIC ;
	signal color: STD_LOGIC;
	signal hsv,vsv: STD_LOGIC;
	signal x	: integer range 0 to 799;
	signal y : integer range 0 to 524;
	type index_array is array(0 to 599) of integer range 0 to 39;
	shared variable index : index_array := (
	37,37,0,33,15,22,13,25,23,15,0,30,25,0,38,22,19,17,18,30,39,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	type alpha is array(0 to 39) of STD_LOGIC_VECTOR(127 downto 0);
	constant alphas : alpha := (
	x"00000000000000000000000000000000",
	x"00001824424242424242422418000000",
	x"00007C10101010101010101C10000000",
	x"00007E4204081020404242423C000000",
	x"00003C4242402018204042423C000000",
	x"0000F82020FE22242428303020000000",
	x"00001C22424040221E0202027E000000",
	x"00003844424242463A02022418000000",
	x"0000080808080810102020427E000000",
	x"00003C4242422418244242423C000000",
	x"0000182440405C62424242221C000000",
	x"0000e74242223c241414180808000000",
	x"00001f22424242221e2222221f000000",
	x"00001c2242010101010142427c000000",
	x"00001f2242424242424242221f000000",
	x"00003f42420212121e1212423f000000",
	x"00000702020212121e1212423f000000",
	x"00001c2222217101010122223c000000",
	x"0000e7424242427e42424242e7000000",
	x"00003e0808080808080808083e000000",
	x"0f11101010101010101010107c000000",
	x"000077222212120a0e0a122277000000",
	x"00007f42020202020202020207000000",
	x"00006b2a2a2a2a2a3636363677000000",
	x"00004762625252524a4a4646e3000000",
	x"00001c2241414141414141221c000000",
	x"000007020202023e424242423f000000",
	x"00601c32534d4141414141221c000000",
	x"0000c742222212123e4242423f000000",
	x"00003e4242402018040242427c000000",
	x"00001c0808080808080808497f000000",
	x"00003c424242424242424242e7000000",
	x"000008081814142424224242e7000000",
	x"0000222222365555494949496b000000",
	x"0000e7422424181818242442e7000000",
	x"00001c08080808081414222277000000",
	x"00003f4242040408101020217e000000",
	x"00000204081020402010080402000000",
	x"00780808080808080808080808087800",
	x"001e1010101010101010101010101e00");
begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			fd_clk <= not fd_clk;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			x <= 0;
		elsif rising_edge(fd_clk) then
			if (x = 799) then
				x <= 0;
			else
				x <= x + 1;
			end if;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			y <= 0;
		elsif rising_edge(fd_clk) then
			if (x = 799) then
				if (y = 524) then
					y <= 0;
				else
					y <= y + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			hsv <= '1';
		elsif rising_edge(fd_clk) then
			if (x >= 656 and x < 752) then
				hsv <= '0';
			else
				hsv <= '1';
			end if;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			vsv <= '1';
		elsif rising_edge(fd_clk) then
			if (y >= 490 and y < 492) then
				vsv <= '0';
			else
				vsv <= '1';
			end if;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			Hs <= '1';
		elsif rising_edge(fd_clk) then
			Hs <= hsv;
		end if;
	end process;
	
	process(fd_clk,rst)
	begin
		if (rst = '0') then
			Vs <= '1';
		elsif rising_edge(fd_clk) then
			Vs <= vsv;
		end if;
	end process;
	
	--------------------------used--------------------------
	process(fd_clk,rst,x,y)
	variable seq_x : integer range 0 to 29;
	variable seq_y : integer range 0 to 19;
	variable num1 : integer range 0 to 599;
	variable num2 : integer range 0 to 127;
	begin
		if (rst = '0') then
			color <= '0';
			seq_x := 0;
			seq_y := 0;
		elsif(rising_edge(fd_clk)) then
			if(x < 80 or x >= 320 or y < 80 or y >= 400) then
				color <= '0';
			else
				seq_x := conv_integer(to_stdlogicvector(to_bitvector(conv_std_logic_vector(x - 80,10)) srl 3));
				seq_y := conv_integer(to_stdlogicvector(to_bitvector(conv_std_logic_vector(y - 80,9)) srl 4));
				num1 := seq_x + seq_y * 30;
				num2 := x - 80 - seq_x * 8 + (y - 80 - seq_y * 16) * 8;
				color <= alphas(index(num1))(num2);
			end if;
		end if;
	end process;
	
	process(hsv,vsv,color)
	begin
		if (hsv = '1' and vsv = '1') then
			R <= (others => color);
			G <= (others => color);
			B <= (others => color);
		else
			R <= (others => '0');
			G <= (others => '0');
			B <= (others => '0');
		end if;
	end process;
	
	process(data_ready)
	variable col: integer range 0 to 29:=0;
	variable row: integer range 0 to 19:=1;
	variable se: integer range 0 to 599:= 0;
	variable number : std_logic_vector(7 downto 0):= "00000000";
	begin

		if(falling_edge(data_ready))then
		   number := data;
			if(data = x"5A")then				--»Ø³µ
				if(row = 19)then
						row := 0;
					else
						row := row + 1;
					end if;
				col := 0;
			elsif(data = x"66")then			--ÍË¸ñ
				if(col > 0)then
					col := col- 1;
					se := col + row * 30;
					index(se) := 0;
				end if;
			else
					se := col + row * 30;
				case data is
					when x"45" =>index(se) := 1;
					when x"16" =>index(se) := 2;
					when x"1E" =>index(se) := 3;
					when x"26" =>index(se) := 4;
					when x"25" =>index(se) := 5;
					when x"2E" =>index(se) := 6;
					when x"36" =>index(se) := 7;
					when x"3D" =>index(se) := 8;
					when x"3E" =>index(se) := 9;
					when x"46" =>index(se) := 10;
					when x"1C" =>index(se) := 11;
					when x"32" =>index(se) := 12;
					when x"21" =>index(se) := 13;
					when x"23" =>index(se) := 14;
					when x"24" =>index(se) := 15;
					when x"2B" =>index(se) := 16;
					when x"34" =>index(se) := 17;
					when x"33" =>index(se) := 18;
					when x"43" =>index(se) := 19;
					when x"3B" =>index(se) := 20;
					when x"42" =>index(se) := 21;
					when x"4B" =>index(se) := 22;
					when x"3A" =>index(se) := 23;
					when x"31" =>index(se) := 24;
					when x"44" =>index(se) := 25;
					when x"4D" =>index(se) := 26;
					when x"15" =>index(se) := 27;
					when x"2D" =>index(se) := 28;
					when x"1B" =>index(se) := 29;
					when x"2C" =>index(se) := 30;
					when x"3C" =>index(se) := 31;
					when x"2A" =>index(se) := 32;
					when x"1D" =>index(se) := 33;
					when x"22" =>index(se) := 34;
					when x"35" =>index(se) := 35;
					when x"1A" =>index(se) := 36;
					when x"49" =>index(se) := 37;
					when x"54" =>index(se) := 38;
					when x"5B" =>index(se) := 39;
					when others=>index(se) := 0;
				end case;
					if(col = 29)then
						if(row = 19)then
							row := 0;
						else
							row := row + 1;
						end if;
						col := 0;
					else
						col := col + 1;
					end if;
			end if;
		end if;
	end process;
end Behavioral;

