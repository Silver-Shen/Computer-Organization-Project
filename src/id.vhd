----------------------------------------------------------------------------------
-- Engineer: Zheyan Shen
-- Project Name: Computer Organization Final Project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id is  --译码阶段
    Port (rst : in  std_logic;
          --来自IF/ID阶段寄存器传来的信号
          pc  : in std_logic_vector(15 downto 0);
          inst : in std_logic_vector(15 downto 0);
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
          alu_op : out std_logic_vector(4 downto 0);
          alu_sel: out std_logic_vector(2 downto 0);
          --传给alu的两个操作数
          operand1  : out std_logic_vector(15 downto 0);
          operand2  : out std_logic_vector(15 downto 0);
          --传入下一阶段的写回寄存器信息
          wreg_addr : out std_logic_vector(2 downto 0);
          wreg_sel  : out std_logic;  --写入的类型，通用寄存器还是特殊寄存器
          wrge_en   : out std_logic); --是否允许写入
end id;

architecture Behavioral of id is    
    signal inst_header, inst_tail : std_logic_vector(4 downto 0);
    signal regx, regy  : std_logic_vector(2 downto 0);
    --signal imm : std_logic_vector(15 downto 0);
    --signal instValid : std_logic := '0';
begin
    Pre_Decode: --预处理阶段，先将指令分段
    process (inst)
    begin
        inst_header <= inst(15 downto 11);
        regx <= inst(10 downto 8);
        regy <= inst(7 downto 5);
        inst_tail <= inst(4 downto 0);
    end process;

    Decode: --译码阶段
    process (rst, inst_header, inst_tail, regx, regy, reg1_data, reg2_data, sreg_data)
    begin
        if (rst = '0' or inst_header = "00001") then  --复位或者NOP指令，控制信号全部清空
            alu_op <= "00001";
            alu_sel <= "000";
            reg1_en <= '1';
            reg2_en <= '1';
            reg1_addr <= "00000";
            reg2_addr <= "00000";
            sreg_en <= '1';
            sreg_addr <= "00";
            operand1 <= x"0000";
            operand2 <= x"0000";
            wreg_en <= '1';
            wreg_sel <= '0';
            wreg_addr <= "000";
        else 
            alu_op <= inst_header;
            case inst_header is
                when "01111" =>     --move 
                    alu_sel <= "000";
                    reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regy;
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= reg1_data;
                    operand2 <= x"0000";
                    wreg_en <= '0';
                    wreg_sel <= '0';  --表示写通用寄存器
                    wreg_addr <= regx;
                when "01001" =>     --addiu
                    alu_sel <= "000";
                    reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regx;
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= reg1_data;
                    operand2 <= to_std_logic_vector(resize(signed(regy&inst_tail), 16));
                    wreg_en <= '0';
                    wreg_sel <= '0';  
                    wreg_addr <= regx;
                when "01000" =>     --addiu3
                    alu_sel <= "000";
                    reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regx;
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= reg1_data;
                    operand2 <= to_std_logic_vector(resize(signed(inst_tail(3 downto 0)), 16));
                    wreg_en <= '0';
                    wreg_sel <= '0'; 
                    wreg_addr <= regy;
                when "01110" =>     --cmpi
                    alu_sel <= "000";
                    reg1_en <= '0';
                    reg2_en <= '1';
                    reg1_addr <= regx;
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= reg1_data;
                    operand2 <= to_std_logic_vector(resize(signed(regy&inst_tail), 16));
                    wreg_en <= '0';
                    wreg_sel <= '1';  --写特殊寄存器 
                    wreg_addr <= "000";  --T寄存器
                when "01101" =>     --li
                    alu_sel <= "000";
                    reg1_en <= '1';
                    reg2_en <= '1';
                    reg1_addr <= "00000";
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= x"0000";
                    operand2 <= x"00" & regy & inst_tail;
                    wreg_en <= '0';
                    wreg_sel <= '0'; 
                    wreg_addr <= regx; 
                when "11100" =>     --addu
                    alu_sel <= "000";
                    reg1_en <= '0';
                    reg2_en <= '0';
                    reg1_addr <= regx;
                    reg2_addr <= regy;
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= reg1_data;
                    operand2 <= reg2_data;
                    wreg_en <= '0';
                    wreg_sel <= '0'; 
                    wreg_addr <= inst_tail(4 downto 2);
                when others =>
                    alu_op <= "00001";
                    alu_sel <= "000";
                    reg1_en <= '1';
                    reg2_en <= '1';
                    reg1_addr <= "00000";
                    reg2_addr <= "00000";
                    sreg_en <= '1';
                    sreg_addr <= "00";
                    operand1 <= x"0000";
                    operand2 <= x"0000";
                    wreg_en <= '1';
                    wreg_sel <= '0';
                    wreg_addr <= "000";
            end case;            
        end if;
    end process;
end Behavioral;

