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

entity control is
    Port (  rst : in  std_logic;
            request_from_id : in std_logic;
            request_from_mmu: in std_logic;
            request_from_fd : in std_logic;
            stall_for_pc    : out std_logic;
            stall_for_if    : out std_logic_vector(1 downto 0);
            stall_for_id    : out std_logic);
end control;

architecture Behavioral of control is       
begin
    process (rst, request_from_id, request_from_mmu)
    begin
        if (rst = '0') then           
            stall_for_pc <= '1';
            stall_for_if <= "11";
            stall_for_id <= '1';
        else
            stall_for_pc <= '1';
            stall_for_if <= "11";
            stall_for_id <= '1';            
            if (request_from_fd = '0' or request_from_id = '0' or request_from_mmu = '0') then
                stall_for_pc <= '0';  --hold the value
                stall_for_if <= "00"; --clear                
            end if;
        end if;         
    end process;
end Behavioral;
