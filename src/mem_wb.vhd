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

entity mem_wb is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           --来自访存阶段传来的信号  
           mem_wreg_data : in std_logic_vector(15 downto 0);         
           mem_wreg_addr : in std_logic_vector(2 downto 0);          
           mem_wreg_en   : in std_logic;
           mem_wsreg_data : in std_logic_vector(15 downto 0);         
           mem_wsreg_addr : in std_logic_vector(1 downto 0);          
           mem_wsreg_en   : in std_logic;
           --传入写回阶段的信号，需要注意的是回写阶段实际上是由寄存器堆完成，故输出信号直接与两个寄存器堆相连
           wb_wreg_data : out std_logic_vector(15 downto 0);         
           wb_wreg_addr : out std_logic_vector(2 downto 0);           
           wb_wreg_en   : out std_logic;
           wb_wsreg_data : out std_logic_vector(15 downto 0);         
           wb_wsreg_addr : out std_logic_vector(1 downto 0);           
           wb_wsreg_en   : out std_logic);
end mem_wb;

architecture Behavioral of mem_wb is    
begin
    process (clk, rst)
    begin
        if (rst = '0') then           
            wb_wreg_en <= '1';            
            wb_wreg_addr <= "000";
            wb_wreg_data <= x"0000";
            wb_wsreg_en <= '1';            
            wb_wsreg_addr <= "00";
            wb_wsreg_data <= x"0000";
        elsif (clk'event and clk = '1') then
            wb_wreg_en <= mem_wreg_en;           
            wb_wreg_addr <= mem_wreg_addr;
            wb_wreg_data <= mem_wreg_data;
            wb_wsreg_en <= mem_wsreg_en;           
            wb_wsreg_addr <= mem_wsreg_addr;
            wb_wsreg_data <= mem_wsreg_data;
        end if;         
    end process;
end Behavioral;
