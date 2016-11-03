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
           branch       : in std_logic;
           branch_addr  : in std_logic_vector(15 downto 0);
           --signal for MMU
           pc           : out std_logic_vector(15 downto 0);
           en           : out std_logic);
end pc_reg;

architecture Behavioral of pc_reg is
    signal stored_pc : std_logic_vector(15 downto 0) := x"0000";
begin
    process (clk, rst, stall, branch, branch_addr)
    begin
        if (rst = '0') then
            stored_pc <= x"0000";
            en <= '1';
			pc <= x"0000"; 
        elsif (clk'event and clk = '1') then
            if (branch = '0') then
                stored_pc <= branch_addr;
                en <= '0';
						pc <= branch_addr;
            elsif (stall = '1' and branch = '1') then
                stored_pc <= stored_pc + 1;
                en <= '0';
                pc <= stored_pc + 1;
            end if; 
        end if;    
    end process;
end Behavioral;

