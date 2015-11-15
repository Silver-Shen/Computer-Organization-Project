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

    --译码模块
    component id
        Port (rst : in  std_logic;
              --来自IF/ID阶段寄存器传来的信号
              pc  : in std_logic_vector(15 downto 0);
              inst: in std_logic_vector(15 downto 0);
              --来自通用寄存器堆的读取结果
              reg1_data : in std_logic_vector(15 downto 0);
              reg2_data : in std_logic_vector(15 downto 0);
              --来自特殊寄存器堆的读取结果
              sreg_data : in std_logic_vector(15 downto 0);
              --访问通用寄存器堆的读信号
              reg1_addr : out std_logic_vector(2 downto 0);
              reg1_en   : out std_logic;
              reg2_addr : out std_logic_vector(2 downto 0);
              reg2_en   : out std_logic;
              --访问特殊寄存器堆的读信号
              sreg_addr : out std_logic_vector(1 downto 0);
              sreg_en   : out std_logic;
              --传给alu的运算信息
              alu_op    : out std_logic_vector(4 downto 0);
              alu_sel   : out std_logic_vector(2 downto 0);
              --传给alu的两个操作数
              operand1  : out std_logic_vector(15 downto 0);
              operand2  : out std_logic_vector(15 downto 0);
              --传入下一阶段的写回寄存器信息
              wreg_addr : out std_logic_vector(2 downto 0);  --通用寄存器          
              wreg_en   : out std_logic;  --是否允许写入
              wsreg_addr: out std_logic_vector(1 downto 0);  --特殊寄存器
              wsreg_en  : out std_logic);
    end component;

    signal reg1_addr, reg2_addr, wreg_addr : std_logic_vector(2 downto 0);
    signal sreg_addr, wsreg_addr : std_logic_vector(1 downto 0);
    signal reg1_en, reg2_en, sreg_en, wreg_en, wsreg_en : std_logic;
    signal alu_op    : std_logic_vector(4 downto 0);
    signal alu_sel   : std_logic_vector(2 downto 0);             
    signal operand1, operand2  : std_logic_vector(15 downto 0);

    --通用寄存器堆
    component g_regfile
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --写入寄存器的信号，同步操作
               w_addr  : in std_logic_vector(2 downto 0);
               w_data  : in std_logic_vector(15 downto 0);
               w_en    : in std_logic;
               --读取寄存器的信号，异步操作
               reg1_addr : in std_logic_vector(2 downto 0);
               reg1_en : in std_logic; 
               reg2_addr : in std_logic_vector(2 downto 0);
               reg2_en : in std_logic;
               reg1_data : out std_logic_vector(15 downto 0);
               reg2_data : out std_logic_vector(15 downto 0));
    end component;

    signal reg1_data,reg2_data : std_logic_vector(15 downto 0);

    --特殊寄存器堆
    component s_regfile
        Port ( clk : in  std_logic;
               rst : in  std_logic;
               --写入寄存器的信号，同步操作
               w_addr  : in std_logic_vector(1 downto 0);
               w_data  : in std_logic_vector(15 downto 0);
               w_en    : in std_logic;
               --读取寄存器的信号，异步操作
               reg_addr : in std_logic_vector(1 downto 0);
               reg_en : in std_logic;           
               reg_data : out std_logic_vector(15 downto 0));     
    end component;

    signal sreg_data : std_logic_vector(15 downto 0);

    
begin
    pc_unit : pc_reg port map (clk, rst, pc, inst_en);
    new_inst_addr <= pc;  --指令寄存器接收pc模块的输出
    if_id_register : if_id port map (clk, rst, pc, inst, id_pc, id_inst);
    id_unit : id port map  (rst, id_pc, id_inst, reg1_data, reg2_data, sreg_data, 
                            reg1_addr, reg1_en, reg2_addr, reg2_en, sreg_addr, sreg_en,
                            alu_op, alu_sel, operand1, operand2, 
                            wreg_addr, wreg_en, wsreg_addr, wsreg_en);
    g_regfile_unit : g_regfile port map(clk, rst, , , , 
                                        reg1_addr, reg1_en, reg2_addr, reg2_en, 
                                        reg1_data, reg2_data);
    s_regfile_unit : s_regfile port map(clk, rst, , , ,
                                        sreg_addr, sreg_en, sreg_data);

end Behavioral;

