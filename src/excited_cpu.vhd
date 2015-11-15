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

entity excited_cpu is
    Port ( clk : in  std_logic;
           rst : in  std_logic;
           inst: in std_logic_vector(15 downto 0);
           new_inst_addr : out std_logic_vector(15 downto 0);
           inst_en : out std_logic);          
end excited_cpu;

architecture Behavioral of excited_cpu is
    --pc module    
    component pc_reg
        Port (clk : in  std_logic;
              rst : in  std_logic;
              pc  : out std_logic_vector(15 downto 0);
              en  : out std_logic);    
    end component;    

    signal pc : std_logic_vector(15 downto 0);    

    --if/id stage register    
    component if_id 
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --signal from if stage           
               if_pc  : in std_logic_vector(15 downto 0);
               if_inst : in std_logic_vector(15 downto 0);
               --signal for id stage           
               id_pc : out std_logic_vector(15 downto 0);
               id_inst : out std_logic_vector(15 downto 0));
    end component;

    signal id_pc   : std_logic_vector(15 downto 0);
    signal id_inst : std_logic_vector(15 downto 0);

    --instruction decode
    component id
        Port (rst : in  std_logic;
              --signal from if stage          
              pc  : in std_logic_vector(15 downto 0);
              inst: in std_logic_vector(15 downto 0);
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
              wsreg_en  : out std_logic); 
    end component;

    signal reg1_addr, reg2_addr, wreg_addr : std_logic_vector(2 downto 0);
    signal sreg_addr, wsreg_addr : std_logic_vector(1 downto 0);
    signal reg1_en, reg2_en, sreg_en, wreg_en, wsreg_en : std_logic;
    signal alu_op    : std_logic_vector(4 downto 0);
    signal alu_sel   : std_logic_vector(2 downto 0);             
    signal operand1, operand2  : std_logic_vector(15 downto 0);

    --General Purpose Register File
    component g_regfile
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --write_back signal           
               w_addr  : in std_logic_vector(2 downto 0);
               w_data  : in std_logic_vector(15 downto 0);
               w_en    : in std_logic;
               --read_reg signal           
               reg1_addr : in std_logic_vector(2 downto 0);
               reg1_en : in std_logic; 
               reg2_addr : in std_logic_vector(2 downto 0);
               reg2_en : in std_logic;
               reg1_data : out std_logic_vector(15 downto 0);
               reg2_data : out std_logic_vector(15 downto 0));
    end component;

    signal reg1_data,reg2_data : std_logic_vector(15 downto 0);

    --Special Purpose Register File     
    component s_regfile
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --write_back signal           
               w_addr  : in std_logic_vector(1 downto 0);
               w_data  : in std_logic_vector(15 downto 0);
               w_en    : in std_logic;
               --read_reg signal           
               reg_addr : in std_logic_vector(1 downto 0);
               reg_en : in std_logic;           
               reg_data : out std_logic_vector(15 downto 0));       
    end component;

    signal sreg_data : std_logic_vector(15 downto 0);

    --ID/EX stage register
    component id_ex 
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --signal from id stage           
               id_aluop   : in std_logic_vector(4 downto 0);
               id_alusel  : in std_logic_vector(2 downto 0);
               id_operand1: in std_logic_vector(15 downto 0);
               id_operand2: in std_logic_vector(15 downto 0);
               id_wreg_addr : in std_logic_vector(2 downto 0);           
               id_wreg_en   : in std_logic;
               id_wsreg_addr : in std_logic_vector(1 downto 0);           
               id_wsreg_en   : in std_logic;
               --signal for ex stage           
               ex_aluop   : out std_logic_vector(4 downto 0);
               ex_alusel  : out std_logic_vector(2 downto 0);
               ex_operand1: out std_logic_vector(15 downto 0);
               ex_operand2: out std_logic_vector(15 downto 0);
               ex_wreg_addr : out std_logic_vector(2 downto 0);           
               ex_wreg_en   : out std_logic;
               ex_wsreg_addr : out std_logic_vector(1 downto 0);           
               ex_wsreg_en   : out std_logic);
    end component;
    
    signal ex_aluop   : std_logic_vector(4 downto 0);
    signal ex_alusel  : std_logic_vector(2 downto 0);
    signal ex_operand1, ex_operand2: std_logic_vector(15 downto 0);    
    signal ex_wreg_addr : std_logic_vector(2 downto 0);           
    signal ex_wreg_en, ex_wsreg_en   : std_logic;
    signal ex_wsreg_addr : std_logic_vector(1 downto 0);   

    --EX stage (alu)
    component ex
        Port ( rst : in  std_logic;
               --signal from id stage           
               aluop   : in std_logic_vector(4 downto 0);
               alusel  : in std_logic_vector(2 downto 0);
               operand1: in std_logic_vector(15 downto 0);
               operand2: in std_logic_vector(15 downto 0);
               wreg_addr : in std_logic_vector(2 downto 0);          
               wreg_en   : in std_logic;
               wsreg_addr : in std_logic_vector(1 downto 0);          
               wsreg_en   : in std_logic;
               --signal for mem stage          
               wreg_data_out : out std_logic_vector(15 downto 0);
               wreg_addr_out : out std_logic_vector(2 downto 0);           
               wreg_en_out   : out std_logic;
               wsreg_data_out : out std_logic_vector(15 downto 0);
               wsreg_addr_out : out std_logic_vector(1 downto 0);           
               wsreg_en_out   : out std_logic);
    end component;
    
    signal wreg_data_out, wsreg_data_out : std_logic_vector(15 downto 0);
    signal wreg_en_out, wsreg_en_out : std_logic;  
    signal wreg_addr_out : std_logic_vector(2 downto 0);                 
    signal wsreg_addr_out : std_logic_vector(1 downto 0);           
    
    --EX/MEM stage register
    component ex_mem 
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --signal from ex stage           
               ex_wreg_data : in std_logic_vector(15 downto 0);         
               ex_wreg_addr : in std_logic_vector(2 downto 0);           
               ex_wreg_en   : in std_logic;
               ex_wsreg_data: in std_logic_vector(15 downto 0);         
               ex_wsreg_addr: in std_logic_vector(1 downto 0);           
               ex_wsreg_en  : in std_logic;
               --signal for mem stage           
               mem_wreg_data : out std_logic_vector(15 downto 0);         
               mem_wreg_addr : out std_logic_vector(2 downto 0);          
               mem_wreg_en   : out std_logic;
               mem_wsreg_data: out std_logic_vector(15 downto 0);         
               mem_wsreg_addr: out std_logic_vector(1 downto 0);           
               mem_wsreg_en  : out std_logic);
    end component;

    signal mem_wreg_data, mem_wsreg_data : std_logic_vector(15 downto 0);         
    signal mem_wreg_en, mem_wsreg_en  : std_logic;
    signal mem_wreg_addr : std_logic_vector(2 downto 0);              
    signal mem_wsreg_addr: std_logic_vector(1 downto 0);    

    --memory stage
    component mem
        Port ( rst : in  std_logic;
               --signal from ex/mem stage                    
               wreg_data : in std_logic_vector(15 downto 0);           
               wreg_addr : in std_logic_vector(2 downto 0);           
               wreg_en   : in std_logic;
               wsreg_data: in std_logic_vector(15 downto 0);         
               wsreg_addr: in std_logic_vector(1 downto 0);           
               wsreg_en  : in std_logic;
               --signal for mem/wb stage                    
               wreg_data_out : out std_logic_vector(15 downto 0);
               wreg_addr_out : out std_logic_vector(2 downto 0);          
               wreg_en_out   : out std_logic;
               wsreg_data_out : out std_logic_vector(15 downto 0);
               wsreg_addr_out : out std_logic_vector(1 downto 0);           
               wsreg_en_out   : out std_logic);
    end component;

    signal mem_wreg_data_out, mem_wsreg_data_out: std_logic_vector(15 downto 0);
    signal mem_wreg_en_out, mem_wsreg_en_out : std_logic;
    signal mem_wreg_addr_out : std_logic_vector(2 downto 0);   
    signal mem_wsreg_addr_out : std_logic_vector(1 downto 0);          
    
    --mem/wb stage register        
    component mem_wb
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --signal from mem stage            
               mem_wreg_data : in std_logic_vector(15 downto 0);         
               mem_wreg_addr : in std_logic_vector(2 downto 0);          
               mem_wreg_en   : in std_logic;
               mem_wsreg_data : in std_logic_vector(15 downto 0);         
               mem_wsreg_addr : in std_logic_vector(1 downto 0);          
               mem_wsreg_en   : in std_logic;
               --signal for wb stage, directly connect to register file            
               wb_wreg_data : out std_logic_vector(15 downto 0);         
               wb_wreg_addr : out std_logic_vector(2 downto 0);           
               wb_wreg_en   : out std_logic;
               wb_wsreg_data : out std_logic_vector(15 downto 0);         
               wb_wsreg_addr : out std_logic_vector(1 downto 0);           
               wb_wsreg_en   : out std_logic);
    end component; 

    signal wb_wreg_data, wb_wsreg_data : std_logic_vector(15 downto 0); 
    signal wb_wreg_en, wb_wsreg_en : std_logic;      
    signal wb_wreg_addr : std_logic_vector(2 downto 0);           
    signal wb_wsreg_addr : std_logic_vector(1 downto 0);

