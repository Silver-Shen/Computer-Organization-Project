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

entity id_ex is
    Port ( clk   : in  std_logic;
           rst   : in  std_logic;
           stall : in std_logic;
           --signal from id stage                      
           id_alusel    : in std_logic_vector(2 downto 0);
           id_operand1  : in std_logic_vector(15 downto 0);
           id_operand2  : in std_logic_vector(15 downto 0);
           id_wreg_addr : in std_logic_vector(2 downto 0);           
           id_wreg_en   : in std_logic;
           id_wsreg_addr: in std_logic_vector(1 downto 0);           
           id_wsreg_en  : in std_logic;
           id_mem_read_en   : in std_logic;
           id_mem_write_en  : in std_logic;
           id_mem_write_data: in std_logic_vector(15 downto 0);    
           --signal for ex stage                      
           ex_alusel    : out std_logic_vector(2 downto 0);
           ex_operand1  : out std_logic_vector(15 downto 0);
           ex_operand2  : out std_logic_vector(15 downto 0);
           ex_wreg_addr : out std_logic_vector(2 downto 0);           
           ex_wreg_en   : out std_logic;
           ex_wsreg_addr: out std_logic_vector(1 downto 0);           
           ex_wsreg_en  : out std_logic;
           ex_mem_read_en   : out std_logic;
           ex_mem_write_en  : out std_logic;
           ex_mem_write_data: out std_logic_vector(15 downto 0));           
end id_ex;

architecture Behavioral of id_ex is    
begin
    process (clk, rst, stall)
    begin
        if (rst = '0' or stall = '0') then           
            ex_alusel <= "000";            
            ex_operand1 <= x"0000";
            ex_operand2 <= x"0000";
            ex_wreg_en <= '1';            
            ex_wreg_addr <= "000";
            ex_wsreg_en <= '1';            
            ex_wsreg_addr <= "00";
            ex_mem_read_en <= '1';
            ex_mem_write_en <= '1';
            ex_mem_write_data <= x"0000";
        elsif (clk'event and clk = '1') then            
            ex_alusel <= id_alusel;            
            ex_operand1 <= id_operand1;
            ex_operand2 <= id_operand2;
            ex_wreg_en <= id_wreg_en;            
            ex_wreg_addr <= id_wreg_addr;
            ex_wsreg_en <= id_wsreg_en;            
            ex_wsreg_addr <= id_wsreg_addr;
            ex_mem_read_en <= id_mem_read_en;
            ex_mem_write_en <=id_mem_write_en;
            ex_mem_write_data <= id_mem_write_data;
        end if;         
    end process;
end Behavioral;

