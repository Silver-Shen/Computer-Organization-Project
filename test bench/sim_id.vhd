--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:52:49 11/15/2015
-- Design Name:   
-- Module Name:   F:/CST/procedure storage/ISE/CPU/sim_id.vhd
-- Project Name:  CPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: id
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
 
ENTITY sim_id IS
END sim_id;
 
ARCHITECTURE behavior OF sim_id IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT id
    PORT(
         rst : IN  std_logic;
         pc : IN  std_logic_vector(15 downto 0);
         inst : IN  std_logic_vector(15 downto 0);
         reg1_data : IN  std_logic_vector(15 downto 0);
         reg2_data : IN  std_logic_vector(15 downto 0);
         sreg_data : IN  std_logic_vector(15 downto 0);
         reg1_addr : OUT  std_logic_vector(2 downto 0);
         reg1_en : OUT  std_logic;
         reg2_addr : OUT  std_logic_vector(2 downto 0);
         reg2_en : OUT  std_logic;
         sreg_addr : OUT  std_logic_vector(1 downto 0);
         sreg_en : OUT  std_logic;
         alu_op : OUT  std_logic_vector(4 downto 0);
         alu_sel : OUT  std_logic_vector(2 downto 0);
         operand1 : OUT  std_logic_vector(15 downto 0);
         operand2 : OUT  std_logic_vector(15 downto 0);
         wreg_addr : OUT  std_logic_vector(2 downto 0);
         wreg_en : OUT  std_logic;
         wsreg_addr : OUT  std_logic_vector(1 downto 0);
         wsreg_en : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal pc : std_logic_vector(15 downto 0) := (others => '0');
   signal inst : std_logic_vector(15 downto 0) := (others => '0');
   signal reg1_data : std_logic_vector(15 downto 0) := (others => '0');
   signal reg2_data : std_logic_vector(15 downto 0) := (others => '0');
   signal sreg_data : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal reg1_addr : std_logic_vector(2 downto 0);
   signal reg1_en : std_logic;
   signal reg2_addr : std_logic_vector(2 downto 0);
   signal reg2_en : std_logic;
   signal sreg_addr : std_logic_vector(1 downto 0);
   signal sreg_en : std_logic;
   signal alu_op : std_logic_vector(4 downto 0);
   signal alu_sel : std_logic_vector(2 downto 0);
   signal operand1 : std_logic_vector(15 downto 0);
   signal operand2 : std_logic_vector(15 downto 0);
   signal wreg_addr : std_logic_vector(2 downto 0);
   signal wreg_en : std_logic;
   signal wsreg_addr : std_logic_vector(1 downto 0);
   signal wsreg_en : std_logic;
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: id PORT MAP (
          rst => rst,
          pc => pc,
          inst => inst,
          reg1_data => reg1_data,
          reg2_data => reg2_data,
          sreg_data => sreg_data,
          reg1_addr => reg1_addr,
          reg1_en => reg1_en,
          reg2_addr => reg2_addr,
          reg2_en => reg2_en,
          sreg_addr => sreg_addr,
          sreg_en => sreg_en,
          alu_op => alu_op,
          alu_sel => alu_sel,
          operand1 => operand1,
          operand2 => operand2,
          wreg_addr => wreg_addr,
          wreg_en => wreg_en,
          wsreg_addr => wsreg_addr,
          wsreg_en => wsreg_en
        );

   -- Stimulus process
   stim_proc: process
   begin

    --part1: rst test
	 pc <= x"0001";
    rst <= '0';
	 reg1_data <= x"0123";
    reg2_data <= x"0321";
    inst <= "0111101000100000";
    wait for clk_period;

    --part2 move test
    rst <= '1';
    pc <= x"0002";
    inst <= "0111101000100000";
    wait for clk_period;

    --part3 addiu test
	 pc <= x"0003";
    inst <= "0100101111111111";
    wait for clk_period;

    --part4 addiu3 test
	 pc <= x"0004";
    inst <= "0100001000101111";
    wait for clk_period;

    --part5 cmpi test
	 pc <= x"0005";
    inst <= "0111001111111111";
    wait for clk_period;

    --part6 addu test
	 pc <= x"0006";
    inst <= "1110001000110001";
    wait for clk_period;

    --part7 nop test
	 pc <= x"0007";
    inst <= "0000100000000000";
    wait for clk_period;
    wait;
   end process;

END;
