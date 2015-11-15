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

entity ex is
    Port ( rst : in  std_logic;
           --signal from id stage           
           aluop   : in std_logic_vector(4 downto 0);
           alusel  : in std_logic_vector(2 downto 0);
           operand1: in std_logic_vector(15 downto 0);
           operand2: in std_logic_vector(15 downto 0);
           wreg_addr : in std_logic_vector(2 downto 0);          
           wreg_en   : in std_logic;
           wsreg_addr : in std_logic_vector(1 downto 0);          
           wsreg_en   : in std_logic;
           --signal for mem stage          
           wreg_data_out : out std_logic_vector(15 downto 0);
           wreg_addr_out : out std_logic_vector(2 downto 0);           
           wreg_en_out   : out std_logic;
           wsreg_data_out : out std_logic_vector(15 downto 0);
           wsreg_addr_out : out std_logic_vector(1 downto 0);           
           wsreg_en_out   : out std_logic);
end ex;

architecture Behavioral of ex is    
    variable temp_data : std_logic_vector(15 downto 0) := x"0000";
begin
    Pass_Write_Back:
    process (rst, wreg_en, wreg_addr, wsreg_en, wsreg_addr)
    begin
        if (rst = '0') then
            wreg_en_out <= '1';            
            wreg_addr_out <= "000";
            wsreg_en_out <= '1';            
            wsreg_addr_out <= "00";
        else 
            wreg_en_out <= wreg_en;           
            wreg_addr_out <= wreg_addr;
            wsreg_en_out <= wsreg_en;           
            wsreg_addr_out <= wsreg_addr;
        end if;
    end process;

    ALU_OPERATION:  --make operation according to aluop&alusel
    process (rst, operand1, operand2, aluop, alusel)
    begin
        if (rst = '0' or aluop = "00001") then
            wreg_data_out <= x"0000";
            wsreg_data_out <= x"0000";
        else
            case aluop is
                when "11100"|"01111"|"01001"|"01000"|"01101" =>   --addu|move|addiu|addiu3|li
                    wreg_data_out <= operand1 + operand2;
                    wsreg_data_out <= x"0000";
                when "01110" =>     --cmpi
                    temp_data := operand1 - operand2;
                    wreg_data_out <= x"0000";
                    if (temp_data = x"0000") then
                        wsreg_data_out(0) <= '0';
                    else
                        wsreg_data_out(0) <= '1';
                    end if;                    
                when others => 
                    wreg_data_out <= x"0000";
                    wsreg_data_out <= x"0000";
            end case;
        end if;         
    end process;
end Behavioral;

