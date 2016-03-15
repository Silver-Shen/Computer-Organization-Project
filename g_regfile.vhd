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

entity g_regfile is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           --write_back signal           
           w_addr  : in std_logic_vector(2 downto 0);
           w_data  : in std_logic_vector(15 downto 0);
           w_en    : in std_logic;
           --read_reg signal           
           reg1_addr : in std_logic_vector(2 downto 0);
           reg1_en : in std_logic; 
           reg2_addr : in std_logic_vector(2 downto 0);
           reg2_en : in std_logic;
           reg1_data : out std_logic_vector(15 downto 0);
           reg2_data : out std_logic_vector(15 downto 0);
           --timeout
           mode : in std_logic);
end g_regfile;

architecture Behavioral of g_regfile is    
    type reg_array is array(0 to 7) of std_logic_vector(15 downto 0); 
    signal regfile : reg_array := (x"0000",x"0000",x"0000",x"0000",
                                   x"0000",x"0000",x"0000",x"0000");

    signal backup  : reg_array := (x"0000",x"0000",x"0000",x"0000",
                                   x"0000",x"0000",x"0000",x"0000");
begin
    Write_Back:
    process (clk, rst, mode)
    begin       
        if (clk'event and clk = '1') then
            --if (timeout = '0') then                 
            --    regfile <= backup;
            --    backup  <= regfile; 
            if (rst /= '0' and w_en = '0') then
                if (mode = '0') then
                    regfile(CONV_INTEGER(w_addr)) <= w_data;
                else
                    backup(CONV_INTEGER(w_addr)) <= w_data;
                end if;
            end if;
        end if;         
    end process;

    Read_Reg1: 
    process(rst, reg1_addr, reg1_en, w_addr, w_en, w_data, regfile, mode)
    begin
        if (rst = '0') then
            reg1_data <= x"0000";
        elsif (reg1_addr = w_addr and reg1_en = '0' and w_en = '0') then
            reg1_data <= w_data;
        elsif (reg1_en = '0') then
            if (mode = '0') then
                reg1_data <= regfile(CONV_INTEGER(reg1_addr));
            else
                reg1_data <= backup(CONV_INTEGER(reg1_addr));
            end if;
        else
            reg1_data <= x"0000";
        end if; 
    end process;

    Read_Reg2:
    process(rst, reg2_addr, reg2_en, w_addr, w_en, w_data, regfile, mode)
    begin
        if (rst = '0') then
            reg2_data <= x"0000";
        elsif (reg2_addr = w_addr and reg2_en = '0' and w_en = '0') then
            reg2_data <= w_data;
        elsif (reg2_en = '0') then
            if (mode = '0') then
                reg2_data <= regfile(CONV_INTEGER(reg2_addr));
            else
                reg2_data <= backup(CONV_INTEGER(reg2_addr));
            end if;
        else
            reg2_data <= x"0000";
        end if; 
    end process;
end Behavioral;

