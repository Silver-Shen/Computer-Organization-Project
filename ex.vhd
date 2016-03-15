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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ex is
    Port ( rst : in  std_logic;
           --signal from id stage                      
           alusel  : in std_logic_vector(2 downto 0);
           operand1: in std_logic_vector(15 downto 0);
           operand2: in std_logic_vector(15 downto 0);
           wreg_addr : in std_logic_vector(2 downto 0);          
           wreg_en   : in std_logic;
           wsreg_addr : in std_logic_vector(1 downto 0);          
           wsreg_en   : in std_logic;
           mem_read_en   : in std_logic;
           mem_write_en  : in std_logic;
           mem_write_data: in std_logic_vector(15 downto 0);  
           --signal for mem stage          
           wreg_data_out : out std_logic_vector(15 downto 0);  --also forwarding
           wreg_addr_out : inout std_logic_vector(2 downto 0);   --also forwarding        
           wreg_en_out   : inout std_logic;                      --also forwarding
           wsreg_data_out : out std_logic_vector(15 downto 0); --also forwarding
           wsreg_addr_out : out std_logic_vector(1 downto 0);  --also forwarding         
           wsreg_en_out   : out std_logic;                     --also forwarding 
           mem_read_en_out   : inout std_logic;
           mem_read_addr_out : out std_logic_vector(15 downto 0);
           mem_write_en_out  : out std_logic;
           mem_write_addr_out: out std_logic_vector(15 downto 0);
           mem_write_data_out: out std_logic_vector(15 downto 0);
           --load conflict forwarding
           is_ex_load        : out std_logic;    
           ex_load_addr      : out std_logic_vector(3 downto 0));
end ex;

architecture Behavioral of ex is        
begin
    Pass_Write_Back:
    process (rst, wreg_en, wreg_addr, wsreg_en, wsreg_addr, 
             mem_read_en, mem_write_en, mem_write_data)
    begin
        if (rst = '0') then
            wreg_en_out <= '1';            
            wreg_addr_out <= "000";
            wsreg_en_out <= '1';            
            wsreg_addr_out <= "00";
            mem_read_en_out <= '1';
            mem_write_en_out <= '1';
            mem_write_data_out <= x"0000";
        else 
            wreg_en_out <= wreg_en;           
            wreg_addr_out <= wreg_addr;
            wsreg_en_out <= wsreg_en;           
            wsreg_addr_out <= wsreg_addr;
            mem_read_en_out <= mem_read_en;
            mem_write_en_out <= mem_write_en;
            mem_write_data_out <= mem_write_data;
        end if;
    end process;

    Pass_Load_Infomation:
    process (wreg_addr, mem_read_en)
    begin
        is_ex_load <= mem_read_en;
		  if(mem_read_en = '0')then
			ex_load_addr <= '0' & wreg_addr;
		  else
			ex_load_addr <= '1' & wreg_addr;
		  end if;
    end process;

    ALU_OPERATION:  --make operation according to alusel
    process (rst, operand1, operand2, alusel, mem_read_en, mem_write_en, wreg_en, wsreg_en)
        variable temp_result : std_logic_vector(15 downto 0);
    begin
        wreg_data_out <= x"0000";
        wsreg_data_out <= x"0000";
        mem_write_addr_out <= x"0000";
        mem_read_addr_out <= x"0000";
        if (rst /= '0') then
            case (alusel) is
                when "000" =>
                    temp_result := operand1 + operand2;
                when "001" =>
                    temp_result := operand1 - operand2;
                when "010" =>
                    if (operand1 = operand2) then
                        temp_result := x"0000";
                    else
                        temp_result := x"0001";
                    end if;
                when "011" =>
                    if (operand1 < operand2) then
                        temp_result := x"0001";
                    else
                        temp_result := x"0000";
                    end if;
                when "100" =>
                    if (operand2 = x"0000") then
                        temp_result := TO_STDLOGICVECTOR(TO_BITVECTOR(operand1) SLL 8);
                    else
                        temp_result := TO_STDLOGICVECTOR(TO_BITVECTOR(operand1) SLL CONV_INTEGER(operand2));
                    end if;
                when "101" =>
                    if (operand2 = x"0000") then
                        temp_result := TO_STDLOGICVECTOR(TO_BITVECTOR(operand1) SRA 8);
                    else
                        temp_result := TO_STDLOGICVECTOR(TO_BITVECTOR(operand1) SRA CONV_INTEGER(operand2));
                    end if;
                when "110" =>
                    temp_result := operand1 AND operand2;
                when "111" =>
                    temp_result := operand1 OR operand2;
                when others => 
                    temp_result := x"0000";
            end case;
        end if;
        --make sure the alu result is data or memory address
        if (mem_read_en = '0') then
            mem_read_addr_out <= temp_result;
        elsif (mem_write_en = '0') then
            mem_write_addr_out <= temp_result;
        elsif (wreg_en = '0') then
            wreg_data_out <= temp_result;
        elsif (wsreg_en = '0') then
            wsreg_data_out <= temp_result;
        end if;            
    end process;
end Behavioral;

