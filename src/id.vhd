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
          inst		: in std_logic_vector(15 downto 0);
          --signal from general register file           
		  reg1_data : in std_logic_vector(15 downto 0);
          reg2_data : in std_logic_vector(15 downto 0);
          --signal from special register file 
		  sreg_data : in std_logic_vector(15 downto 0);
          --signal for read general register          
          reg1_addr : inout std_logic_vector(2 downto 0);
          reg1_en   : inout std_logic;
          reg2_addr : inout std_logic_vector(2 downto 0);
          reg2_en   : inout std_logic;
          --signal for read special register    
          sreg_addr : inout std_logic_vector(1 downto 0);
          sreg_en   : inout std_logic;
          --signal for ex stage          		  
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
          mem_write_en: inout std_logic;
          mem_write_data: out std_logic_vector(15 downto 0);          
          --stall          
          stall_request : out std_logic;
          --forwarding 
          ex_reg_write : in std_logic;
          ex_reg_write_addr : in std_logic_vector(2 downto 0);
          ex_reg_write_data : in std_logic_vector(15 downto 0);
          ex_sreg_write: in std_logic;
          ex_sreg_write_addr: in std_logic_vector(1 downto 0);
          ex_sreg_write_data : in std_logic_vector(15 downto 0);
          mem_reg_write : in std_logic;
          mem_reg_write_addr : in std_logic_vector(2 downto 0);
          mem_reg_write_data : in std_logic_vector(15 downto 0);
          mem_sreg_write: in std_logic;
          mem_sreg_write_addr: in std_logic_vector(1 downto 0);
          mem_sreg_write_data : in std_logic_vector(15 downto 0);
          is_ex_load : in std_logic;
          ex_load_addr: in std_logic_vector(2 downto 0)); 
end id;

architecture Behavioral of id is    
    signal inst_header, inst_tail : std_logic_vector(4 downto 0);
    signal regx, regy  : std_logic_vector(2 downto 0);
    signal imm : std_logic_vector(15 downto 0);
    signal reg1_data_no_conflict : std_logic_vector(15 downto 0);
    signal reg2_data_no_conflict : std_logic_vector(15 downto 0);
    signal sreg_data_no_conflict : std_logic_vector(15 downto 0);
    --JALR
    signal rpc : std_logic_vector(15 downto 0);   
