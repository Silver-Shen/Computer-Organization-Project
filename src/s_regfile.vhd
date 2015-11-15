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

entity s_regfile is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           --写入寄存器的信号，同步操作
           w_addr  : in std_logic_vector(1 downto 0);
           w_data  : in std_logic_vector(15 downto 0);
           w_en    : in std_logic;
           --读取寄存器的信号，异步操作
           reg_addr : in std_logic_vector(1 downto 0);
           reg_en : in std_logic;           
           reg_data : out std_logic_vector(15 downto 0));          
end s_regfile;

architecture Behavioral of s_regfile is
    --特殊寄存器堆由四个分立的信号构成，按顺序从00编号到11
    signal T : std_logic;
    signal IH : std_logic_vector(15 downto 0);
    signal RA : std_logic_vector(15 downto 0);
    signal SP : std_logic_vector(15 downto 0);
begin
    Write_Back: --回写进程，与时钟信号同步
    process (clk, rst)
    begin       
        if (clk'event and clk = '1') then
            if (rst /= '0' and w_en = '0') then
                case w_addr is
                  when "00" =>
                    T <= w_data(0);
                  when "01" =>
                    IH <= w_data;
                  when "10" =>
                    RA <= w_data;
                  when "11" =>
                    SP <= w_data;
                  when others => null;
                end case;
            end if;
        end if;         
    end process;

    Read_Reg1: --读寄存器进程，解决了ID和WB阶段的数据冲突问题，即相隔两条指令的RAW冲突
    process(rst, reg_addr, reg_en, w_addr, w_en, w_data)
    begin
        if (rst = '0') then
            reg_data <= x"0000";
        elsif (reg_addr = w_addr and reg_en = '0' and w_en = '0') then
            reg_data <= w_data;
        elsif (reg_en = '0') then
            case reg_addr is
                when "00" =>
                  reg_data(0) <= T; 
                when "01" =>
                  reg_data <= IH;
                when "10" =>
                  reg_data <= RA;
                when "11" =>
                  reg_data <= SP;
                when others => 
                  reg_data <= x"0000";
            end case;
        else
            reg_data <= x"0000";
        end if; 
    end process;

end Behavioral;

