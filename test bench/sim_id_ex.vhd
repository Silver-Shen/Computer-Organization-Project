--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:57:48 11/15/2015
-- Design Name:   
-- Module Name:   F:/CST/procedure storage/ISE/CPU/sim_id_ex.vhd
-- Project Name:  CPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: id_ex
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
 
ENTITY sim_id_ex IS
END sim_id_ex;
 
ARCHITECTURE behavior OF sim_id_ex IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT id_ex
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         id_aluop : IN  std_logic_vector(4 downto 0);
         id_alusel : IN  std_logic_vector(2 downto 0);
         id_operand1 : IN  std_logic_vector(15 downto 0);
         id_operand2 : IN  std_logic_vector(15 downto 0);
         id_wreg_addr : IN  std_logic_vector(2 downto 0);
         id_wreg_en : IN  std_logic;
         id_wsreg_addr : IN  std_logic_vector(1 downto 0);
         id_wsreg_en : IN  std_logic;
         ex_aluop : OUT  std_logic_vector(4 downto 0);
         ex_alusel : OUT  std_logic_vector(2 downto 0);
         ex_operand1 : OUT  std_logic_vector(15 downto 0);
         ex_operand2 : OUT  std_logic_vector(15 downto 0);
         ex_wreg_addr : OUT  std_logic_vector(2 downto 0);
         ex_wreg_en : OUT  std_logic;
         ex_wsreg_addr : OUT  std_logic_vector(1 downto 0);
         ex_wsreg_en : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal id_aluop : std_logic_vector(4 downto 0) := (others => '0');
   signal id_alusel : std_logic_vector(2 downto 0) := (others => '0');
   signal id_operand1 : std_logic_vector(15 downto 0) := (others => '0');
   signal id_operand2 : std_logic_vector(15 downto 0) := (others => '0');
   signal id_wreg_addr : std_logic_vector(2 downto 0) := (others => '0');
   signal id_wreg_en : std_logic := '0';
   signal id_wsreg_addr : std_logic_vector(1 downto 0) := (others => '0');
   signal id_wsreg_en : std_logic := '0';

 	--Outputs
   signal ex_aluop : std_logic_vector(4 downto 0);
   signal ex_alusel : std_logic_vector(2 downto 0);
   signal ex_operand1 : std_logic_vector(15 downto 0);
   signal ex_operand2 : std_logic_vector(15 downto 0);
   signal ex_wreg_addr : std_logic_vector(2 downto 0);
   signal ex_wreg_en : std_logic;
   signal ex_wsreg_addr : std_logic_vector(1 downto 0);
   signal ex_wsreg_en : std_logic;

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: id_ex PORT MAP (
          clk => clk,
          rst => rst,
          id_aluop => id_aluop,
          id_alusel => id_alusel,
          id_operand1 => id_operand1,
          id_operand2 => id_operand2,
          id_wreg_addr => id_wreg_addr,
          id_wreg_en => id_wreg_en,
          id_wsreg_addr => id_wsreg_addr,
          id_wsreg_en => id_wsreg_en,
          ex_aluop => ex_aluop,
          ex_alusel => ex_alusel,
          ex_operand1 => ex_operand1,
          ex_operand2 => ex_operand2,
          ex_wreg_addr => ex_wreg_addr,
          ex_wreg_en => ex_wreg_en,
          ex_wsreg_addr => ex_wsreg_addr,
          ex_wsreg_en => ex_wsreg_en
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
      
      rst <= '0';
      id_aluop <= "01111";
      id_alusel <= "000";
      id_operand1 <= x"0123";
      id_operand2 <= x"0321";
      id_wreg_addr <= "010";
      id_wreg_en <= '0';
      id_wsreg_addr <= "00";
      id_wsreg_en <= '1';
      wait for clk_period/2;

		rst <= '1';
      id_aluop <= "01111";
      id_alusel <= "000";
      id_operand1 <= x"0123";
      id_operand2 <= x"0321";
      id_wreg_addr <= "010";
      id_wreg_en <= '0';
      id_wsreg_addr <= "00";
      id_wsreg_en <= '1';
      wait for clk_period/2;
      
      wait;
   end process;

END;
