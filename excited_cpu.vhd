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
    Port ( fclk : in  std_logic;			  
           rst  : in  std_logic;           
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
           --signal for series2
           uart_clk : in STD_LOGIC; --11.0592MHz
           rxd      : in STD_LOGIC; --data received
           sdo      : out STD_LOGIC;--); --data transmited                 
			  --test
			  L		  : out STD_LOGIC_VECTOR(15 downto 0);
		--	  time_slice_signal : out STD_LOGIC_VECTOR(3 downto 0);
		--	  flush_count_signal : out STD_LOGIC_VECTOR(1 downto 0);
			  hclk		: in STD_LOGIC;
			  clk_mode  : in STD_LOGIC;
		--	  process_mode : out STD_LOGIC);
			  sel_mode  : in STD_LOGIC;
			  --flash
			  flash_data : inout  STD_LOGIC_VECTOR(15 downto 0);
			  flash_addr_out : out  STD_LOGIC_VECTOR(22 downto 0);
			  flash_byte :out	STD_LOGIC;
			  flash_vpen :out	STD_LOGIC;
			  flash_ce : out	STD_LOGIC;
			  flash_rp :out	STD_LOGIC;
			  flash_we : out	STD_LOGIC;
			  flash_oe : out	STD_LOGIC;
			  --vga & ps2
			  R 		: out STD_LOGIC_VECTOR (2 downto 0);
			  G 		: out STD_LOGIC_VECTOR (2 downto 0);
		     B 		: out STD_LOGIC_VECTOR (2 downto 0);
			  Hs 	: out STD_LOGIC ;
			  Vs 	: out STD_LOGIC ;
		     ps2clk : in  STD_LOGIC;
		     ps2data : in  STD_LOGIC
			  );
end excited_cpu;

