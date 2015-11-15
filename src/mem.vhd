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
           --signal from ex/mem stage                    
           wreg_data : in std_logic_vector(15 downto 0);           
           wreg_addr : in std_logic_vector(2 downto 0);           
           wreg_en   : in std_logic;
           wsreg_data: in std_logic_vector(15 downto 0);         
           wsreg_addr: in std_logic_vector(1 downto 0);           
           wsreg_en  : in std_logic;
           --signal for mem/wb stage                    
           wreg_data_out : out std_logic_vector(15 downto 0);
           wreg_addr_out : out std_logic_vector(2 downto 0);          
           wreg_en_out   : out std_logic;
           wsreg_data_out : out std_logic_vector(15 downto 0);
           wsreg_addr_out : out std_logic_vector(1 downto 0);           
           wsreg_en_out   : out std_logic);
end mem;

architecture Behavioral of mem is       
begin
    process (rst, wreg_en, wreg_addr, wreg_data, wsreg_en, wsreg_addr, wsreg_data)
    begin
        if (rst = '0') then           
            wreg_en_out <= '1';            
            wreg_addr_out <= "000";
            wreg_data_out <= x"0000";
            wsreg_en_out <= '1';            
            wsreg_addr_out <= "00";
            wsreg_data_out <= x"0000";
        else
            wreg_en_out <= wreg_en;            
            wreg_addr_out <= wreg_addr;
            wreg_data_out <= wreg_data;
            wsreg_en_out <= wsreg_en;            
            wsreg_addr_out <= wsreg_addr;
            wsreg_data_out <= wsreg_data;
        end if;         
    end process;
end Behavioral;

