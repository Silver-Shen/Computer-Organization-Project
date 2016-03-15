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
    Port (  rst      : in STD_LOGIC;
            clk      : in  STD_LOGIC;            
            main_clk : out  STD_LOGIC;            
            --for double kernel
            mode     : out std_logic := '0';
            stall    : inout STD_LOGIC := '1';
				pc_stall : out std_logic := '1';
				--test
				time_slice_signal : out STD_LOGIC_VECTOR(3 downto 0);
				flush_count_signal : out STD_LOGIC_VECTOR(2 downto 0);
				hclk		: in STD_LOGIC;
				clk_mode : in STD_LOGIC;
				uart_clk : in STD_LOGIC;
				--flash
            cpu_en   : in STD_LOGIC; 
            flash_clk: out STD_LOGIC
				);
end fd_clk;

architecture Behavioral of fd_clk is
    signal cnt: std_logic_vector(1 downto 0):= "00";   
    signal time_slice : std_logic_vector(3 downto 0) := "0000";
    signal flush_count: std_logic_vector(2 downto 0) := "000";
	 signal inner_clk : std_logic;
    signal inner_mode:std_logic;
	 signal cnt_flash: std_logic_vector(1 downto 0):= "00";
begin
--	main_clk <= cnt(0); --25MHz   
	process(clk)
	begin
		if(clk_mode = '0')then
			main_clk <= hclk;
			inner_clk <= hclk;
		else
			main_clk <= cnt(0);
			inner_clk <= cnt(0);
		end if;
	end process;
	time_slice_signal <= time_slice;
	flush_count_signal <= flush_count;
	
	
--	inner_clk <= cnt(0);

	CPU_CLOCK:
	process (clk)
	begin
		if(rising_edge(clk)) then
			cnt <= cnt + 1;
		end if;
	end process;
	
    flash_clk <= cnt_flash(1); --12.5MHz
	 FLASH_CLOCK:
    process(clk)
    begin
        if (rising_edge(clk)) then
            cnt_flash <= cnt_flash + 1;
        end if;
    end process;

	process(inner_clk, rst, stall)
	begin
        if (rst = '0') then            
            stall <= '1';
      --      time_slice <= x"0000";
				time_slice <= "0000";
            flush_count<= "000";
            mode <= '0';
            inner_mode <= '0';
		elsif(rising_edge(inner_clk)) then
            if (stall = '1') then
                time_slice <= time_slice + 1;
            --    if (time_slice = x"ffff") then        
					 if (time_slice = "1111")then
                    stall  <= '0';
						  pc_stall <= '0';
                    flush_count <= "000";                    
                else                    
                    stall <= '1';
						  pc_stall <= '1';
                    flush_count <= "000";                    
                end if;
            elsif (stall = '0') then
                flush_count <= flush_count + 1;
					 if (flush_count = "011")then
						mode <= not inner_mode;
						inner_mode <= not inner_mode;
						flush_count <= flush_count + 1;
                elsif (flush_count = "100") then
                    stall <= '1';
						  pc_stall <= '1';
                else
                    stall <= '0';   
						  pc_stall <= '0';
                end if;           
            else
                time_slice <= time_slice + 1;
            end if;    
		end if;
	end process;
end Behavioral;

