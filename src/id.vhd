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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id is  --instruction decode stage
    Port (rst : in  std_logic;
          --signal from if stage          
          pc        : in std_logic_vector(15 downto 0);
          inst		  : in std_logic_vector(15 downto 0);
          --signal from general register file           
			 reg1_data : in std_logic_vector(15 downto 0);
          reg2_data : in std_logic_vector(15 downto 0);
          --signal from special register file 
			 sreg_data : in std_logic_vector(15 downto 0);
          --signal for read general register          
          reg1_addr : out std_logic_vector(2 downto 0);
          reg1_en   : out std_logic;
          reg2_addr : out std_logic_vector(2 downto 0);
          reg2_en   : out std_logic;
          --signal for read special register    
          sreg_addr : out std_logic_vector(1 downto 0);
          sreg_en   : out std_logic;
          --signal for ex stage          
			 alu_op    : out std_logic_vector(4 downto 0);
          alu_sel   : out std_logic_vector(2 downto 0);          
          operand1  : out std_logic_vector(15 downto 0);
          operand2  : out std_logic_vector(15 downto 0);
          --write back signal  
          wreg_addr : out std_logic_vector(2 downto 0);
          wreg_en   : out std_logic;
          wsreg_addr: out std_logic_vector(1 downto 0);
		    wsreg_en  : out std_logic;
          ----------------------------------------------
          --branch judge
          branch      : out std_logic;
          branch_addr : out std_logic_vector(15 downto 0);
          --mem control
          mem_read_en : out std_logic;
          mem_write_en: out std_logic;
          --JALR
          rpc : out std_logic_vector(15 downto 0);
          --stall
          stall : in std_logic;
          stall_request : out std_logic;
          --forwarding 
          ex_reg_write : in std_logic;
          ex_reg_write_addr : in std_logic_vector(2 downto 0);
          ex_sreg_write: in std_logic;
          ex_sreg_write_addr: in std_logic_vector(1 downto 0);
          mem_reg_write : in std_logic;
          mem_reg_write_addr : in std_logic_vector(2 downto 0);
          mem_sreg_write: in std_logic;
          mem_sreg_write_addr: in std_logic_vector(1 downto 0);
          is_ex_load : in std_logic); 
end id;

architecture Behavioral of id is    
    signal inst_header, inst_tail : std_logic_vector(4 downto 0);
    signal regx, regy  : std_logic_vector(2 downto 0);
    signal imm : std_logic_vector(15 downto 0);
    --signal instValid : std_logic := '0';
