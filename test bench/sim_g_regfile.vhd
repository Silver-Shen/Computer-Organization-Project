--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:58:45 11/15/2015
-- Design Name:   
-- Module Name:   F:/CST/procedure storage/ISE/CPU/sim_g_regfile.vhd
-- Project Name:  CPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: g_regfile
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sim_g_regfile IS
END sim_g_regfile;
 
ARCHITECTURE behavior OF sim_g_regfile IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT g_regfile
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         w_addr : IN  std_logic_vector(2 downto 0);
         w_data : IN  std_logic_vector(15 downto 0);
         w_en : IN  std_logic;
         reg1_addr : IN  std_logic_vector(2 downto 0);
         reg1_en : IN  std_logic;
         reg2_addr : IN  std_logic_vector(2 downto 0);
         reg2_en : IN  std_logic;
         reg1_data : OUT  std_logic_vector(15 downto 0);
         reg2_data : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal w_addr : std_logic_vector(2 downto 0) := (others => '0');
   signal w_data : std_logic_vector(15 downto 0) := (others => '0');
   signal w_en : std_logic := '0';
   signal reg1_addr : std_logic_vector(2 downto 0) := (others => '0');
   signal reg1_en : std_logic := '0';
   signal reg2_addr : std_logic_vector(2 downto 0) := (others => '0');
   signal reg2_en : std_logic := '0';

 	--Outputs
   signal reg1_data : std_logic_vector(15 downto 0);
   signal reg2_data : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: g_regfile PORT MAP (
          clk => clk,
          rst => rst,
          w_addr => w_addr,
          w_data => w_data,
          w_en => w_en,
          reg1_addr => reg1_addr,
          reg1_en => reg1_en,
          reg2_addr => reg2_addr,
          reg2_en => reg2_en,
          reg1_data => reg1_data,
          reg2_data => reg2_data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

      --part0: reg initial
      rst <= '1';
      w_en <= '0';
      reg1_en <= '1';
      reg2_en <= '1';

      w_addr <= "000";
      w_data <= x"0001";
      wait for clk_period;      
      w_addr <= "001";
      w_data <= x"0010";
      wait for clk_period;      
      w_addr <= "010";
      w_data <= x"0100";
      wait for clk_period;      
      w_addr <= "011";
      w_data <= x"1000";
      wait for clk_period;      
      w_addr <= "100";
      w_data <= x"1001";
      wait for clk_period;      
      w_addr <= "101";
      w_data <= x"1010";
      wait for clk_period;      
      w_addr <= "110";
      w_data <= x"1100";
      wait for clk_period;      
      w_addr <= "111";
      w_data <= x"1111";
      wait for clk_period;                

      --part1: rst test
      rst <= '0';
      w_en <= '1';
      reg1_en <= '0';
      reg1_addr <= "010";
      wait for clk_period;

      --part2: normal & wb hazard test
      rst <= '1';
      w_en <= '0';
      w_addr <= "111";
      w_data <= x"1101";
      reg1_en <= '0';
      reg2_en <= '0';
      reg1_addr <= "101";
      reg2_addr <= "111";
      wait for clk_period;
      
      --part3: stall(need update) test
      w_en <= '1';      
      reg1_en <= '1';
      reg1_addr <= "000";
      reg2_addr <= "110";
      wait for clk_period;

      wait;
   end process;

END;
