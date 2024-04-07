
-- IF/ID Latch between Instruction Fetch and Instruction Decode

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity if_id_latch is
    Port (
        clk: in std_logic;
        if_in_instruction : in std_logic_vector(15 downto 0);
        if_out_instruction : out std_logic_vector(15 downto 0);
        if_in_in_port : in std_logic_vector(15 downto 0);
        if_out_in_port : out std_logic_vector(15 downto 0);
        if_in_in_port_enable : in std_logic;
        if_out_in_port_enable: out std_logic;
        if_in_pc : in std_logic_vector(15 downto 0);
        if_out_pc: out std_logic_vector(15 downto 0);
        if_in_flush_pipeline: in std_logic;
        if_enable_latch: in std_logic
    );
end if_id_latch;

architecture Behavioral of if_id_latch is

begin
    process(clk)
    variable temp_instruction : std_logic_vector(15 downto 0);
    begin
        temp_instruction := if_in_instruction;
    
        if(rising_edge(clk) and if_enable_latch = '1') then
        
            if (if_in_flush_pipeline = '1') then
                temp_instruction := (others => '0');
            else 
                temp_instruction := if_in_instruction;
            end if;        
    
        elsif(falling_edge(clk) and if_enable_latch = '1') then
            if_out_instruction <= temp_instruction;
            if_out_in_port <= if_in_in_port;
            if_out_in_port_enable <= if_in_in_port_enable;
            if_out_pc <= if_in_pc;
        end if;
    end process;
end Behavioral;

-- ID/EX Latch between Instruction Decode and Execute

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity id_ex_latch is
    Port(
        clk: in std_logic;
        id_in_rd_data_1: in std_logic_vector(15 downto 0);
        id_out_rd_data_1: out std_logic_vector(15 downto 0);
        id_in_rd_data_2: in std_logic_vector(15 downto 0);
        id_out_rd_data_2: out std_logic_vector(15 downto 0);
        id_in_rd_data_3: in std_logic_vector(15 downto 0);
        id_out_rd_data_3: out std_logic_vector(15 downto 0);
        id_in_alu_op: in std_logic_vector(2 downto 0);
        id_out_alu_op: out std_logic_vector(2 downto 0);
        id_in_mem_op: in std_logic_vector(2 downto 0);
        id_out_mem_op: out std_logic_vector(2 downto 0);
        id_in_wb_op: in std_logic;
        id_out_wb_op: out std_logic;
        id_in_cl_value: in std_logic_vector(3 downto 0);
        id_out_cl_value: out std_logic_vector(3 downto 0);
        id_in_wb_register : in std_logic_vector(2 downto 0);
        id_out_wb_register : out std_logic_vector(2 downto 0);
        id_in_branch_op : in std_logic_vector(7 downto 0);   
        id_out_branch_op : out std_logic_vector(7 downto 0); 
        id_in_branch_displacement : in std_logic_vector(8 downto 0); 
        id_out_branch_displacement : out std_logic_vector(8 downto 0);
        id_in_pc : in std_logic_vector(15 downto 0);
        id_out_pc : out std_logic_vector(15 downto 0);
        id_in_m1: in std_logic;
        id_out_m1: out std_logic;
        id_in_imm: in std_logic_vector(7 downto 0);
        id_out_imm: out std_logic_vector(7 downto 0);
        id_enable_latch: in std_logic
    );
end id_ex_latch;

architecture Behavioral of id_ex_latch is
begin
    process(clk) begin
        if(falling_edge(clk) and id_enable_latch = '1') then
            id_out_rd_data_1 <= id_in_rd_data_1;
            id_out_rd_data_2 <= id_in_rd_data_2;
            id_out_rd_data_3 <= id_in_rd_data_3;
            id_out_alu_op <= id_in_alu_op;
            id_out_cl_value <= id_in_cl_value;
            id_out_branch_op <= id_in_branch_op;
            id_out_branch_displacement <= id_in_branch_displacement;
            id_out_mem_op <= id_in_mem_op;
            id_out_wb_op <= id_in_wb_op;
            id_out_wb_register <= id_in_wb_register;
            id_out_pc <= id_in_pc;
            id_out_m1 <= id_in_m1;
            id_out_imm <= id_in_imm;
        end if;
    end process;
