----------------------------------------------------------------------------------
-- Engineer: Zheyan Shen
-- Project Name: Computer Organization Final Project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem is
    Port ( rst : in  std_logic;
           --来自EX/MEM阶段阶段寄存器传来的信号
           wreg_data : in std_logic_vector(15 downto 0);           
           wreg_addr : in std_logic_vector(2 downto 0);
           wreg_sel  : in std_logic;
           wreg_en   : in std_logic;
           --传入下一阶段的信号           
           wreg_data_out : out std_logic_vector(15 downto 0);
           wreg_addr_out : out std_logic_vector(2 downto 0);
           wreg_sel_out  : out std_logic;
           wreg_en_out   : out std_logic);
end mem;

architecture Behavioral of mem is       
begin
    process (rst, wreg_en, wreg_sel, wreg_addr, wreg_data)
    begin
        if (rst = '0') then           
            wreg_en_out <= '1';
            wreg_sel_out <= '0';
            wreg_addr_out <= "000";
            wreg_data_out <= x"0000";
        else
            wreg_en_out <= wreg_en;
            wreg_sel_out <= wreg_sel;
            wreg_addr_out <= wreg_addr;
            wreg_data_out <= wreg_data;
        end if;         
    end process;
end Behavioral;

