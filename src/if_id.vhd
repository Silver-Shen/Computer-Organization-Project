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

entity if_id is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           --signal from control
           stall  : in std_logic_vector(1 downto 0);
           --signal from if stage           
           if_pc  : in std_logic_vector(15 downto 0);
           if_inst: in std_logic_vector(15 downto 0);
           --signal for id stage           
           id_pc  : out std_logic_vector(15 downto 0);
           id_inst: out std_logic_vector(15 downto 0));
end if_id;

architecture Behavioral of if_id is    
begin
    process (clk, rst, stall)
    begin
        if (rst = '0') then
            id_pc <= x"0000";
            id_inst <= x"0800"; -- represent NOP
        elsif (clk'event and clk = '1') then
            case stall is
                when "11" => --normal
                    id_pc <= if_pc;
                    id_inst <= if_inst;
                when "00" => --clear
                    id_pc <= x"0000";
                    id_inst <= x"0800";
                when others => null; --hold the value
            end case;
        end if;         
    end process;
end Behavioral;

