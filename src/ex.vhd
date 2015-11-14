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
           --来自ID/EX阶段阶段寄存器传来的信号
           aluop   : in std_logic_vector(4 downto 0);
           alusel  : in std_logic_vector(2 downto 0);
           operand1: in std_logic_vector(15 downto 0);
           operand2: in std_logic_vector(15 downto 0);
           wreg_addr : in std_logic_vector(2 downto 0);
           wreg_sel  : in std_logic;
           wreg_en   : in std_logic;
           --传入下一阶段的信号           
           wreg_data_out : out std_logic_vector(15 downto 0);
           wreg_addr_out : out std_logic_vector(2 downto 0);
           wreg_sel_out  : out std_logic;
           wreg_en_out   : out std_logic);
end ex;

architecture Behavioral of ex is    
    variable temp_data : std_logic_vector(15 downto 0) := x"0000";
begin
    Pass_Write_Back:  --写回的信号和地址不需要修改，直接传给下一阶段
    process (rst, wreg_en, wreg_sel, wreg_addr)
    begin
        if (rst = '0') then
            wreg_en_out <= '1';
            wreg_sel_out <= '0';
            wreg_addr_out <= "000";
        else 
            wreg_en_out <= wreg_en;
            wreg_sel_out <= wreg_sel;
            wreg_addr_out <= wreg_addr;
        end if;
    end process;

    ALU_OPERATION:   --根据操作码和选择码进行alu运算
    process (rst, operand1, operand2, aluop, alusel)
    begin
        if (rst = '0' or aluop = "00001") then
            wreg_data_out <= x"0000";
        else
            case aluop is
                when "11100"|01111|01001|01000|01101 =>   --addu|move|addiu|addiu3|li
                    wreg_data_out <= operand1 + operand2;
                when "01110" =>     --cmpi
                    temp_data := operand1 - operand2;
                    if (temp_data = x"0000") then
                        wreg_data_out(0) <= '0';
                    else
                        wreg_data_out(0) <= '1';
                    end if;                    
                when others => wreg_data_out <= x"0000";
            end case;
        end if;         
    end process;
end Behavioral;

