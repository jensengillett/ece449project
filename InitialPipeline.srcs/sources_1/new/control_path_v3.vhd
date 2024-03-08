
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path_v3 is
    Port ( 
        out_pc : out std_logic_vector(15 downto 0);
        out_port: out std_logic_vector(15 downto 0);
        in_port: in std_logic_vector(15 downto 0);
        in_enable: in std_logic;
        loaded_value: in std_logic_vector(15 downto 0);
        in_clk: in std_logic;
        in_reg_reset: in std_logic
    );
end control_path_v3;

architecture Behavioral of control_path_v3 is

signal clk: STD_LOGIC;

component alu
    port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : out   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_enable: in  STD_LOGIC;
        branch_op: in STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: in STD_LOGIC_VECTOR(8 DOWNTO 0);
        out_pc: out STD_LOGIC_VECTOR(16 DOWNTO 0)
    );
end component;

signal alu_a, alu_b, alu_result, alu_extra_16_bits : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_cl : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal alu_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal alu_negative, alu_zero, alu_overflow : STD_LOGIC;
signal alu_branch_op: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal alu_branch_displacement: STD_LOGIC_VECTOR(8 DOWNTO 0);
signal alu_out_pc: STD_LOGIC_VECTOR(16 DOWNTO 0);

component register_file port(
        rst : in std_logic; clk: in std_logic; reg_enable: in std_logic;
        --read signals
        rd_index1: in std_logic_vector(2 downto 0); 
        rd_index2: in std_logic_vector(2 downto 0); 
        rd_data1: out std_logic_vector(15 downto 0); 
        rd_data2: out std_logic_vector(15 downto 0);
        --write signals
        wr_index: in std_logic_vector(2 downto 0); 
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic;
        out_enable: in std_logic;
        out_port: out std_logic_vector(15 downto 0);
        in_enable: in std_logic;
        in_index: in std_logic_vector(2 downto 0);
        in_port: in std_logic_vector(15 downto 0)
    );
end component;

signal reg_rst, reg_wr_enable, reg_out_enable, reg_in_enable: STD_LOGIC;
signal reg_rd_index1, reg_rd_index2, reg_wr_index, reg_in_index: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal reg_rd_data1, reg_rd_data2, reg_wr_data, reg_out_port, reg_in_port: STD_LOGIC_VECTOR(15 DOWNTO 0);

component decoder Port ( 
        clk: in STD_LOGIC;
        decode_enable : in STD_LOGIC;
        instruction: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_op: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_op: out STD_LOGIC_VECTOR(1 DOWNTO 0);
        wb_op: out STD_LOGIC;
        read_1_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_2_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        cl_value: out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- for SHL and SHR
        branch_op: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: out STD_LOGIC_VECTOR(8 DOWNTO 0);
        -- TEMP FOR PRELIMINARY DESIGN REVIEW
        in_in_port: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_in_port: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_in_enable: in STD_LOGIC;
        out_in_enable: out STD_LOGIC;
        in_write_data: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_port_index : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        out_enable: out STD_LOGIC
    );
end component;

signal decode_wb_op, decode_out_enable, decode_in_in_enable, decode_out_in_enable: STD_LOGIC;
signal decode_instruction, decode_in_in_port, decode_out_in_port, decode_in_write_data: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal decode_alu_op, decode_read_1_select, decode_read_2_select, decode_write_select, decode_in_port_index: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal decode_branch_op: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal decode_branch_displacement: STD_LOGIC_VECTOR(8 DOWNTO 0);
signal decode_cl_value: STD_LOGIC_VECTOR(3 DOWNTO 0);
signal decode_mem_op: STD_LOGIC_VECTOR(1 DOWNTO 0);

component pc_unit Port (
        clk: in STD_LOGIC;
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_reset: in STD_LOGIC;
        out_pc: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_enable: in STD_LOGIC
     );
end component;

signal in_pc, pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_pc_reset: STD_LOGIC;

