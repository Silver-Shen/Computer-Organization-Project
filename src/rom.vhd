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

entity rom is
    Port ( en  : in std_logic;
           addr : in std_logic_vector(15 downto 0);
           inst : out std_logic_vector(15 downto 0));
end rom;

architecture Behavioral of rom is
    type rom_array is array(0 to 15) of std_logic_vector(15 downto 0); 
    constant stored_inst : rom_array  := (x"0000",x"0001",x"0002",x"0003",
                                          x"0004",x"0005",x"0006",x"0007",
                                          x"0008",x"0009",x"000a",x"000b",
                                          x"000c",x"000d",x"000e",x"000f");
begin
    process (en, addr)
        if (en = '1') then
            inst <= x"0000";
        else
            inst <= stored_inst[addr(3 downto 0)];
        end if;        
    end process;
end Behavioral;

