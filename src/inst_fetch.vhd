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

entity inst_fetch is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           inst : out std_logic_vector(15 downto 0));          
end inst_fetch;

architecture Behavioral of inst_fetch is
    component pc_reg
        Port (clk : in  std_logic;
            rst : in  std_logic;
            pc  : out std_logic_vector(15 downto 0);
            en  : out std_logic);    
    end component;
    component rom 
        Port ( en  : in std_logic;
            addr : in std_logic_vector(15 downto 0);
            inst : out std_logic_vector(15 downto 0));
    end component;
    signal pc : std_logic_vector(15 downto 0);
    signal en : std_logic;
begin
   pc_unit : pc_reg port map (clk, rst, pc, en);
   inst_mem : rom port map (en, pc, inst);
end Behavioral;