begin
    pc_unit : pc_reg port map (clk, rst, pc, inst_en);

    new_inst_addr <= pc;  --instruction memory take the output of pc_unit as new address

    if_id_register : if_id port map (clk, rst, pc, inst, id_pc, id_inst);

    id_unit : id port map  (rst, id_pc, id_inst, reg1_data, reg2_data, sreg_data, 
                            reg1_addr, reg1_en, reg2_addr, reg2_en, sreg_addr, sreg_en,
                            alu_op, alu_sel, operand1, operand2, 
                            wreg_addr, wreg_en, wsreg_addr, wsreg_en);

    g_regfile_unit : g_regfile port map(clk, rst, wb_wreg_addr, wb_wreg_data, wb_wreg_en, 
                                        reg1_addr, reg1_en, reg2_addr, reg2_en, 
                                        reg1_data, reg2_data);

    s_regfile_unit : s_regfile port map(clk, rst, wb_wsreg_addr, wb_wsreg_data, wb_wsreg_en,
                                        sreg_addr, sreg_en, sreg_data);

    id_ex_register : id_ex port map(clk, rst, alu_op, alu_sel, operand1, operand2,
                                    wreg_addr, wreg_en, wsreg_addr, wsreg_en,
                                    ex_aluop, ex_alusel, ex_operand1, ex_operand2,
                                    ex_wreg_addr, ex_wreg_en, ex_wsreg_addr, ex_wsreg_en);

    ex_unit : ex port map(rst, ex_aluop, ex_alusel, ex_operand1, ex_operand2,
                          ex_wreg_addr, ex_wreg_en, ex_wsreg_addr, ex_wsreg_en,
                          wreg_data_out, wreg_addr_out, wreg_en_out,
                          wsreg_data_out, wsreg_addr_out, wsreg_en_out);

    ex_mem_register : ex_mem port map(clk, rst, wreg_data_out, wreg_addr_out, wreg_en_out,
                                      wsreg_data_out, wsreg_addr_out, wsreg_en_out,
                                      mem_wreg_data, mem_wreg_addr, mem_wreg_en,
                                      mem_wsreg_data, mem_wsreg_addr, mem_wsreg_en);

    mem_unit : mem port map(rst, mem_wreg_data, mem_wreg_addr, mem_wreg_en,
                            mem_wsreg_data, mem_wsreg_addr, mem_wsreg_en,
                            mem_wreg_data_out, mem_wreg_addr_out, mem_wreg_en_out,
                            mem_wsreg_data_out, mem_wsreg_addr_out, mem_wsreg_en_out);

    mem_wb_register : mem_wb port map(clk, rst, mem_wreg_data_out, mem_wreg_addr_out, mem_wreg_en_out,
                                      mem_wsreg_data_out, mem_wsreg_addr_out, mem_wsreg_en_out,
                                      wb_wreg_data, wb_wreg_addr, wb_wreg_en,
                                      wb_wsreg_data, wb_wsreg_addr, wb_wsreg_en);
end Behavioral;

