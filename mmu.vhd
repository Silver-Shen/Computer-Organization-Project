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
           wrn         : out std_logic;		   		   
           --series2
           parity_error : in std_logic;
           framing_error: in std_logic;
           data_ready2  : in  std_logic;
           tbre2        : in  std_logic;
           tsre2        : in  std_logic;             
           rdn2         : out std_logic;
           wrn2         : out std_logic;
           data2_in        : in std_logic_vector(7 downto 0);
           data2_out        : out std_logic_vector(7 downto 0);
			  --multiple use
			  mode			: in std_logic;
			  --flash
			  flash_clk : in  STD_LOGIC;
           flash_data_to_ram : in  STD_LOGIC_VECTOR(15 downto 0);
           flash_addr_to_ram : in  STD_LOGIC_VECTOR(17 downto 0);
			  flash_cpu_en : in	STD_LOGIC);
end mmu;

architecture Behavioral of mmu is   
    signal Address : std_logic_vector(15 downto 0); 
begin	
    Make_Address:
    process(mem_read_en, mem_read_addr, mem_write_addr, mem_write_en)
    begin
        if (mem_read_en = '0') then
            Address <= mem_read_addr;
        elsif (mem_write_en = '0') then
            Address <= mem_write_addr;
        else
            Address <= (others => '0');
        end if;
    end process;

    Ram2EN <= '0';
    inst <= Ram2Data;

    Handle_ALL:
    process(clk, mem_read_en, mem_write_en, mem_write_data, Address,
            Ram1Data, tsre, tbre, data_ready, inst_en, inst_addr,
            flash_clk, flash_addr_to_ram, flash_data_to_ram, flash_cpu_en)
    begin
        stall_request <= '1';
		  if (flash_cpu_en = '1') then
            Ram2OE <= '1';
            Ram2WE <= flash_clk;
            Ram2Data <= flash_data_to_ram;
            Ram2Addr <=flash_addr_to_ram;
        else 
        if (Address = x"BF00") then
                data2_out <= (others => 'Z');     
            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';

            Ram2OE <= '0';
            Ram2WE <= '1';
				
            Ram2Addr <= "00" & inst_addr;
            Ram2Data <= (others => 'Z');
				
				rdn2 <= '1';
				wrn2 <= '1';
            if (mem_write_en = '0') then
                rdn <= '1';               
                wrn <= clk;
                Ram1Data <= mem_write_data;
                data <= Ram1Data;
            elsif (mem_read_en = '0') then
                rdn <= '0';                
                wrn <= '1';
                Ram1Data <= (others => 'Z');
                Ram1Addr <= "00" & Address;
                data <= Ram1Data;
            else
                rdn <= '1';  
					 wrn <= '1';
                Ram1Data <= mem_write_data;
                Ram1Addr <= (others => 'Z');
                data <= (others => '0');
            end if;
        elsif (Address = x"BF01") then
                data2_out <= (others => 'Z');     
            rdn <= '1';            
            wrn <= '1';
				 rdn2 <= '1';
					 wrn2 <= '1';
            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';

            Ram2OE <= '0';
            Ram2WE <= '1';

            Ram2Addr <= '0' & mode & inst_addr;
            Ram2Data <= (others => 'Z');
            if (mem_read_en = '0') then
                Ram1Data <= mem_write_data;
                Ram1Addr <= "00" & Address;
                data <= (1=>data_ready, 0=>(tsre AND tbre), others=>'0');
            else
                Ram1Data <= mem_write_data;
                Ram1Addr <= (others => '0');
                data <= Ram1Data;
            end if;
        elsif (Address = x"BF02") then
            rdn <= '1';            
            wrn <= '1';

            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';

            Ram2OE <= '0';
            Ram2WE <= '1';

            Ram2Addr <= "00" & inst_addr;
            Ram2Data <= (others => 'Z');
            if (mem_write_en = '0') then
                rdn2 <= '1';                
                wrn2 <= clk;
                data2_out <= mem_write_data(7 downto 0);
                data(7 downto 0) <= data2_in;
            elsif (mem_read_en = '0') then
                rdn2 <= '0';                
                wrn2 <= '1';
                data2_out <= (others => 'Z');                
                data(7 downto 0 ) <= data2_in;
            else
                rdn2 <= '1';
					 wrn2 <= '1';
                data2_out <= mem_write_data(7 downto 0);                
                data <= (others => '0');
            end if;
        elsif (Address = x"BF03") then
            data2_out <= (others => 'Z');     
            rdn <= '1';          
            wrn <= '1';
            Ram1EN <= '1';
            Ram1WE <= '1';
            Ram1OE <= '1';

            Ram2OE <= '0';
            Ram2WE <= '1';

            Ram2Addr <= "00" & inst_addr;
            Ram2Data <= (others => 'Z');

            rdn2 <= '1';
            wrn2 <= '1';
            if (mem_read_en = '0') then
                Ram1Data <= mem_write_data;
                Ram1Addr <= "00" & Address;
                data <= (1=>data_ready2, 0=>(tsre2 AND tbre2), others=>'0');
            else
                Ram1Data <= mem_write_data;
                Ram1Addr <= (others => '0');
                data <= Ram1Data;
            end if;
        else
                data2_out <= (others => 'Z');     
            rdn <= '1';           
            wrn <= '1';
				rdn2 <= '1';
            wrn2 <= '1';
            if (Address < x"8000") then
                Ram1EN <= '1';
                Ram1WE <= '1';
                Ram1OE <= '1';
                Ram1Data <= mem_write_data;
                Ram1Addr <= (others => '0');                
                if (Address <x"4000") then
                    Ram2OE <= '0';
                    Ram2WE <= '1';
                    Ram2Addr <= "00" & inst_addr;
                    Ram2Data <= (others => 'Z');
                    data <= (others => '0');
                elsif (mem_read_en = '0') then
                    stall_request <= '0';
                    Ram2OE <= '0';
                    Ram2WE <= '1';
                    Ram2Addr <= "00" & Address;
                    Ram2Data <= (others => 'Z');
                    data <= Ram2Data;
                elsif (mem_write_en = '0') then
                    stall_request <= '0';
                    Ram2OE <= '1';
                    Ram2WE <= clk;
                    Ram2Addr <= "00" & Address;
                    Ram2Data <= mem_write_data;
                    data <= Ram2Data;
                else
                    Ram2OE <= '0';
                    Ram2WE <= '1';
                    Ram2Addr <= "00" & inst_addr;
                    Ram2Data <= (others => 'Z');
                    data <= (others => '0');
                end if;
            else
                Ram2OE <= '0';
                Ram2WE <= '1';
                Ram2Addr <= "00" & inst_addr;
                Ram2Data <= (others => 'Z');
                if (mem_write_en = '0') then
                    Ram1EN <= '0';
                    Ram1WE <= clk;
                    Ram1OE <= '1';
                    Ram1Data <= mem_write_data;
                    Ram1Addr <= "00" & Address;
                    data <= Ram1Data;
                elsif (mem_read_en = '0') then
                    Ram1EN <= '0';
                    Ram1OE <= '0';
                    Ram1WE <= '1';
                    Ram1Data <= (others => 'Z');
                    Ram1Addr <= "00" & Address;
                    data <= Ram1Data;
                else
                    Ram1EN <= '1';
                    Ram1WE <= '1';
                    Ram1OE <= '1';
                    Ram1Data <= mem_write_data;
                    Ram1Addr <= (others => '0');
                    data <= Ram1Data;
                end if;
            end if;
        end if;
		  end if;
    end process;
end Behavioral;