architecture Behavioral of excited_cpu is
	 
	 --test
	 signal time_slice_signal : STD_LOGIC_VECTOR(3 downto 0);
	 signal flush_count_signal : STD_LOGIC_VECTOR(2 downto 0);
	 signal out_pc_signal : STD_LOGIC_VECTOR(15 downto 0);
	 
    --uart unit
    component uart
        PORT (rst, clk, rxd, rdn, wrn : in std_logic;
              data_in          : in std_logic_vector(7 downto 0);
              data_out          : out std_logic_vector(7 downto 0);
              data_ready    : out std_logic;
              parity_error  : out std_logic;
              framing_error : out std_logic;
              tbre          : out std_logic;
              tsre          : out std_logic;
              sdo           : out std_logic);
    end component;
    signal uart_data_in    : std_logic_vector(7 downto 0);
    signal uart_data_out    : std_logic_vector(7 downto 0);
    signal data_ready2  : std_logic;
    signal parity_error : STD_LOGIC;
    signal framing_error: std_logic;
    signal tbre2, tsre2 : std_logic;   
	
	component fd_clk
	   Port (   rst      : in STD_LOGIC;
                clk      : in  STD_LOGIC;            
                main_clk : out  STD_LOGIC;            
                --for double kernel
               mode      : out std_logic := '0';
                stall    : inout STD_LOGIC := '1';
					 pc_stall : out std_logic := '1';
				time_slice_signal : out STD_LOGIC_VECTOR(3 downto 0);
				flush_count_signal : out STD_LOGIC_VECTOR(2 downto 0);
				hclk		: in STD_LOGIC;
				clk_mode : in STD_LOGIC;
				uart_clk : in STD_LOGIC;
            cpu_en   : in STD_LOGIC; 
            flash_clk: out STD_LOGIC);
	end component;
	signal clk : std_logic;
    signal mode, fd_stall_request,pc_stall_s : STD_LOGIC;
	 signal cpu_en : std_logic;
	 signal flash_clk : std_logic;

 --vga & ps2
	 
	 component ps2
    Port ( fclk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
			  out_data : out STD_LOGIC_VECTOR(7 downto 0);	
			  data_ready : out STD_LOGIC := '1');
	end component;
	
	signal data_e : STD_LOGIC_VECTOR (7 downto 0);
	signal data_ready_e : STD_LOGIC;
	
	component vga
      Port (
				clk 	: in  STD_LOGIC;
           	rst 	: in  STD_LOGIC;
				R 		: out STD_LOGIC_VECTOR (2 downto 0);
				G 		: out STD_LOGIC_VECTOR (2 downto 0);
				B 		: out STD_LOGIC_VECTOR (2 downto 0);
				Hs 	: out STD_LOGIC ;
				Vs 	: out STD_LOGIC ;
				data : in STD_LOGIC_VECTOR(7 downto 0):= x"00";
				data_ready : in STD_LOGIC);
	end component;

    --control unit
    component control 
        Port (  rst             : in  std_logic;
                request_from_id : in std_logic;
                request_from_mmu: in std_logic;
                request_from_fd : in std_logic;
                stall_for_pc    : out std_logic;
                stall_for_if    : out std_logic_vector(1 downto 0);
                stall_for_id    : out std_logic);
    end component;

    signal stall_for_pc : std_logic;
    signal stall_for_if : std_logic_vector(1 downto 0);
    signal stall_for_id : std_logic;

    --pc module    
    component pc_reg
        Port ( clk          : in std_logic;
               rst          : in std_logic;
               stall        : in std_logic;
					pc_stall		 : in std_logic;
               branch       : in std_logic;
               branch_addr  : in std_logic_vector(15 downto 0);
               mode : in std_logic;
               --signal for MMU
               pc           : out std_logic_vector(15 downto 0);
               en           : out std_logic); 
    end component;    

    signal pc : std_logic_vector(15 downto 0);    
    signal en : std_logic;

    --MMU for memory access of instruction and data 
    component mmu
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
					mode			: in std_logic;
				  --flash
				  flash_clk : in  STD_LOGIC;
				  flash_data_to_ram : in  STD_LOGIC_VECTOR(15 downto 0);
				  flash_addr_to_ram : in  STD_LOGIC_VECTOR(17 downto 0);
				  flash_cpu_en : in	STD_LOGIC);
    end component;

    signal inst : std_logic_vector(15 downto 0);
    signal data : std_logic_vector(15 downto 0);
    signal mmu_stall_request : std_logic;
    signal rdn2, wrn2        : STD_LOGIC;
	 signal flash_data_to_ram : STD_LOGIC_VECTOR(15 downto 0);
	 signal flash_addr_to_ram : STD_LOGIC_VECTOR(17 downto 0);
	 component flash
		 Port ( flash_clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  flash_data : inout  STD_LOGIC_VECTOR(15 downto 0);
				  flash_addr_out : out  STD_LOGIC_VECTOR(22 downto 0);
				  flash_byte :out	STD_LOGIC;
				  flash_vpen :out	STD_LOGIC;
				  flash_ce : out	STD_LOGIC;
				  flash_rp :out	STD_LOGIC;
				  flash_we : out	STD_LOGIC;
				  flash_oe : out	STD_LOGIC;
				  flash_data_to_ram : out  STD_LOGIC_VECTOR(15 downto 0);
				  flash_addr_to_ram : out  STD_LOGIC_VECTOR(17 downto 0);
				  flash_cpu_en : out	STD_LOGIC);
	end component;
    --if/id stage register    
    component if_id 
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --signal from control
               stall  : in std_logic_vector(1 downto 0);
               --signal from if stage           
               if_pc  : in std_logic_vector(15 downto 0);
               if_inst: in std_logic_vector(15 downto 0);
               --signal for id stage           
               id_pc  : out std_logic_vector(15 downto 0);
               id_inst: out std_logic_vector(15 downto 0));
    end component;

    signal id_pc   : std_logic_vector(15 downto 0);
    signal id_inst : std_logic_vector(15 downto 0);

    --instruction decode
    component id
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
          ex_load_addr: in std_logic_vector(3 downto 0);
			 pc_out : out std_logic_vector(15 downto 0));     
    end component;

    signal reg1_addr, reg2_addr, wreg_addr : std_logic_vector(2 downto 0);
    signal sreg_addr, wsreg_addr : std_logic_vector(1 downto 0);
    signal reg1_en, reg2_en, sreg_en, wreg_en, wsreg_en, branch, id_mem_read_en, id_mem_write_en, id_stall_request: std_logic;    
    signal alu_sel   : std_logic_vector(2 downto 0);             
    signal operand1, operand2, id_mem_write_data, branch_addr : std_logic_vector(15 downto 0);

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
               reg1_en   : in std_logic; 
               reg2_addr : in std_logic_vector(2 downto 0);
               reg2_en   : in std_logic;
               reg1_data : out std_logic_vector(15 downto 0);
               reg2_data : out std_logic_vector(15 downto 0);
               --timeout
               mode : in std_logic);
    end component;

    signal reg1_data, reg2_data : std_logic_vector(15 downto 0);

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
               reg_en   : in std_logic;           
               reg_data : out std_logic_vector(15 downto 0);
               --timeout
               mode  : in std_logic);       
    end component;

    signal sreg_data : std_logic_vector(15 downto 0);

    --ID/EX stage register
    component id_ex 
        Port ( clk   : in  std_logic;
               rst   : in  std_logic;
               stall : in std_logic;
               --signal from id stage                      
               id_alusel    : in std_logic_vector(2 downto 0);
               id_operand1  : in std_logic_vector(15 downto 0);
               id_operand2  : in std_logic_vector(15 downto 0);
               id_wreg_addr : in std_logic_vector(2 downto 0);           
               id_wreg_en   : in std_logic;
               id_wsreg_addr: in std_logic_vector(1 downto 0);           
               id_wsreg_en  : in std_logic;
               id_mem_read_en   : in std_logic;
               id_mem_write_en  : in std_logic;
               id_mem_write_data: in std_logic_vector(15 downto 0);    
               --signal for ex stage                      
               ex_alusel    : out std_logic_vector(2 downto 0);
               ex_operand1  : out std_logic_vector(15 downto 0);
               ex_operand2  : out std_logic_vector(15 downto 0);
               ex_wreg_addr : out std_logic_vector(2 downto 0);           
               ex_wreg_en   : out std_logic;
               ex_wsreg_addr: out std_logic_vector(1 downto 0);           
               ex_wsreg_en  : out std_logic;
               ex_mem_read_en   : out std_logic;
               ex_mem_write_en  : out std_logic;
               ex_mem_write_data: out std_logic_vector(15 downto 0));           
    end component;
        
    signal ex_alusel  : std_logic_vector(2 downto 0);
    signal ex_operand1, ex_operand2, ex_mem_write_data: std_logic_vector(15 downto 0);    
    signal ex_wreg_addr : std_logic_vector(2 downto 0);           
    signal ex_wreg_en, ex_wsreg_en, ex_mem_read_en, ex_mem_write_en: std_logic;
    signal ex_wsreg_addr : std_logic_vector(1 downto 0);   

    --EX stage (alu)
    component ex
        Port ( rst : in  std_logic;
           --signal from id stage                      
           alusel  : in std_logic_vector(2 downto 0);
           operand1: in std_logic_vector(15 downto 0);
           operand2: in std_logic_vector(15 downto 0);
           wreg_addr : in std_logic_vector(2 downto 0);          
           wreg_en   : in std_logic;
           wsreg_addr : in std_logic_vector(1 downto 0);          
           wsreg_en   : in std_logic;
           mem_read_en   : in std_logic;
           mem_write_en  : in std_logic;
           mem_write_data: in std_logic_vector(15 downto 0);  
           --signal for mem stage          
           wreg_data_out : out std_logic_vector(15 downto 0);  --also forwarding
           wreg_addr_out : inout std_logic_vector(2 downto 0);   --also forwarding        
           wreg_en_out   : inout std_logic;                      --also forwarding
           wsreg_data_out : out std_logic_vector(15 downto 0); --also forwarding
           wsreg_addr_out : out std_logic_vector(1 downto 0);  --also forwarding         
           wsreg_en_out   : out std_logic;                     --also forwarding 
           mem_read_en_out   : inout std_logic;
           mem_read_addr_out : out std_logic_vector(15 downto 0);
           mem_write_en_out  : out std_logic;
           mem_write_addr_out: out std_logic_vector(15 downto 0);
           mem_write_data_out: out std_logic_vector(15 downto 0);
           --load conflict forwarding
           is_ex_load        : out std_logic;    
           ex_load_addr      : out std_logic_vector(3 downto 0));
    end component;
    
    signal wreg_data_out, wsreg_data_out, mem_read_addr_out, mem_write_addr_out, mem_write_data_out: std_logic_vector(15 downto 0);
    signal wreg_en_out, wsreg_en_out, mem_read_en_out, mem_write_en_out, is_ex_load : std_logic;  
    signal wreg_addr_out : std_logic_vector(2 downto 0);
	 signal ex_load_addr : std_logic_vector(3 downto 0);
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
               ex_mem_read_en    : in std_logic;
               ex_mem_read_addr  : in std_logic_vector(15 downto 0);
               ex_mem_write_en   : in std_logic;
               ex_mem_write_addr : in std_logic_vector(15 downto 0);
               ex_mem_write_data : in std_logic_vector(15 downto 0);
               --signal for mem stage           
               mem_wreg_data : out std_logic_vector(15 downto 0);         
               mem_wreg_addr : out std_logic_vector(2 downto 0);          
               mem_wreg_en   : out std_logic;
               mem_wsreg_data: out std_logic_vector(15 downto 0);         
               mem_wsreg_addr: out std_logic_vector(1 downto 0);           
               mem_wsreg_en  : out std_logic;
               mem_read_en_out   : out std_logic;
               mem_read_addr_out : out std_logic_vector(15 downto 0);
               mem_write_en_out  : out std_logic;
               mem_write_addr_out: out std_logic_vector(15 downto 0);
               mem_write_data_out: out std_logic_vector(15 downto 0));
    end component;

    signal mem_wreg_data, mem_wsreg_data, mem_read_addr, mem_write_addr, mem_write_data: std_logic_vector(15 downto 0);         
    signal mem_wreg_en, mem_wsreg_en, mem_read_en, mem_write_en : std_logic;
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
               mem_read_en    : in std_logic;
               mem_read_addr  : in std_logic_vector(15 downto 0);
               mem_write_en   : in std_logic;
               mem_write_addr : in std_logic_vector(15 downto 0);
               mem_write_data : in std_logic_vector(15 downto 0);
               --signal from MMU
               RamData        : in std_logic_vector(15 downto 0);                      
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
	--test
		--process_mode <= mode;
	 process(fclk)
	 begin
		if(sel_mode = '0')then
			L <= out_pc_signal;
		else
			L(3 downto 0) <= time_slice_signal;
			L(6 downto 4) <= flush_count_signal;
			L(7) <= mode;
			L(15) <= pc_stall_s;
			L(14 downto 8) <= (others=>'0');
		end if;
	 end process;
	 
	 ps2_unit : ps2 port map (fclk,rst,ps2clk,ps2data,data_e,data_ready_e);
	 vga_unit : vga port map (fclk,rst,R,G,B,Hs,Vs,data_e,data_ready_e);
	 
    uart_unit : uart port map(rst, uart_clk, rxd, rdn2, wrn2,
                              uart_data_in, uart_data_out, data_ready2, parity_error,
                              framing_error, tbre2, tsre2, sdo);

	fd_clk_unit: fd_clk port map (rst, fclk, clk, mode, fd_stall_request,pc_stall_s,
									time_slice_signal,flush_count_signal,hclk,clk_mode,uart_clk,
									cpu_en,flash_clk);

    control_unit: control port map (rst, id_stall_request, mmu_stall_request, fd_stall_request, 
                                    stall_for_pc, stall_for_if, stall_for_id);

    pc_unit : pc_reg port map (clk, rst, stall_for_pc, pc_stall_s,branch, branch_addr,
                               mode, pc, en);
          
    memory_unit : mmu port map (clk, rst, pc, en, mem_read_en, mem_read_addr, 
                                mem_write_en, mem_write_addr, mem_write_data,
                                inst, data, mmu_stall_request,
                                Ram1Addr, Ram1Data, Ram1OE, Ram1WE, Ram1EN,
                                Ram2Addr, Ram2Data, Ram2OE, Ram2WE, Ram2EN,
                                data_ready, tbre, tsre, rdn, wrn, 
                                parity_error, framing_error, data_ready2,
                                tbre2, tsre2, rdn2, wrn2, uart_data_out, uart_data_in,mode,
										  flash_clk,flash_data_to_ram,flash_addr_to_ram,cpu_en);
										  
	 flash_unit : flash port map (flash_clk,rst,flash_data,flash_addr_out,
											flash_byte,flash_vpen,flash_ce,flash_rp,flash_we,flash_oe,
											flash_data_to_ram,flash_addr_to_ram,cpu_en);

    if_id_register : if_id port map (clk, rst, stall_for_if, pc, inst, id_pc, id_inst);

    id_unit : id port map  (rst, id_pc, id_inst, reg1_data, reg2_data, sreg_data, 
                            reg1_addr, reg1_en, reg2_addr, reg2_en, sreg_addr, sreg_en,
                            alu_sel, operand1, operand2, wreg_addr, wreg_en, wsreg_addr, wsreg_en,
                            branch, branch_addr, id_mem_read_en, id_mem_write_en, id_mem_write_data,
                            id_stall_request, wreg_en_out, wreg_addr_out, wreg_data_out,
                            wsreg_en_out, wsreg_addr_out, wsreg_data_out, 
                            mem_wreg_en_out, mem_wreg_addr_out, mem_wreg_data_out,
                            mem_wsreg_en_out, mem_wsreg_addr_out, mem_wsreg_data_out,
                            is_ex_load, ex_load_addr,out_pc_signal);
    g_regfile_unit : g_regfile port map(clk, rst, wb_wreg_addr, wb_wreg_data, wb_wreg_en, 
                                        reg1_addr, reg1_en, reg2_addr, reg2_en, 
                                        reg1_data, reg2_data, mode);

    s_regfile_unit : s_regfile port map(clk, rst, wb_wsreg_addr, wb_wsreg_data, wb_wsreg_en,
                                        sreg_addr, sreg_en, sreg_data, mode);

    id_ex_register : id_ex port map(clk, rst, stall_for_id, alu_sel, operand1, operand2,
                                    wreg_addr, wreg_en, wsreg_addr, wsreg_en,
                                    id_mem_read_en, id_mem_write_en, id_mem_write_data,
                                    ex_alusel, ex_operand1, ex_operand2,
                                    ex_wreg_addr, ex_wreg_en, ex_wsreg_addr, ex_wsreg_en,
                                    ex_mem_read_en, ex_mem_write_en, ex_mem_write_data);

    ex_unit : ex port map(rst, ex_alusel, ex_operand1, ex_operand2,
                          ex_wreg_addr, ex_wreg_en, ex_wsreg_addr, ex_wsreg_en,
                          ex_mem_read_en, ex_mem_write_en, ex_mem_write_data,
                          wreg_data_out, wreg_addr_out, wreg_en_out,
                          wsreg_data_out, wsreg_addr_out, wsreg_en_out,
                          mem_read_en_out, mem_read_addr_out,
                          mem_write_en_out, mem_write_addr_out, mem_write_data_out,
                          is_ex_load, ex_load_addr);

    ex_mem_register : ex_mem port map(clk, rst, wreg_data_out, wreg_addr_out, wreg_en_out,
                                      wsreg_data_out, wsreg_addr_out, wsreg_en_out,
                                      mem_read_en_out, mem_read_addr_out,
                                      mem_write_en_out, mem_write_addr_out, mem_write_data_out,
                                      mem_wreg_data, mem_wreg_addr, mem_wreg_en,
                                      mem_wsreg_data, mem_wsreg_addr, mem_wsreg_en,
                                      mem_read_en, mem_read_addr, mem_write_en, mem_write_addr, mem_write_data);

    mem_unit : mem port map(rst, mem_wreg_data, mem_wreg_addr, mem_wreg_en,
                            mem_wsreg_data, mem_wsreg_addr, mem_wsreg_en,
                            mem_read_en, mem_read_addr, mem_write_en, mem_write_addr, mem_write_data,
                            data,
                            mem_wreg_data_out, mem_wreg_addr_out, mem_wreg_en_out,
                            mem_wsreg_data_out, mem_wsreg_addr_out, mem_wsreg_en_out);

    mem_wb_register : mem_wb port map(clk, rst, mem_wreg_data_out, mem_wreg_addr_out, mem_wreg_en_out,
                                      mem_wsreg_data_out, mem_wsreg_addr_out, mem_wsreg_en_out,
                                      wb_wreg_data, wb_wreg_addr, wb_wreg_en,
                                      wb_wsreg_data, wb_wsreg_addr, wb_wsreg_en);
end Behavioral;