begin
    Pre_Decode:
    process (inst)
    begin
        inst_header <= inst(15 downto 11);
        regx <= inst(10 downto 8);
        regy <= inst(7 downto 5);
        inst_tail <= inst(4 downto 0);
    end process;

    Decode:
    process (rst, inst_header, inst_tail, regx, regy, reg1_data, reg2_data, sreg_data)
    begin
		if (rst = '0' or inst_header = "00001") then
			alu_op <= "00001";  				--alu operation
         alu_sel <= "000";   				--alu selector
         reg1_en <= '1';     				--read reg1 enable
         reg2_en <= '1';     				--read reg2 enable
			reg1_addr <= "000"; 				--read reg1 address
         reg2_addr <= "000"; 				--read reg2 address
         sreg_en <= '1';     				--read sreg enable
         sreg_addr <= "00";  				--read sreg address           
         wreg_en <= '1';     				--write reg enable
         wreg_addr <= "000"; 				--write reg address
         wsreg_en <= '1';    				--write sreg enable      
         wsreg_addr <= "00"; 				--write sreg address
         branch <= '1';      				--if branch success
         branch_addr <= x"0000";			--branch address
         mem_read_en <= '1'; 				--read memory enanle
         mem_write_en <= '1';				--read memory address
         rpc <= x"0000";     				--RPC for jalr		
			imm <= x"0000";					--immediate number
		else
			alu_op <= inst_header;
			case inst_header is
				when "11100" =>
               reg1_en <= '0';
               reg2_en <= '0';
               reg1_addr <= regx;
               reg2_addr <= regy;
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= inst_tail(4 downto 2);
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000"; 
					imm <= x"0000";
					case inst_tail(1 downto 0) is
						when "01" =>			--ADDU
							alu_sel <= "000";
						when "11" =>			--SUBU
							alu_sel <= "001";
						when others =>
							alu_op <= "00001";
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                    
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "11101" =>
					case inst_tail is
						when "01100" =>		--AND
							alu_sel <= "000";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "01010" =>		--CMP
							alu_sel <= "001";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "00";	--register T
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00000" =>
							case regy is
								when "010" =>	--MFPC
									alu_sel <= "010";
									reg1_en <= '0';
									reg2_en <= '1';
									reg1_addr <= regx;
									reg2_addr <= "000";
									sreg_en <= '1';
									sreg_addr <= "00";
									wreg_en <= '0';                 
									wreg_addr <= regx;
									wsreg_en <= '1';           
									wsreg_addr <= "00";
									branch <= '1';     
									branch_addr <= x"0000";
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when "110" =>	--JALR
									alu_sel <= "101";
									reg1_en <= '0';
									reg2_en <= '1';
									reg1_addr <= regx;
									reg2_addr <= "000";
									sreg_en <= '1';
									sreg_addr <= "00";
									wreg_en <= '1';                 
									wreg_addr <= "000";
									wsreg_en <= '0';           
									wsreg_addr <= "10";	--register RA
									branch <= '0';     
									branch_addr <= reg1_data;
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= pc + 2;
									imm <= x"0000";
								when "000" =>	--JR
									alu_sel <= "110";
									reg1_en <= '0';
									reg2_en <= '1';
									reg1_addr <= regx;
									reg2_addr <= "000";
									sreg_en <= '1';
									sreg_addr <= "00";
									wreg_en <= '1';                 
									wreg_addr <= "000";
									wsreg_en <= '1';           
									wsreg_addr <= "00";
									branch <= '0';     
									branch_addr <= reg1_data;
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when "001" =>	--JRRA
									alu_sel <= "111";
									reg1_en <= '1';
									reg2_en <= '1';
									reg1_addr <= "000";
									reg2_addr <= "000";
									sreg_en <= '0';
									sreg_addr <= "10";	--register RA
									wreg_en <= '1';                 
									wreg_addr <= "000";
									wsreg_en <= '1';           
									wsreg_addr <= "00";
									branch <= '0';     
									branch_addr <= sreg_data;
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when others =>
									alu_op <= "00001";
									alu_sel <= "000";
									reg1_en <= '1';
									reg2_en <= '1';
									reg1_addr <= "000";
									reg2_addr <= "000";
									sreg_en <= '1';
									sreg_addr <= "00";
									wreg_en <= '1';                    
									wreg_addr <= "000";
									wsreg_en <= '1';           
									wsreg_addr <= "00";
									branch <= '1';     
									branch_addr <= x"0000";
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
							end case;
						when "01101" =>		--OR
							alu_sel <= "011";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00011" =>		--SLTU
							alu_sel <= "100";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "00";	--register T
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when others =>
							alu_op <= "00001";
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                    
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "11110" =>
					case inst_tail is
						when "00000" =>		--MFIH
							alu_sel <= "000";
							reg1_en <= '0';
							reg2_en <= '1';
							reg1_addr <= regx;
							reg2_addr <= "000";
							sreg_en <= '0';
							sreg_addr <= "01";	--register IH
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00001" =>		--MTIH
							alu_sel <= "001";
							reg1_en <= '0';
							reg2_en <= '1';
							reg1_addr <= regx;
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "01";	--register IH
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when others =>
							alu_op <= "00001";
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                    
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "01111" =>				--MOVE
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regy;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= regx;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= x"0000";
				when "01100" =>
					case regx is
						when "100" =>			--MTSP
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '0';
							reg1_addr <= "000";
							reg2_addr <= regx;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "11";	--register SP
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "011" =>			--ADDSP
							alu_sel <= "001";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '0';
							sreg_addr <= "11";	--register SP
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "11";	--register SP
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= SXT(inst(7 downto 0),16);
						when "000" =>			--BTEQZ
							alu_sel <= "010";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '0';
							sreg_addr <= "00";	--register T
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							if(sreg_data(0) = '0') then
								branch <= '0';     
								branch_addr <= pc + SXT(inst(7 downto 0),16);
							else
								branch <= '1';
								branch_addr <= x"0000";
							end if;
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= SXT(inst(7 downto 0),16);
						when others =>
							alu_op <= "00001";
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                    
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "00110" =>
					case inst_tail(1 downto 0) is
						when "00" =>			--SLL
							alu_sel <= "000";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= "0000000000000" & inst_tail(4 downto 2);
						when "11" =>			--SRA
							alu_sel <= "001";
							reg1_en <= '0';
							reg2_en <= '0';
							reg1_addr <= regx;
							reg2_addr <= regy;
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= "0000000000000" & inst_tail(4 downto 2);
						when others =>
							alu_op <= "00001";
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                    
							wreg_addr <= "000";
							wsreg_en <= '1';           
							wsreg_addr <= "00";
							branch <= '1';     
							branch_addr <= x"0000";
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "01001" =>				--ADDIU
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= regx;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "01000" =>				--ADDIU3
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '0';
               reg1_addr <= regx;
               reg2_addr <= regy;
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= regy;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst_tail(3 downto 0),16);
				when "01110" =>				--CMPI
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '0';           
               wsreg_addr <= "00";					--regsiter T
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "01101" =>				--LI
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= regx;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= "00000000" & inst(7 downto 0);
				when "10011" =>				--LW
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '0';
               reg1_addr <= regx;
               reg2_addr <= regy;
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '0';                 
               wreg_addr <= regy;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '0'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst_tail,16);
				when "10010" =>				--LW_SP
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '0';
               sreg_addr <= "11";						--register SP
               wreg_en <= '0';                 
               wreg_addr <= regx;
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '0'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "11011" =>				--SW
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '0';
               reg1_addr <= regx;
               reg2_addr <= regy;
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '0';
               rpc <= x"0000";
					imm <= SXT(inst_tail,16);
				when "11010" =>				--SW_SP
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '0';
               sreg_addr <= "11";						--register SP
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '0';
               rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "00010" =>				--B
					alu_sel <= "000";
					reg1_en <= '1';
               reg2_en <= '1';
               reg1_addr <= "000";
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '0';     
               branch_addr <= pc + SXT(inst(10 downto 0),16);
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= SXT(inst(10 downto 0),16);
				when "00100" =>				--BEQZ
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
					if( reg1_data = x"0000") then
						branch <= '0';     
						branch_addr <= pc + SXT(inst(7 downto 0),16);
						imm <= SXT(inst(7 downto 0),16);
					else
						branch <= '1';
						branch_addr <= x"0000";
						imm <= x"0000";
					end if;
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
				when "00101" =>				--BNEZ
					alu_sel <= "000";
					reg1_en <= '0';
               reg2_en <= '1';
               reg1_addr <= regx;
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                 
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
					if( reg1_data = x"0000") then
						branch <= '1';
						branch_addr <= x"0000";
						imm <= x"0000";
					else
						branch <= '0';     
						branch_addr <= pc + SXT(inst(7 downto 0),16);
						imm <= SXT(inst(7 downto 0),16);
					end if;
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
				when others =>
					alu_op <= "00001";
               alu_sel <= "000";
               reg1_en <= '1';
               reg2_en <= '1';
               reg1_addr <= "000";
               reg2_addr <= "000";
               sreg_en <= '1';
               sreg_addr <= "00";
               wreg_en <= '1';                    
               wreg_addr <= "000";
               wsreg_en <= '1';           
               wsreg_addr <= "00";
               branch <= '1';     
               branch_addr <= x"0000";
               mem_read_en <= '1'; 
               mem_write_en <= '1';
               rpc <= x"0000";
					imm <= x"0000";
			end case;
		end if;
    end process;
end Behavioral;

