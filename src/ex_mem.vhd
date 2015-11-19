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

entity ex_mem is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           --signal from ex stage           
           ex_wreg_data : in std_logic_vector(15 downto 0);         
           ex_wreg_addr : in std_logic_vector(2 downto 0);           
           ex_wreg_en   : in std_logic;
           ex_wsreg_data: in std_logic_vector(15 downto 0);         
           ex_wsreg_addr: in std_logic_vector(1 downto 0);           
           ex_wsreg_en  : in std_logic;
           ex_mem_read_en    : in std_logic;
           ex_mem_read_addr  : in std_logic_vector(15 downto 0);
           ex_mem_write_en   : in std_logic;
           ex_mem_write_addr : in std_logic_vector(15 downto 0);
           ex_mem_write_data : in std_logic_vector(15 downto 0);
           --signal for mem stage           
           mem_wreg_data : out std_logic_vector(15 downto 0);         
           mem_wreg_addr : out std_logic_vector(2 downto 0);          
           mem_wreg_en   : out std_logic;
           mem_wsreg_data: out std_logic_vector(15 downto 0);         
           mem_wsreg_addr: out std_logic_vector(1 downto 0);           
           mem_wsreg_en  : out std_logic;
           mem_read_en_out   : out std_logic;
           mem_read_addr_out : out std_logic_vector(15 downto 0);
           mem_write_en_out  : out std_logic;
           mem_write_addr_out: out std_logic_vector(15 downto 0);
           mem_write_data_out: out std_logic_vector(15 downto 0));
end ex_mem;

architecture Behavioral of ex_mem is    
begin
    process (clk, rst)
    begin
        if (rst = '0') then           
            mem_wreg_en <= '1';            
            mem_wreg_addr <= "000";
            mem_wreg_data <= x"0000";
            mem_wsreg_en <= '1';            
            mem_wsreg_addr <= "00";
            mem_wsreg_data <= x"0000";
            mem_read_en_out <= '1';
            mem_read_addr_out <= x"0000";
            mem_write_en_out <= '1';
            mem_write_addr_out <= x"0000";
            mem_write_data_out <= x"0000";
        elsif (clk'event and clk = '1') then
            mem_wreg_en <= ex_wreg_en;            
            mem_wreg_addr <= ex_wreg_addr;
            mem_wreg_data <= ex_wreg_data;
            mem_wsreg_en <= ex_wsreg_en;            
            mem_wsreg_addr <= ex_wsreg_addr;
            mem_wsreg_data <= ex_wsreg_data;
            mem_read_en_out <= ex_mem_read_en;
            mem_read_addr_out <= ex_mem_read_addr;
            mem_write_en_out <= ex_mem_write_en;
            mem_write_addr_out <= ex_mem_write_addr;
            mem_write_data_out <= ex_mem_write_data;
        end if;         
    end process;
end Behavioral;

