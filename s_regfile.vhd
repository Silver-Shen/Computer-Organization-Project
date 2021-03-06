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
           --write_back signal           
           w_addr  : in std_logic_vector(1 downto 0);
           w_data  : in std_logic_vector(15 downto 0);
           w_en    : in std_logic;
           --read_reg signal           
           reg_addr : in std_logic_vector(1 downto 0);
           reg_en : in std_logic;           
           reg_data : out std_logic_vector(15 downto 0);
           --mode
           mode  : in std_logic);          
end s_regfile;

architecture Behavioral of s_regfile is
    -- four special register, number from 00 to 11   
    signal T : std_logic := '0';
    signal IH : std_logic_vector(15 downto 0) := x"0000";
    signal RA : std_logic_vector(15 downto 0) := x"0000";
    signal SP : std_logic_vector(15 downto 0) := x"0000";
    signal back_T : std_logic := '0';
    signal back_IH: std_logic_vector(15 downto 0) := x"0000";
    signal back_RA: std_logic_vector(15 downto 0) := x"0000";
    signal back_SP: std_logic_vector(15 downto 0) := x"0000";
begin
    Write_Back:    
    process (clk, rst, mode)        
    begin       
        if (clk'event and clk = '1') then
            --if (timeout = '0') then                
            --    T <= back_T;
            --    back_T <= T;                
            --    IH <= back_IH;
            --    back_IH <= IH;
            --    RA <= back_RA;
            --    back_RA <= RA;
            --    SP <= back_SP;
            --    back_SP <= SP;
            if (rst /= '0' and w_en = '0') then
                if (mode = '0') then
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
                else
                    case w_addr is
                      when "00" =>
                        back_T <= w_data(0);
                      when "01" =>
                        back_IH <= w_data;
                      when "10" =>
                        back_RA <= w_data;
                      when "11" =>
                        back_SP <= w_data;
                      when others => null;
                    end case;
                end if;
            end if;
        end if;         
    end process;

    Read_Reg:    
    process(rst, reg_addr, reg_en, w_addr, w_en, w_data, T, IH, RA, SP, mode)
    begin
        if (rst = '0') then
            reg_data <= x"0000";
        elsif (reg_addr = w_addr and reg_en = '0' and w_en = '0') then
			if (reg_addr = "00") then
                reg_data <= "000000000000000" & w_data(0);
            else
                reg_data <= w_data;
            end if;        
		elsif (reg_en = '0') then
            if (mode = '0') then
                case reg_addr is
                    when "00" =>
                      reg_data <= "000000000000000" & T; 
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
                case reg_addr is
                    when "00" =>
                      reg_data <= "000000000000000" & back_T; 
                    when "01" =>
                      reg_data <= back_IH;
                    when "10" =>
                      reg_data <= back_RA;
                    when "11" =>
                      reg_data <= back_SP;
                    when others => 
                      reg_data <= x"0000";
                end case;
            end if;
        else
            reg_data <= x"0000";
        end if; 
    end process;

end Behavioral;