begin
    Pre_Decode:
    process (inst)
    begin
        inst_header <= inst(15 downto 11);
        regx <= inst(10 downto 8);
        regy <= inst(7 downto 5);
        inst_tail <= inst(4 downto 0);
    end process;

    Handle_Load_Conflict:
    process (is_ex_load, ex_load_addr, reg1_addr, reg1_en, reg2_addr, reg2_en)        
    begin
        if (is_ex_load = '0') then
            if (reg1_en = '0' and reg1_addr = ex_load_addr) then
                stall_request <= '0';
            elsif (reg2_en = '0' and reg2_addr = ex_load_addr) then
                stall_request <= '0';
            else
                stall_request <= '1';
            end if;
        else 
            stall_request <= '1';
        end if;
    end process;

    Handle_Data_Conflict_Reg1:
    process (reg1_data, reg1_addr, reg1_en, 
             ex_reg_write_data, ex_reg_write_addr, ex_reg_write,
             mem_reg_write_data, mem_reg_write_addr, mem_reg_write)
    begin
        if (reg1_en = '0') then
            if (ex_reg_write = '0' and ex_reg_write_addr = reg1_addr) then
                reg1_data_no_conflict <= ex_reg_write_data;
            elsif (mem_reg_write = '0' and mem_reg_write_addr = reg1_addr) then
                reg1_data_no_conflict <= mem_reg_write_data;
            else 
                reg1_data_no_conflict <= reg1_data;
            end if;
        else 
            reg1_data_no_conflict <= x"0000";
        end if;
    end process;

    Handle_Data_Conflict_Reg2:
    process (reg2_data, reg2_addr, reg2_en, 
             ex_reg_write_data, ex_reg_write_addr, ex_reg_write,
             mem_reg_write_data, mem_reg_write_addr, mem_reg_write)
    begin
        if (reg2_en = '0') then
            if (ex_reg_write = '0' and ex_reg_write_addr = reg2_addr) then
                reg2_data_no_conflict <= ex_reg_write_data;
            elsif (mem_reg_write = '0' and mem_reg_write_addr = reg2_addr) then
                reg2_data_no_conflict <= mem_reg_write_data;
            else 
                reg2_data_no_conflict <= reg2_data;
            end if;
        else 
            reg2_data_no_conflict <= x"0000";
        end if;
    end process;

    Handle_Data_Conflict_SReg:
    process (sreg_data, sreg_addr, sreg_en, 
             ex_sreg_write_data, ex_sreg_write_addr, ex_sreg_write,
             mem_sreg_write_data, mem_sreg_write_addr, mem_sreg_write)
    begin
        if (sreg_en = '0') then
            if (ex_sreg_write = '0' and ex_sreg_write_addr = sreg_addr) then
                sreg_data_no_conflict <= ex_sreg_write_data;
            elsif (mem_sreg_write = '0' and mem_sreg_write_addr = sreg_addr) then
                sreg_data_no_conflict <= mem_sreg_write_data;
            else 
                sreg_data_no_conflict <= sreg_data;
            end if;
        else 
            sreg_data_no_conflict <= x"0000";
        end if;
    end process;

    Handle_Branch_Conflict:
    process (rst, inst, reg1_data_no_conflict, sreg_data_no_conflict)
        variable pc_1 : std_logic_vector(15 downto 0);
    begin
        if (rst = '0') then
            branch <= '1';
            branch_addr <= x"0000";
        else 
            pc_1 := pc + 1;
            case (inst(15 downto 11)) is
                when "00010" => --B
                    branch <= '0';
                    branch_addr <= pc_1 + SXT(inst(10 downto 0),16);
                when "00100" => --BEQZ
                    if (reg1_data_no_conflict = x"0000") then
                        branch <= '0';
                        branch_addr <= pc_1 + SXT(inst(7 downto 0),16);
                    else 
                        branch <= '1';
                        branch_addr <= x"0000";
                    end if;
                when "00101" => --BNEZ
                    if (reg1_data_no_conflict /= x"0000") then
                        branch <= '0';
                        branch_addr <= pc_1 + SXT(inst(7 downto 0),16);
                    else 
                        branch <= '1';
                        branch_addr <= x"0000";
                    end if;
                when "01100" => --BTEQZ
                    if(inst(10 downto 8) = "000" and sreg_data_no_conflict = x"0000") then
                        branch <= '0';     
                        branch_addr <= pc_1 + SXT(inst(7 downto 0),16);
                    else
                        branch <= '1';
                        branch_addr <= x"0000";
                    end if;
                when "11101" =>
                    case (inst(7 downto 0)) is                    
                        when "11000000" => --JALR
                            branch <= '0';
                            branch_addr <= reg1_data_no_conflict;
                        when "00000000" => --JR
                            branch <= '0';
                            branch_addr <= reg1_data_no_conflict;
                        when "00100000" => --JRRA
                            branch <= '0';
                            branch_addr <= sreg_data_no_conflict;
                        when others =>
                            branch <= '1';
                            branch_addr <= x"0000";
                    end case ;
                when others =>
                    branch <= '1';
                    branch_addr <= x"0000";
            end case;
        end if;
    end process;

    Update_Operand:
    process(inst, reg1_data_no_conflict, reg1_en, reg2_data_no_conflict, reg2_en,
            sreg_data_no_conflict, sreg_en, imm, mem_write_en, rpc)
    begin
        if (mem_write_en = '0') then
            if (inst(15 downto 11) = "11011") then --SW
                operand1 <= reg1_data_no_conflict;
                operand2 <= imm;
            else  --SW_SP
                operand1 <= sreg_data_no_conflict;
                operand2 <= imm;
            end if;
        elsif (sreg_en = '0') then
            operand1 <= sreg_data_no_conflict;
            operand2 <= imm;
        elsif (reg1_en = '0' and reg2_en = '0') then
            operand1 <= reg1_data_no_conflict;
            operand2 <= reg2_data_no_conflict;
        elsif (reg1_en = '0' and reg2_en = '1') then
            if (rpc /= x"0000") then --JALR
                operand1 <= rpc;
                operand2 <= x"0000";
            else
                operand1 <= reg1_data_no_conflict;
                operand2 <= imm;
            end if;
        elsif (reg1_en = '1' and reg2_en = '1') then
            if (inst(15 downto 11) = "11101" and inst(7 downto 0) = "01000000") then --MFPC
                operand1 <= pc + 1;
                operand2 <= imm;
            elsif (inst(15 downto 11)="01101") then --LI
                operand1 <= imm;
                operand2 <= x"0000";
            else
                operand1 <= x"0000";
                operand2 <= x"0000";
            end if;
        else
            operand1 <= x"0000";
            operand2 <= x"0000";
        end if;
    end process;

    Handle_Mem_Write_Addr:
    process (inst, reg1_data_no_conflict, reg2_data_no_conflict)
    begin
        if (inst(15 downto 11) = "11011") then
            mem_write_data <= reg2_data_no_conflict;
        elsif (inst(15 downto 11) = "11010") then
            mem_write_data <= reg1_data_no_conflict;
        else
            mem_write_data <= "ZZZZZZZZZZZZZZZZ";
        end if;
    end process;

    Decode:
    process (rst, inst_header, inst_tail, regx, regy, reg1_data, reg2_data, sreg_data)
    begin
		if (rst = '0' or inst_header = "00001") then			
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
            mem_read_en <= '1'; 				--read memory enanle
            mem_write_en <= '1';				--read memory address        
            rpc <= x"0000";     				--RPC for jalr		
			imm <= x"0000";					    --immediate number
		else			
			case inst_header is
				when "11100" => --ADDU|SUBU
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "11101" => --AND|CMP|MFPC|OR|SLTU|JALR|JR|JRRA
					case inst_tail is
						when "01100" =>		--AND
							alu_sel <= "110";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "01010" =>		--CMP
							alu_sel <= "010";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00000" => --MFPC|JALR|JR|JRRA
							case regy is
								when "010" =>	--MFPC
									alu_sel <= "000";
									reg1_en <= '1';
									reg2_en <= '1';
									reg1_addr <= "000";
									reg2_addr <= "000";
									sreg_en <= '1';
									sreg_addr <= "00";
									wreg_en <= '0';                 
									wreg_addr <= regx;
									wsreg_en <= '1';           
									wsreg_addr <= "00";									
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when "110" =>	--JALR
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
									wsreg_addr <= "10";	--register RA									
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= pc + 2;
									imm <= x"0000";
								when "000" =>	--JR
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
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when "001" =>	--JRRA
									alu_sel <= "000";
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
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
								when others =>									
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
									mem_read_en <= '1'; 
									mem_write_en <= '1';
									rpc <= x"0000";
									imm <= x"0000";
							end case;
						when "01101" =>		--OR
							alu_sel <= "111";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00011" =>		--SLTU
							alu_sel <= "011";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when others =>							
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "11110" =>  --MFIH|MTIH
					case inst_tail is
						when "00000" =>		--MFIH
							alu_sel <= "000";
							reg1_en <= '1';
							reg2_en <= '1';
							reg1_addr <= "000";
							reg2_addr <= "000";
							sreg_en <= '0';
							sreg_addr <= "01";	--register IH
							wreg_en <= '0';                 
							wreg_addr <= regx;
							wsreg_en <= '1';           
							wsreg_addr <= "00";							
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "00001" =>		--MTIH
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
							wsreg_addr <= "01";	--register IH							
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when others =>							
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= x"0000";
				when "01100" =>  --MTSP|ADDSP|BTEQZ
					case regx is
						when "100" =>			--MTSP
							alu_sel <= "000";
							reg1_en <= '0';
							reg2_en <= '1';
							reg1_addr <= regy;
							reg2_addr <= "000";
							sreg_en <= '1';
							sreg_addr <= "00";
							wreg_en <= '1';                 
							wreg_addr <= "000";
							wsreg_en <= '0';           
							wsreg_addr <= "11";	--register SP							
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
						when "011" =>			--ADDSP
							alu_sel <= "000";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= SXT(inst(7 downto 0), 16);
						when "000" =>			--BTEQZ
							alu_sel <= "000";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= SXT(inst(7 downto 0), 16);
						when others =>							
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "00110" => --SLL|SRA
					case inst_tail(1 downto 0) is
						when "00" =>			--SLL
							alu_sel <= "100";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= "0000000000000" & inst_tail(4 downto 2);
						when "11" =>			--SRA
							alu_sel <= "101";
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= "0000000000000" & inst_tail(4 downto 2);
						when others =>							
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
							mem_read_en <= '1'; 
							mem_write_en <= '1';
							rpc <= x"0000";
							imm <= x"0000";
					end case;
				when "01001" =>		--ADDIU
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "01000" =>		--ADDIU3
					alu_sel <= "000";
					reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regx;
                    reg2_addr <= "000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    wreg_en <= '0';                 
                    wreg_addr <= regy;
                    wsreg_en <= '1';           
                    wsreg_addr <= "00";               
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
    				imm <= SXT(inst_tail(3 downto 0),16);
				when "01110" =>		--CMPI
					alu_sel <= "010";
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "01101" =>		--LI
					alu_sel <= "000";
					reg1_en <= '1';
                    reg2_en <= '1';
                    reg1_addr <= "000";
                    reg2_addr <= "000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    wreg_en <= '0';                 
                    wreg_addr <= regx;
                    wsreg_en <= '1';           
                    wsreg_addr <= "00";               
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= "00000000" & inst(7 downto 0);
				when "10011" =>		--LW
					alu_sel <= "000";
					reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regx;
                    reg2_addr <= "000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    wreg_en <= '0';                 
                    wreg_addr <= regy;
                    wsreg_en <= '1';           
                    wsreg_addr <= "00";               
                    mem_read_en <= '0'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= SXT(inst_tail, 16);
				when "10010" =>		--LW_SP
					alu_sel <= "000";
					reg1_en <= '1';
                    reg2_en <= '1';
                    reg1_addr <= "000";
                    reg2_addr <= "000";
                    sreg_en <= '0';
                    sreg_addr <= "11";						--register SP
                    wreg_en <= '0';                 
                    wreg_addr <= regx;
                    wsreg_en <= '1';           
                    wsreg_addr <= "00";               
                    mem_read_en <= '0'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "11011" =>		--SW
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '0';
                    rpc <= x"0000";
					imm <= SXT(inst_tail,16);
				when "11010" =>		--SW_SP
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '0';
                    rpc <= x"0000";
					imm <= SXT(inst(7 downto 0),16);
				when "00010" =>		--B
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
				    imm <= SXT(inst(10 downto 0),16);
				when "00100" =>		--BEQZ
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
                    imm <= SXT(inst(7 downto 0),16);
				when "00101" =>		--BNEZ
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
                    imm <= SXT(inst(7 downto 0),16);
				when others =>					
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
                    mem_read_en <= '1'; 
                    mem_write_en <= '1';
                    rpc <= x"0000";
					imm <= x"0000";
			end case;
		end if;
    end process;
end Behavioral;

