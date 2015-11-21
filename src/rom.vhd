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
    constant stored_inst : rom_array  := (x"69de",x"6905",x"6abe",x"6a03",
                                          x"6a01",x"6bff",x"6cff",x"6dff",
                                          x"e14d",x"e171",x"e255",x"6981",
                                          x"6eff",x"6fff",x"69ff",x"6aff");
begin
    process (en, addr)
    begin
        if (en = '1') then
            inst <= x"0000";
        else
            inst <= stored_inst(conv_integer(addr(3 downto 0)));
        end if;        
    end process;
end Behavioral;