end Behavioral;

-- EX/MEM latch between Execute and Memory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ex_mem_latch is
    Port(
        clk: in std_logic;
        ex_in_alu_result: in std_logic_vector(15 downto 0);
        ex_out_alu_result: out std_logic_vector(15 downto 0);
        ex_in_mem_op: in std_logic_vector(2 downto 0);
        ex_out_mem_op: out std_logic_vector(2 downto 0);
        ex_in_wb_op: in std_logic;
        ex_out_wb_op: out std_logic;
        ex_in_wb_register : in std_logic_vector(2 downto 0);
        ex_out_wb_register : out std_logic_vector(2 downto 0);
        ex_in_m1: in std_logic;
        ex_out_m1: out std_logic;
        ex_in_imm: in std_logic_vector(7 downto 0);
        ex_out_imm: out std_logic_vector(7 downto 0);
        ex_in_alu_result_enable: in std_logic;
        ex_out_alu_result_enable: out std_logic;
        ex_in_rd_data_1: in std_logic_vector(15 downto 0);
        ex_out_rd_data_1: out std_logic_vector(15 downto 0);
        ex_in_rd_data_2: in std_logic_vector(15 downto 0);
        ex_out_rd_data_2: out std_logic_vector(15 downto 0);
        ex_enable_latch: in std_logic
    );
end ex_mem_latch;

architecture Behavioral of ex_mem_latch is
begin
    process(clk) begin
        if(falling_edge(clk) and ex_enable_latch = '1') then
            ex_out_alu_result <= ex_in_alu_result;
            ex_out_mem_op <= ex_in_mem_op;
            ex_out_wb_op <= ex_in_wb_op;
            ex_out_wb_register <= ex_in_wb_register;
            ex_out_m1 <= ex_in_m1;
            ex_out_imm <= ex_in_imm;
            ex_out_alu_result_enable <= ex_in_alu_result_enable;
            ex_out_rd_data_1 <= ex_in_rd_data_1;
            ex_out_rd_data_2 <= ex_in_rd_data_2;
        end if;
    end process;
end Behavioral;

-- MEM/WB latch between Memory and Writeback

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_wb_latch is
    Port(
        clk: in std_logic;
        mem_in_alu_result: in std_logic_vector(15 downto 0);
        mem_out_alu_result: out std_logic_vector(15 downto 0);
        mem_in_alu_result_en: in std_logic;
        mem_out_alu_result_en: out std_logic;
        mem_in_mem_load: in std_logic_vector(15 downto 0);
        mem_out_mem_load: out std_logic_vector(15 downto 0);
        mem_in_mem_load_en: in std_logic;
        mem_out_mem_load_en: out std_logic;
        mem_in_wb_op: in std_logic;
        mem_out_wb_op: out std_logic;
        mem_in_wb_register : in std_logic_vector(2 downto 0);
        mem_out_wb_register : out std_logic_vector(2 downto 0);
        mem_enable_latch: in std_logic
    );
end mem_wb_latch;

architecture Behavioral of mem_wb_latch is
begin
    process(clk) begin
        if(falling_edge(clk) and mem_enable_latch = '1') then
            mem_out_alu_result <= mem_in_alu_result;
            mem_out_wb_op <= mem_in_wb_op;
            mem_out_wb_register <= mem_in_wb_register;
            mem_out_alu_result_en <= mem_in_alu_result_en;
            mem_out_mem_load <= mem_in_mem_load;
            mem_out_mem_load_en <= mem_in_mem_load_en;
        end if;
    end process;
end Behavioral;