component if_id_latch Port (
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
end component;

signal if_in_instruction, if_out_instruction, if_in_in_port, if_out_in_port: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal if_in_wb_register, if_out_wb_register: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal if_in_in_enable, if_out_in_enable: STD_LOGIC;

component id_ex_latch Port(
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
end component;

signal id_in_rd_data_1: std_logic_vector(15 downto 0);
signal id_out_rd_data_1: std_logic_vector(15 downto 0);
signal id_in_rd_data_2: std_logic_vector(15 downto 0);
signal id_out_rd_data_2: std_logic_vector(15 downto 0);
signal id_in_alu_op: std_logic_vector(2 downto 0);
signal id_out_alu_op: std_logic_vector(2 downto 0);
signal id_in_mem_op: std_logic_vector(1 downto 0);
signal id_out_mem_op: std_logic_vector(1 downto 0);
signal id_in_wb_op: std_logic;
signal id_out_wb_op: std_logic;
signal id_in_cl_value: std_logic_vector(3 downto 0);
signal id_out_cl_value: std_logic_vector(3 downto 0);
signal id_in_wb_register : std_logic_vector(2 downto 0);
signal id_out_wb_register : std_logic_vector(2 downto 0);
signal id_in_branch_op : std_logic_vector(7 downto 0);   
signal id_out_branch_op : std_logic_vector(7 downto 0); 
signal id_in_branch_displacement : std_logic_vector(8 downto 0); 
signal id_out_branch_displacement : std_logic_vector(8 downto 0);

component ex_mem_latch Port(
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
end component;

signal ex_in_alu_result: std_logic_vector(15 downto 0);
signal ex_out_alu_result: std_logic_vector(15 downto 0);
signal ex_in_mem_op: std_logic_vector(1 downto 0);
signal ex_out_mem_op: std_logic_vector(1 downto 0);
signal ex_in_wb_op: std_logic;
signal ex_out_wb_op: std_logic;
signal ex_in_wb_register : std_logic_vector(2 downto 0);
signal ex_out_wb_register : std_logic_vector(2 downto 0);

component mem_wb_latch Port(
        clk: in std_logic;
        mem_in_alu_result: in std_logic_vector(15 downto 0);
        mem_out_alu_result: out std_logic_vector(15 downto 0);
        mem_in_wb_op: in std_logic;
        mem_out_wb_op: out std_logic;
        mem_in_wb_register : in std_logic_vector(2 downto 0);
        mem_out_wb_register : out std_logic_vector(2 downto 0)
    );
end component;

signal mem_in_alu_result: std_logic_vector(15 downto 0);
signal mem_out_alu_result: std_logic_vector(15 downto 0);
signal mem_in_wb_op: std_logic;
signal mem_out_wb_op: std_logic;
signal mem_in_wb_register : std_logic_vector(2 downto 0);
signal mem_out_wb_register : std_logic_vector(2 downto 0);

-- Enable lines
signal en_decode: STD_LOGIC := '1';
signal en_regread: STD_LOGIC := '1';
signal en_alu: STD_LOGIC := '1';
signal en_regwrite: STD_LOGIC := '1';
signal pc_enable: STD_LOGIC := '1';


begin
    u_alu: alu port map(
        a => alu_a,
        b => alu_b,
        cl => alu_cl,
        f => alu_f,
        clk => clk,
        negative => alu_negative,
        zero => alu_zero,
        overflow => alu_overflow,
        result => alu_result,
        extra_16_bits => alu_extra_16_bits,
        alu_enable => en_alu,
        branch_op => alu_branch_op,
        branch_displacement => alu_branch_displacement,
        out_pc => alu_out_pc
    );
    
    u_register: register_file port map(
        rst => reg_rst,
        clk => clk,
        reg_enable => en_regread or en_regwrite,
        rd_index1 => reg_rd_index1,
        rd_index2 => reg_rd_index2,
        rd_data1 => reg_rd_data1,
        rd_data2 => reg_rd_data2,
        wr_index => reg_wr_index,
        wr_data => reg_wr_data,
        wr_enable => reg_wr_enable and en_regwrite,
        out_enable => reg_out_enable,
        out_port => reg_out_port,
        in_enable => reg_in_enable,
        in_index => reg_in_index,
        in_port => reg_in_port
    );
    
    u_decode: decoder port map(
        clk => clk,
        decode_enable => en_decode,
        instruction => decode_instruction,
        alu_op => decode_alu_op,
        mem_op => decode_mem_op,
        wb_op => decode_wb_op,
        read_1_select => decode_read_1_select,
        read_2_select => decode_read_2_select,
        write_select => decode_write_select,
        cl_value => decode_cl_value,
        branch_op => decode_branch_op,
        branch_displacement => decode_branch_displacement,
        
        
        -- TEMP FOR PRELIMINARY DESIGN REVIEW
        in_in_port => decode_in_in_port,
        out_in_port => decode_out_in_port,
        in_in_enable => decode_in_in_enable,
        out_in_enable => decode_out_in_enable,
        in_write_data => decode_in_write_data,
        in_port_index => decode_in_port_index,
        out_enable => decode_out_enable
    );

    
    u_pc: pc_unit port map(
        clk => clk,
        in_pc => in_pc,
        in_pc_reset => in_pc_reset,
        out_pc => pc,
        in_pc_enable => pc_enable
    );
    
    u_if_id : if_id_latch port map(
        clk => clk,
        if_in_instruction => if_in_instruction,
        if_out_instruction => if_out_instruction,
        if_in_wb_register => if_in_wb_register,
        if_out_wb_register => if_out_wb_register,
        if_in_in_port => if_in_in_port,
        if_out_in_port => if_out_in_port,
        if_in_in_enable => if_in_in_enable,
        if_out_in_enable => if_out_in_enable
    );
    
    u_id_ex : id_ex_latch port map(
        clk => clk,
        id_in_rd_data_1    => id_in_rd_data_1,     
        id_out_rd_data_1   => id_out_rd_data_1,    
        id_in_rd_data_2    => id_in_rd_data_2,     
        id_out_rd_data_2   => id_out_rd_data_2,    
        id_in_alu_op       => id_in_alu_op,        
        id_out_alu_op      => id_out_alu_op,       
        id_in_mem_op       => id_in_mem_op,        
        id_out_mem_op      => id_out_mem_op,       
        id_in_wb_op        => id_in_wb_op,         
        id_out_wb_op       => id_out_wb_op,        
        id_in_cl_value     => id_in_cl_value,      
        id_out_cl_value    => id_out_cl_value,     
        id_in_wb_register  => id_in_wb_register,   
        id_out_wb_register => id_out_wb_register,
        id_in_branch_op => id_in_branch_op,
        id_out_branch_op => id_out_branch_op,
        id_in_branch_displacement => id_in_branch_displacement,
        id_out_branch_displacement => id_out_branch_displacement  
    );
    
    u_ex_mem: ex_mem_latch port map(
        clk => clk,
        ex_in_alu_result    => ex_in_alu_result,  
        ex_out_alu_result   => ex_out_alu_result, 
        ex_in_mem_op        => ex_in_mem_op,      
        ex_out_mem_op       => ex_out_mem_op,     
        ex_in_wb_op         => ex_in_wb_op,       
        ex_out_wb_op        => ex_out_wb_op,      
        ex_in_wb_register   => ex_in_wb_register, 
        ex_out_wb_register  => ex_out_wb_register
    );
    
    u_mem_wb: mem_wb_latch port map(
        clk => clk,
        mem_in_alu_result   => mem_in_alu_result,   
        mem_out_alu_result  => mem_out_alu_result,  
        mem_in_wb_op        => mem_in_wb_op,        
        mem_out_wb_op       => mem_out_wb_op,       
        mem_in_wb_register  => mem_in_wb_register,  
        mem_out_wb_register => mem_out_wb_register 
    );
    
    -- Link PC and clk
    out_pc <= pc;
    clk <= in_clk;
    reg_rst <= in_reg_reset;
    
    -- Instruction fetch
    if_in_instruction <= loaded_value;
    if_in_in_port <= in_port;
    if_in_in_enable <= in_enable;
    
    -- Decode
    -- 'Inputs'
    decode_instruction <= if_out_instruction;
    reg_rd_index1 <= decode_read_1_select;
    reg_rd_index2 <= decode_read_2_select;
    reg_out_enable <= decode_out_enable;
    --reg_in_port <= if_out_in_port;
    decode_in_in_port <= if_out_in_port;
    reg_in_port <= decode_out_in_port;
    --reg_in_enable <= if_out_in_enable;
    decode_in_in_enable <= if_out_in_enable;
    reg_in_enable <= decode_out_in_enable;
    reg_in_index <= decode_in_port_index;
    
    -- 'Outputs'
    out_port <= reg_out_port;
    id_in_alu_op <= decode_alu_op;
    id_in_mem_op <= decode_mem_op;
    id_in_wb_op <= decode_wb_op;
    id_in_wb_register <= decode_write_select;
    id_in_cl_value <= decode_cl_value;
    id_in_branch_op <= decode_branch_op;
    id_in_branch_displacement <= decode_branch_displacement;
    
    
    id_in_rd_data_1 <= reg_rd_data1;
    id_in_rd_data_2 <= reg_rd_data2;
    
    -- Execute
    -- 'Inputs'
    alu_a <= id_out_rd_data_1;
    alu_b <= id_out_rd_data_2;
    alu_f <= id_out_alu_op;
    alu_cl <= id_out_cl_value;
    alu_branch_op <= id_out_branch_op;
    alu_branch_displacement <= id_out_branch_displacement;
    in_pc <= alu_out_pc; -- pass new PC value to PC unit, PC unit will determine whether to use it or not
    -- 'Outputs'
    ex_in_alu_result <= alu_result;
    -- Negative, Zero, Overflow, and extra_16_bits should be added later.
    ex_in_mem_op <= id_out_mem_op;
    ex_in_wb_op <= id_out_wb_op;
    ex_in_wb_register <= id_out_wb_register;
    
    -- Memory
    -- 'Inputs'
    -- Memory operator should be assigned to something here.
    -- 'Outputs'
    mem_in_alu_result <= ex_out_alu_result;
    mem_in_wb_op <= ex_out_wb_op;
    mem_in_wb_register <= ex_out_wb_register;
    
    -- Writeback
    -- 'Inputs'
    reg_wr_index <= mem_out_wb_register;
    reg_wr_data <= mem_out_alu_result;
    reg_wr_enable <= mem_out_wb_op;
    -- No outputs

end Behavioral;
