--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:57:04 11/15/2015
-- Design Name:   
-- Module Name:   F:/CST/procedure storage/ISE/CPU/sim_if_id.vhd
-- Project Name:  CPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: if_id
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
 
ENTITY sim_if_id IS
END sim_if_id;
 
ARCHITECTURE behavior OF sim_if_id IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT if_id
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         if_pc : IN  std_logic_vector(15 downto 0);
         if_inst : IN  std_logic_vector(15 downto 0);
         id_pc : OUT  std_logic_vector(15 downto 0);
         id_inst : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal if_pc : std_logic_vector(15 downto 0) := (others => '0');
   signal if_inst : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal id_pc : std_logic_vector(15 downto 0);
   signal id_inst : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: if_id PORT MAP (
          clk => clk,
          rst => rst,
          if_pc => if_pc,
          if_inst => if_inst,
          id_pc => id_pc,
          id_inst => id_inst
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
      
		rst <= '1';
		
      if_pc <= x"0001";
      if_inst <= "0000000000000001";
      wait for clk_period;	

      if_pc <= x"0002";
      if_inst <= "0000000000000010";
      wait for clk_period;  

      if_pc <= x"0003";
      if_inst <= "0000000000000100";
      wait for clk_period;  

      if_pc <= x"0004";
      if_inst <= "0000000000001000";
      wait for clk_period;  

      if_pc <= x"0005";
      if_inst <= "0000000000010000";
      wait for clk_period;  

      rst <= '0';
		wait for 10 ns;
		rst <= '1';
      if_pc <= x"0006";
      if_inst <= "0000000000100000";
      wait for clk_period;  
		
		rst <= '0';
		
      wait;
   end process;

END;
