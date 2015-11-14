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

entity g_regfile is
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
end g_regfile;

architecture Behavioral of g_regfile is
    --通用寄存器堆是一个8*16的二维数组，初始化为0
    type reg_array is array(0 to 7) of std_logic_vector(15 downto 0); 
    signal regfile : reg_array := (x"0000",x"0000",x"0000",x"0000",
                                   x"0000",x"0000",x"0000",x"0000");
begin
    Write_Back: --回写进程，与时钟信号同步
    process (clk, rst)
    begin       
        if (clk'event and clk = '1') then
            if (rst /= '0' and w_en = '0') then
                regfile[CONV_INTEGER(w_addr)] <= w_data;
            end if;
        end if;         
    end process;

    Read_Reg1: --读寄存器1进程，解决了ID和WB阶段的数据冲突问题，即相隔两条指令的RAW冲突
    process(rst, reg1_addr, reg1_en, w_addr, w_en, w_data)
    begin
        if (rst = '0') then
            reg1_data <= x"0000";
        elsif (reg1_addr = w_addr and reg1_en = '0' and w_en = '0') then
            reg1_data <= w_data;
        elsif (reg1_en = '0') then
            reg1_data <= regfile[CONV_INTEGER(reg1_addr)];
        else
            reg1_data <= x"0000";
        end if; 
    end process;

    Read_Reg2: --读寄存器2进程，解决了ID和WB阶段的数据冲突问题，即相隔两条指令的RAW冲突
    process(rst, reg2_addr, reg2_en, w_addr, w_en, w_data)
    begin
        if (rst = '0') then
            reg2_data <= x"0000";
        elsif (reg2_addr = w_addr and reg2_en = '0' and w_en = '0') then
            reg2_data <= w_data;
        elsif (reg2_en = '0') then
            reg2_data <= regfile[CONV_INTEGER(reg2_addr)];
        else
            reg2_data <= x"0000";
        end if; 
    end process;
end Behavioral;

