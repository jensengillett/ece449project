
-- IF/ID Latch between Instruction Fetch and Instruction Decode

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity if_id_latch is
    Port (
        clk: in std_logic;
        if_in_instruction : in std_logic_vector(15 downto 0);
        if_out_instruction : out std_logic_vector(15 downto 0);
        if_in_wb_register : in std_logic_vector(2 downto 0);
        if_out_wb_register : out std_logic_vector(2 downto 0);
        if_in_in_port : in std_logic_vector(15 downto 0);
        if_out_in_port : out std_logic_vector(15 downto 0);
        if_in_in_enable : in std_logic;
        if_out_in_enable: out std_logic
    );
end if_id_latch;

architecture Behavioral of if_id_latch is
begin
    process(clk) begin
        if(falling_edge(clk)) then
            if_out_instruction <= if_in_instruction;
            if_out_wb_register <= if_in_wb_register;
            if_out_in_port <= if_in_in_port;
            if_out_in_enable <= if_in_in_enable;
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
        id_in_alu_op: in std_logic_vector(2 downto 0);
        id_out_alu_op: out std_logic_vector(2 downto 0);
        id_in_mem_op: in std_logic_vector(1 downto 0);
        id_out_mem_op: out std_logic_vector(1 downto 0);
        id_in_wb_op: in std_logic;
        id_out_wb_op: out std_logic;
        id_in_cl_value: in std_logic_vector(3 downto 0);
        id_out_cl_value: out std_logic_vector(3 downto 0);
        id_in_wb_register : in std_logic_vector(2 downto 0);
        id_out_wb_register : out std_logic_vector(2 downto 0);
        id_in_branch_op : in std_logic_vector(7 downto 0);   
        id_out_branch_op : out std_logic_vector(7 downto 0); 
        id_in_branch_displacement : in std_logic_vector(8 downto 0); 
        id_out_branch_displacement : out std_logic_vector(8 downto 0)
    );
end id_ex_latch;

architecture Behavioral of id_ex_latch is
begin
    process(clk) begin
        if(falling_edge(clk)) then
            id_out_rd_data_1 <= id_in_rd_data_1;
            id_out_rd_data_2 <= id_in_rd_data_2;
            id_out_alu_op <= id_in_alu_op;
            id_out_cl_value <= id_in_cl_value;
            id_out_branch_op <= id_in_branch_op;
            id_out_branch_displacement <= id_in_branch_displacement;
            id_out_mem_op <= id_in_mem_op;
            id_out_wb_op <= id_in_wb_op;
            id_out_wb_register <= id_in_wb_register;
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
        ex_in_mem_op: in std_logic_vector(1 downto 0);
        ex_out_mem_op: out std_logic_vector(1 downto 0);
        ex_in_wb_op: in std_logic;
        ex_out_wb_op: out std_logic;
        ex_in_wb_register : in std_logic_vector(2 downto 0);
        ex_out_wb_register : out std_logic_vector(2 downto 0)
    );
end ex_mem_latch;

architecture Behavioral of ex_mem_latch is
begin
    process(clk) begin
        if(falling_edge(clk)) then
            ex_out_alu_result <= ex_in_alu_result;
            ex_out_mem_op <= ex_in_mem_op;
            ex_out_wb_op <= ex_in_wb_op;
            ex_out_wb_register <= ex_in_wb_register;
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
        mem_in_wb_op: in std_logic;
        mem_out_wb_op: out std_logic;
        mem_in_wb_register : in std_logic_vector(2 downto 0);
        mem_out_wb_register : out std_logic_vector(2 downto 0)
    );
end mem_wb_latch;

architecture Behavioral of mem_wb_latch is
begin
    process(clk) begin
        if(falling_edge(clk)) then
            mem_out_alu_result <= mem_in_alu_result;
            mem_out_wb_op <= mem_in_wb_op;
            mem_out_wb_register <= mem_in_wb_register;
        end if;
    end process;
end Behavioral;