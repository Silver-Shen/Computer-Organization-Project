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

entity sopc is
    Port ( clk : in  std_logic;
           rst : in  std_logic);          
end sopc;

architecture Behavioral of sopc is
    component excited_cpu
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               inst: in std_logic_vector(15 downto 0);
               new_inst_addr : out std_logic_vector(15 downto 0);
               inst_en : out std_logic);  
    end component;

    signal pc : std_logic_vector(15 downto 0);
    signal en : std_logic;

    component rom 
        Port ( en  : in std_logic;
               addr : in std_logic_vector(15 downto 0);
               inst : out std_logic_vector(15 downto 0));
    end component;
    
    signal inst : std_logic_vector(15 downto 0);
begin
   cpu : excited_cpu port map (clk, rst, inst, pc, en);
   inst_mem : rom port map (en, pc, inst);
end Behavioral;
