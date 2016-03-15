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

entity pc_reg is
    Port ( clk          : in std_logic;
           rst          : in std_logic;
           stall        : in std_logic;
			  pc_stall		: in std_logic;
           branch       : in std_logic;
           branch_addr  : in std_logic_vector(15 downto 0);
		   mode : in std_logic;
           --signal for MMU
           pc           : out std_logic_vector(15 downto 0);
           en           : out std_logic);
end pc_reg;

architecture Behavioral of pc_reg is
    signal stored_pc : std_logic_vector(15 downto 0) := x"0000";
    signal backup_pc : std_logic_vector(15 downto 0) := x"0200";
begin
    process (clk, rst, stall, branch, branch_addr)
        variable temp_pc : std_logic_vector(15 downto 0);
    begin
        if (rst = '0') then
            stored_pc <= x"0000";
            backup_pc <= x"0200";
            en <= '1';
			pc <= x"0000"; 
        elsif (clk'event and clk = '1') then
            en <= '0';
                if (branch = '0') then
                    if (mode = '0') then
								if(pc_stall = '0')then
									stored_pc <= branch_addr - 1;
								else
									stored_pc <= branch_addr;                    
								end if;
                    else 
                        if(pc_stall = '0')then
									backup_pc <= branch_addr - 1;
								else
									backup_pc <= branch_addr;                    
								end if;
                    end if;
    				pc <= branch_addr;
                elsif (stall = '0') then
                    if (mode = '0') then
                        pc <= stored_pc;
                    else 
                        pc <= backup_pc;
                    end if;
                elsif (stall = '1' and branch = '1') then
                    if (mode = '0') then
                        stored_pc <= stored_pc + 1;                    
                        pc <= stored_pc + 1;
                    else 
                        backup_pc <= backup_pc + 1;
                        pc <= backup_pc + 1;
                    end if;
                end if; 
            
        end if;    
    end process;
end Behavioral;

