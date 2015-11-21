----------------------------------------------------------------------------------
-- Engineer: Zheyan Shen
-- Project Name: Computer Organization Final Project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmu is
    Port ( clk      : in  std_logic; --12.5 or 25MHz
           --clk_high : in  std_logic; --25 or 50MHz clock
           rst      : in  std_logic;           
           --signal from pc_reg
           inst_addr: in std_logic_vector(15 downto 0);
           inst_en  : in std_logic;
           --signal from ex/mem stage register
           mem_read_en    : in std_logic;
           mem_read_addr  : in std_logic_vector(15 downto 0);
           mem_write_en   : in std_logic;
           mem_write_addr : in std_logic_vector(15 downto 0);
           mem_write_data : in std_logic_vector(15 downto 0);
           --signal for if/id register
           inst     : out std_logic_vector(15 downto 0);
           --signal for mem stage
           data     : out std_logic_vector(15 downto 0);
           --signal for control unit 
           stall_request: out std_logic;
           --signal for Ram1 (Data Memory)
           Ram1Addr : out   std_logic_vector (17 downto 0);
           Ram1Data : inout std_logic_vector (15 downto 0);
           Ram1OE   : out   std_logic;
           Ram1WE   : out   std_logic;
           Ram1EN   : out   std_logic;
           --signal for Ram2 (Instruction Memory)
           Ram2Addr : out   std_logic_vector (17 downto 0);
           Ram2Data : inout std_logic_vector (15 downto 0);
           Ram2OE   : out   std_logic;
           Ram2WE   : out   std_logic;
           Ram2EN   : out   std_logic;
           --signal for series
           data_ready  : in  std_logic;
           tbre        : in  std_logic;
           tsre        : in  std_logic;             
           rdn         : out std_logic;
           wrn         : out std_logic);
end mmu;

architecture Behavioral of mmu is   
    signal data1, data2 : std_logic_vector(15 downto 0);
    signal mode: std_logic; 
begin
    Prepare_Address_Data:
    process (mem_read_addr, mem_read_en, mem_write_en, mem_write_addr, inst_en, inst_addr)
    begin
        stall_request <= '1';

        if (inst_en = '0') then
            Ram2Addr <= "00" & inst_addr;            
            Ram2Data <= "ZZZZZZZZZZZZZZZZ";
        end if;

        if (mem_read_en = '0') then            
            if (mem_read_addr > x"7fff") then
                Ram1Addr <= "00" & mem_read_addr;
                Ram1Data <= "ZZZZZZZZZZZZZZZZ";
                mode <= '0';
            else 
                Ram2Addr <= "00" & mem_read_addr;
                Ram2Data <= "ZZZZZZZZZZZZZZZZ";
                stall_request <= '0';
                mode <= '1';
            end if;
        elsif (mem_write_en = '0') then
            if (mem_write_addr > x"7fff") then
                Ram1Addr <= "00" & mem_write_addr;
                Ram1Data <= mem_write_data;
            else
                Ram2Addr <= "00" & mem_write_addr;
                Ram2Data <= mem_write_data;
                stall_request <= '0';
            end if;
        end if;
    end process;

    Handle_Ram1: --Data Memory
    process(clk, rst, mem_read_en, mem_read_addr, 
            mem_write_en,  mem_write_addr)
        variable temp_data : std_logic;
    begin
        if (rst = '0') then 
            rdn <= '1';
            wrn <= '1';
            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';
        elsif (clk = '1') then            
            rdn <= '1';
            wrn <= '1';
            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';                        
        elsif (clk'event and clk = '0') then
            if (mem_read_en = '0' and mem_read_addr > x"7fff") then --read ram1 or series
                if (mem_read_addr = x"BF01") then  --read series status
                    temp_data := tbre and tsre;
                    data1 <= "00000000000000" & data_ready & temp_data;
                elsif (mem_read_addr = x"BF00") then --read series
                    rdn <= '0';
                    data1 <= Ram1Data;
                else  --read ram1
                    Ram1EN <= '0';
                    Ram1OE <= '0';
                    data1 <= Ram1Data;
                end if;
            elsif (mem_write_en ='0' and mem_write_addr > x"7fff") then --write ram1 or series
                if (mem_write_addr = x"BF00") then --write series
                    wrn <= '0';
                else   --write ram1                 
                    Ram1EN <= '0';
                    Ram1WE <= '0';                
                end if;
            else
                rdn <= '1';
                wrn <= '1';
                Ram1EN <= '1';
                Ram1WE <= '1';
                Ram1OE <= '1'; 
            end if;            
        end if;
    end process;

    Handle_Ram2: --Instruction Memory
    process(clk, rst, mem_read_en, mem_read_addr, 
            mem_write_en,  mem_write_addr)
        variable temp_data : std_logic;
    begin
        if (rst = '0') then            
            Ram2EN <= '1';
            Ram2WE <= '1';
            Ram2OE <= '1';
        elsif (clk = '1') then                       
            Ram2EN <= '1';
            Ram2WE <= '1';
            Ram2OE <= '1';                        
        elsif (clk'event and clk = '0') then
            if (mem_read_en = '0' and mem_read_addr <= x"7fff") then --read ram2                
                Ram2EN <= '0';
                Ram2OE <= '0';
                data2 <= Ram2Data;                
            elsif (mem_write_en ='0' and mem_write_addr <= x"7fff") then --write ram2
                Ram2EN <= '0';
                Ram2WE <= '0';                
            else                
                Ram2EN <= '0';                
                Ram2OE <= '0'; 
                inst <= Ram2Data;
            end if;            
        end if;
    end process;

    process (data1, data2, mode)
    begin
        if (mode = '0') then
            data <= data1;
        else
            data <= data2;
        end if;
    end process;
end Behavioral;