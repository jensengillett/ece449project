
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path_v3 is
    Port ( 
        --out_pc : out std_logic_vector(15 downto 0);
        --out_port: out std_logic_vector(15 downto 0);
        in_port: in std_logic_vector(15 downto 0);
        in_port_enable: in std_logic;
        in_clk: in std_logic;
        in_reg_reset: in std_logic;
        debug_console : in STD_LOGIC;
        board_clock: in std_logic;
       
        vga_red : out std_logic_vector( 3 downto 0 );
        vga_green : out std_logic_vector( 3 downto 0 );
        vga_blue : out std_logic_vector( 3 downto 0 );
       
        h_sync_signal : out std_logic;
        v_sync_signal : out std_logic
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
        negative, zero, overflow : inout   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        result_enable : out STD_LOGIC;
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_enable: in  STD_LOGIC;
        branch_op: in STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: in STD_LOGIC_VECTOR(8 DOWNTO 0);
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_pc: out STD_LOGIC_VECTOR(16 DOWNTO 0);
        flush_pipeline: out STD_LOGIC;
        wb_register_in : in STD_LOGIC_VECTOR(2 downto 0);
        wb_register_out : out STD_LOGIC_VECTOR(2 downto 0);
        reg_seven_in: in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

signal alu_a, alu_b, alu_result, alu_extra_16_bits : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_cl : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal alu_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal alu_negative, alu_zero, alu_overflow : STD_LOGIC;
signal alu_branch_op: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal alu_branch_displacement: STD_LOGIC_VECTOR(8 DOWNTO 0);
signal alu_in_pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_out_pc: STD_LOGIC_VECTOR(16 DOWNTO 0);
signal alu_flush_pipeline: STD_LOGIC;
signal alu_wb_register_in, alu_wb_register_out: STD_LOGIC_VECTOR(2 downto 0);
signal alu_reg_seven_in: STD_LOGIC_VECTOR(15 downto 0);
signal alu_result_enable: STD_LOGIC;

component register_file port(
        rst : in std_logic; clk: in std_logic; reg_enable: in std_logic;
        --read signals
        rd_index1: in std_logic_vector(2 downto 0); 
        rd_index2: in std_logic_vector(2 downto 0); 
        rd_data1: out std_logic_vector(15 downto 0); 
        rd_data2: out std_logic_vector(15 downto 0);
        rd_data3: out std_logic_vector(15 downto 0);
        --write signals
        wr_index: in std_logic_vector(2 downto 0); 
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic;
        out_enable: in std_logic;
        out_port: out std_logic_vector(15 downto 0);
        in_port_enable: in std_logic;
        in_index: in std_logic_vector(2 downto 0);
        in_port: in std_logic_vector(15 downto 0);
        in_flush_pipeline: in std_logic
    );
end component;

signal reg_rst, reg_wr_enable, reg_out_enable, reg_in_port_enable, reg_in_flush_pipeline: STD_LOGIC;
signal reg_rd_index1, reg_rd_index2, reg_wr_index, reg_in_index: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal reg_rd_data1, reg_rd_data2, reg_rd_data3, reg_wr_data, reg_out_port, reg_in_port: STD_LOGIC_VECTOR(15 DOWNTO 0);

component decoder Port ( 
        clk: in STD_LOGIC;
        decode_enable : in STD_LOGIC;
        instruction: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_op: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_op: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_op: out STD_LOGIC;
        read_1_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_2_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        cl_value: out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- for SHL and SHR
        branch_op: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: out STD_LOGIC_VECTOR(8 DOWNTO 0);
        in_in_port: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_in_port: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_in_port_enable: in STD_LOGIC;
        out_in_port_enable: out STD_LOGIC;
        in_write_data: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_port_index : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        out_enable: out STD_LOGIC;
        out_m1: out STD_LOGIC;
        out_imm: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        in_flush_pipeline: in STD_LOGIC
    );
end component;

signal decode_wb_op, decode_out_enable, decode_in_in_port_enable, decode_out_in_port_enable: STD_LOGIC;
signal decode_instruction, decode_in_in_port, decode_out_in_port, decode_in_write_data: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal decode_alu_op, decode_read_1_select, decode_read_2_select, decode_write_select, decode_in_port_index, decode_mem_op: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal decode_branch_op: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal decode_branch_displacement: STD_LOGIC_VECTOR(8 DOWNTO 0);
signal decode_cl_value: STD_LOGIC_VECTOR(3 DOWNTO 0);
signal decode_out_m1, decode_in_flush_pipeline: STD_LOGIC;
signal decode_out_imm: STD_LOGIC_VECTOR(7 DOWNTO 0);

component pc_unit Port (
        clk: in STD_LOGIC;
        in_pc: in STD_LOGIC_VECTOR(16 DOWNTO 0);
        in_pc_reset: in STD_LOGIC;
        out_pc: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_pc_2: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_en_pc: in STD_LOGIC
     );
end component;

signal in_pc: STD_LOGIC_VECTOR(16 DOWNTO 0);
signal pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal out_pc_2: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_pc_reset: STD_LOGIC;

component if_id_latch Port (
        clk: in std_logic;
        if_in_instruction : in std_logic_vector(15 downto 0);
        if_out_instruction : out std_logic_vector(15 downto 0);
        if_in_in_port : in std_logic_vector(15 downto 0);
        if_out_in_port : out std_logic_vector(15 downto 0);
        if_in_in_port_enable : in std_logic;
        if_out_in_port_enable: out std_logic;
        if_in_pc : in std_logic_vector(15 downto 0);
        if_out_pc : out std_logic_vector(15 downto 0);
        if_in_flush_pipeline: in std_logic;
        if_enable_latch: in std_logic
    );
end component;

signal if_in_instruction, if_out_instruction, if_in_in_port, if_out_in_port: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal if_in_in_port_enable, if_out_in_port_enable, if_in_flush_pipeline: STD_LOGIC;
signal if_in_pc, if_out_pc: STD_LOGIC_VECTOR(15 downto 0);

component id_ex_latch Port(
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
        id_in_flush_pipeline :in std_logic;
        id_enable_latch: in std_logic
    );
end component;

signal id_in_rd_data_1: std_logic_vector(15 downto 0);
signal id_out_rd_data_1: std_logic_vector(15 downto 0);
signal id_in_rd_data_2: std_logic_vector(15 downto 0);
signal id_out_rd_data_2: std_logic_vector(15 downto 0);
signal id_in_rd_data_3: std_logic_vector(15 downto 0);
signal id_out_rd_data_3: std_logic_vector(15 downto 0);
signal id_in_alu_op: std_logic_vector(2 downto 0);
signal id_out_alu_op: std_logic_vector(2 downto 0);
signal id_in_mem_op: std_logic_vector(2 downto 0);
signal id_out_mem_op: std_logic_vector(2 downto 0);
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
signal id_in_pc, id_out_pc: STD_LOGIC_VECTOR(15 downto 0);
signal id_in_m1, id_out_m1, id_in_flush_pipeline: std_logic;
signal id_in_imm, id_out_imm: std_logic_vector(7 downto 0);

component ex_mem_latch Port(
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
end component;

signal ex_in_alu_result: std_logic_vector(15 downto 0);
signal ex_out_alu_result: std_logic_vector(15 downto 0);
signal ex_in_mem_op: std_logic_vector(2 downto 0);
signal ex_out_mem_op: std_logic_vector(2 downto 0);
signal ex_in_wb_op, ex_out_wb_op: std_logic;
signal ex_in_wb_register : std_logic_vector(2 downto 0);
signal ex_out_wb_register : std_logic_vector(2 downto 0);
signal ex_in_m1, ex_out_m1: std_logic;
signal ex_in_imm, ex_out_imm: std_logic_vector(7 downto 0);
signal ex_in_alu_result_enable, ex_out_alu_result_enable: std_logic;
signal ex_in_rd_data_1, ex_out_rd_data_1, ex_in_rd_data_2, ex_out_rd_data_2: std_logic_vector(15 downto 0);

component mem_wb_latch Port(
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
end component;

signal mem_in_alu_result: std_logic_vector(15 downto 0);
signal mem_out_alu_result: std_logic_vector(15 downto 0);
signal mem_in_wb_op: std_logic;
signal mem_out_wb_op: std_logic;
signal mem_in_wb_register : std_logic_vector(2 downto 0);
signal mem_out_wb_register : std_logic_vector(2 downto 0);
signal mem_in_alu_result_en, mem_out_alu_result_en: std_logic;
signal mem_in_mem_load, mem_out_mem_load: std_logic_vector(15 downto 0);
signal mem_in_mem_load_en, mem_out_mem_load_en: std_logic;

--component rom Port ( 
--        data_out: out std_logic_vector(15 downto 0);
--        address: in std_logic_vector(7 downto 0);
--        clk: in std_logic
--    );
--end component;

--signal rom_data_out: std_logic_vector(15 downto 0);
--signal rom_address: std_logic_vector(7 downto 0);

component memory_unit port(
        in_mem_op: in std_logic_vector(2 downto 0);
        in_src_data: in std_logic_vector(15 downto 0);
        in_dest_data: in std_logic_vector(15 downto 0);
        out_dest_data: out std_logic_vector(15 downto 0);
        out_enable: out std_logic;
        in_m1: in std_logic;
        in_imm: in std_logic_vector(7 downto 0);
        enable_mem: in std_logic;
        clk: in std_logic;
        in_inst_address: in std_logic_vector(15 downto 0);
        out_inst_data: out std_logic_vector(15 downto 0)
    );
end component; 

signal mem_unit_in_mem_op: std_logic_vector(2 downto 0);
signal mem_unit_in_src_data: std_logic_vector(15 downto 0);
signal mem_unit_in_dest_data: std_logic_vector(15 downto 0);
signal mem_unit_out_dest_data: std_logic_vector(15 downto 0);
signal mem_unit_in_m1: std_logic;
signal mem_unit_in_imm: std_logic_vector(7 downto 0);
signal mem_unit_out_enable: std_logic;
signal mem_unit_in_inst_address: std_logic_vector(15 downto 0);
signal mem_unit_out_inst_data: std_logic_vector(15 downto 0);

-- Enable lines
signal en_decode: STD_LOGIC := '1';
signal en_regread: STD_LOGIC := '1';
signal en_alu: STD_LOGIC := '1';
signal en_regwrite: STD_LOGIC := '1';
signal en_pc: STD_LOGIC := '1';
signal en_mem: STD_LOGIC := '1';
signal en_if_latch: STD_LOGIC := '1';
signal en_id_latch: STD_LOGIC := '1';
signal en_ex_latch: STD_LOGIC := '1';
signal en_mem_latch: STD_LOGIC := '1';

component console is
    port (

--
-- Stage 1 Fetch
--
        s1_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
        s1_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );


--
-- Stage 2 Decode
--
        s2_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
        s2_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );

        s2_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );
        s2_reg_b : in STD_LOGIC_VECTOR( 2 downto 0 );
        s2_reg_c : in STD_LOGIC_VECTOR( 2 downto 0 );

        s2_reg_a_data : in STD_LOGIC_VECTOR( 15 downto 0 );
        s2_reg_b_data : in STD_LOGIC_VECTOR( 15 downto 0 );
        s2_reg_c_data : in STD_LOGIC_VECTOR( 15 downto 0 );

        s2_immediate : in STD_LOGIC_VECTOR( 15 downto 0 );


--
-- Stage 3 Execute
--
        s3_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
        s3_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );

        s3_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );
        s3_reg_b : in STD_LOGIC_VECTOR( 2 downto 0 );
        s3_reg_c : in STD_LOGIC_VECTOR( 2 downto 0 );

        s3_reg_a_data : in STD_LOGIC_VECTOR( 15 downto 0 );
        s3_reg_b_data : in STD_LOGIC_VECTOR( 15 downto 0 );
        s3_reg_c_data : in STD_LOGIC_VECTOR( 15 downto 0 );

        s3_immediate : in STD_LOGIC_VECTOR( 15 downto 0 );

--
-- Branch and memory operation
--
        s3_r_wb : in STD_LOGIC;
        s3_r_wb_data : in STD_LOGIC_VECTOR( 15 downto 0 );

        s3_br_wb : in STD_LOGIC;
        s3_br_wb_address : in STD_LOGIC_VECTOR( 15 downto 0 );

        s3_mr_wr : in STD_LOGIC;
        s3_mr_wr_address : in STD_LOGIC_VECTOR( 15 downto 0 );
        s3_mr_wr_data : in STD_LOGIC_VECTOR( 15 downto 0 );

        s3_mr_rd : in STD_LOGIC;
        s3_mr_rd_address : in STD_LOGIC_VECTOR( 15 downto 0 );

--
-- Stage 4 Memory
--
        s4_pc : in STD_LOGIC_VECTOR( 15 downto 0 );
        s4_inst : in STD_LOGIC_VECTOR( 15 downto 0 );

        s4_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );

        s4_r_wb : in STD_LOGIC;
        s4_r_wb_data : in STD_LOGIC_VECTOR( 15 downto 0 );

--
-- CPU registers
--

        register_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_4 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_5 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_6 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        register_7 : in STD_LOGIC_VECTOR ( 15 downto 0 );

--
-- CPU registers overflow flags
--
        register_0_of : in STD_LOGIC;
        register_1_of : in STD_LOGIC;
        register_2_of : in STD_LOGIC;
        register_3_of : in STD_LOGIC;
        register_4_of : in STD_LOGIC;
        register_5_of : in STD_LOGIC;
        register_6_of : in STD_LOGIC;
        register_7_of : in STD_LOGIC;

--
-- CPU Flags
--
        zero_flag : in STD_LOGIC;
        negative_flag : in STD_LOGIC;
        overflow_flag : in STD_LOGIC;

--
-- Debug screen enable
--
        debug : in STD_LOGIC;

--
-- Text console display memory access signals ( clk is the processor clock )
--
        addr_write : in  STD_LOGIC_VECTOR (15 downto 0);
        clk : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR (15 downto 0);
        en_write : in  STD_LOGIC;

--
-- Video related signals
--
        board_clock : in STD_LOGIC;
        v_sync_signal : out STD_LOGIC;
        h_sync_signal : out STD_LOGIC;
        vga_red : out STD_LOGIC_VECTOR( 3 downto 0 );
        vga_green : out STD_LOGIC_VECTOR( 3 downto 0 );
        vga_blue : out STD_LOGIC_VECTOR( 3 downto 0 )

    );
end component;

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
        result_enable => alu_result_enable,
        extra_16_bits => alu_extra_16_bits,
        alu_enable => en_alu,
        branch_op => alu_branch_op,
        branch_displacement => alu_branch_displacement,
        in_pc => alu_in_pc,
        out_pc => alu_out_pc,
        flush_pipeline => alu_flush_pipeline,
        wb_register_in => alu_wb_register_in,
        wb_register_out => alu_wb_register_out,
        reg_seven_in => alu_reg_seven_in
    );
    
    u_register: register_file port map(
        rst => reg_rst,
        clk => clk,
        reg_enable => en_regread or en_regwrite,
        rd_index1 => reg_rd_index1,
        rd_index2 => reg_rd_index2,
        rd_data1 => reg_rd_data1,
        rd_data2 => reg_rd_data2,
        rd_data3 => reg_rd_data3,
        wr_index => reg_wr_index,
        wr_data => reg_wr_data,
        wr_enable => reg_wr_enable and en_regwrite,
        out_enable => reg_out_enable,
        out_port => reg_out_port,
        in_port_enable => reg_in_port_enable,
        in_index => reg_in_index,
        in_port => reg_in_port,
        in_flush_pipeline => reg_in_flush_pipeline
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
        in_in_port => decode_in_in_port,
        out_in_port => decode_out_in_port,
        in_in_port_enable => decode_in_in_port_enable,
        out_in_port_enable => decode_out_in_port_enable,
        in_write_data => decode_in_write_data,
        in_port_index => decode_in_port_index,
        out_enable => decode_out_enable,
        out_m1 => decode_out_m1,
        out_imm => decode_out_imm,
        in_flush_pipeline => decode_in_flush_pipeline
    );

    
    u_pc: pc_unit port map(
        clk => clk,
        in_pc => in_pc,
        in_pc_reset => in_pc_reset,
        out_pc => pc,
        out_pc_2 => out_pc_2,
        in_en_pc => en_pc
    );
    
    u_if_id : if_id_latch port map(
        clk => clk,
        if_in_instruction => if_in_instruction,
        if_out_instruction => if_out_instruction,
        if_in_in_port => if_in_in_port,
        if_out_in_port => if_out_in_port,
        if_in_in_port_enable => if_in_in_port_enable,
        if_out_in_port_enable => if_out_in_port_enable,
        if_in_pc => if_in_pc,
        if_out_pc => if_out_pc,
        if_in_flush_pipeline => if_in_flush_pipeline,
        if_enable_latch => en_if_latch
    );
    
    u_id_ex : id_ex_latch port map(
        clk => clk,
        id_in_rd_data_1    => id_in_rd_data_1,     
        id_out_rd_data_1   => id_out_rd_data_1,    
        id_in_rd_data_2    => id_in_rd_data_2,     
        id_out_rd_data_2   => id_out_rd_data_2,
        id_in_rd_data_3    => id_in_rd_data_3,     
        id_out_rd_data_3   => id_out_rd_data_3,    
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
        id_out_branch_displacement => id_out_branch_displacement,
        id_in_pc => id_in_pc,
        id_out_pc => id_out_pc,
        id_in_m1 => id_in_m1,
        id_out_m1 => id_out_m1,
        id_in_imm => id_in_imm,
        id_out_imm => id_out_imm,
        id_in_flush_pipeline => id_in_flush_pipeline,
        id_enable_latch => en_id_latch
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
        ex_out_wb_register  => ex_out_wb_register,
        ex_in_m1 => ex_in_m1,
        ex_out_m1 => ex_out_m1,
        ex_in_imm => ex_in_imm,
        ex_out_imm => ex_out_imm,
        ex_in_alu_result_enable => ex_in_alu_result_enable,
        ex_out_alu_result_enable => ex_out_alu_result_enable,
        ex_in_rd_data_1 => ex_in_rd_data_1,
        ex_out_rd_data_1 => ex_out_rd_data_1,
        ex_in_rd_data_2 => ex_in_rd_data_2,
        ex_out_rd_data_2 => ex_out_rd_data_2,
        ex_enable_latch => en_ex_latch
    );
    
    u_mem_wb: mem_wb_latch port map(
        clk => clk,
        mem_in_alu_result   => mem_in_alu_result,   
        mem_out_alu_result  => mem_out_alu_result,  
        mem_in_wb_op        => mem_in_wb_op,        
        mem_out_wb_op       => mem_out_wb_op,       
        mem_in_wb_register  => mem_in_wb_register,  
        mem_out_wb_register => mem_out_wb_register,
        mem_in_alu_result_en => mem_in_alu_result_en,
        mem_out_alu_result_en => mem_out_alu_result_en,
        mem_in_mem_load => mem_in_mem_load,
        mem_out_mem_load => mem_out_mem_load,
        mem_in_mem_load_en => mem_in_mem_load_en,
        mem_out_mem_load_en => mem_out_mem_load_en,
        mem_enable_latch => en_mem_latch
    );
    
    --u_rom: rom port map(
    --    clk => clk,
    --    data_out => rom_data_out,
    --    address => rom_address
    --);
    
    u_mem_unit: memory_unit port map(
        clk => clk,
        in_mem_op     =>  mem_unit_in_mem_op    ,
        in_src_data   =>  mem_unit_in_src_data  ,
        in_dest_data  =>  mem_unit_in_dest_data ,
        out_dest_data =>  mem_unit_out_dest_data,
        out_enable    =>  mem_unit_out_enable   ,
        in_m1         =>  mem_unit_in_m1        ,
        in_imm        =>  mem_unit_in_imm       ,
        enable_mem    =>  en_mem,
        in_inst_address => mem_unit_in_inst_address,
        out_inst_data => mem_unit_out_inst_data
    );
    
    console_display : console
    port map
    (
    --
    -- Stage 1 Fetch
    --
        s1_pc => pc,
        s1_inst => mem_unit_out_inst_data,
    
    --
    -- Stage 2 Decode
    --
    
        s2_pc => x"0000",
        s2_inst => if_out_instruction,
    
        s2_reg_a => decode_read_1_select,
        s2_reg_b => decode_read_2_select,
        s2_reg_c => "111",
    
        s2_reg_a_data => reg_rd_data1,
        s2_reg_b_data => reg_rd_data2,
        s2_reg_c_data => reg_rd_data3,
        s2_immediate => "00000000" & decode_out_imm,
    
    --
    -- Stage 3 Execute
    --
    
        s3_pc => x"0000",
        s3_inst => x"0000",
    
        s3_reg_a => "000",
        s3_reg_b => "000",
        s3_reg_c => "111",
    
        s3_reg_a_data => id_out_rd_data_1,
        s3_reg_b_data => id_out_rd_data_2,
        s3_reg_c_data => id_out_rd_data_3,
        s3_immediate => "00000000" & id_out_imm,
    
        s3_r_wb => id_out_wb_op,
        s3_r_wb_data => x"0000",
    
        s3_br_wb => '0',
        s3_br_wb_address => x"0000",
    
        s3_mr_wr => '0',
        s3_mr_wr_address => x"0000",
        s3_mr_wr_data => x"0000",
    
        s3_mr_rd => '0',
        s3_mr_rd_address => x"0000",
    
    --
    -- Stage 4 Memory
    --
    
        s4_pc => x"0000",
        s4_inst => x"0000",
        s4_reg_a => "000",
        s4_r_wb => mem_unit_out_enable,
        s4_r_wb_data => mem_unit_out_dest_data,
    
    --
    -- CPU registers
    --
    
        register_0 => x"0000",
        register_1 => x"0000",
        register_2 => x"0000",
        register_3 => x"0000",
        register_4 => x"0000",
        register_5 => x"0000",
        register_6 => x"0000",
        register_7 => x"0000",
    
        register_0_of => '0',
        register_1_of => '0',
        register_2_of => '0',
        register_3_of => '0',
        register_4_of => '0',
        register_5_of => '0',
        register_6_of => '0',
        register_7_of => '0',
    
    --
    -- CPU Flags
    --
        zero_flag => '0',
        negative_flag => '0',
        overflow_flag => '0',
    
    --
    -- Debug screen enable
    --
        debug => debug_console,
    
    --
    -- Text console display memory access signals ( clk is the processor clock )
    --
    
        clk => in_clk,
        addr_write => x"0000",
        data_in => in_port,
        en_write => '0',
    
    --
    -- Video related signals
    --
    
        board_clock => board_clock,
        h_sync_signal => h_sync_signal,
        v_sync_signal => v_sync_signal,
        vga_red => vga_red,
        vga_green => vga_green,
        vga_blue => vga_blue
    );
    
    -- Link PC and clk
    --out_pc <= pc;
    clk <= in_clk;
    reg_rst <= in_reg_reset;
    mem_unit_in_inst_address <= '0' & out_pc_2(15 downto 1);
    
    -- Link pipeline flush flag from ALU -> Control path -> IF/ID register
    if_in_flush_pipeline <= alu_flush_pipeline;
    id_in_flush_pipeline <= alu_flush_pipeline;
    reg_in_flush_pipeline <= alu_flush_pipeline;
    decode_in_flush_pipeline <= alu_flush_pipeline;
    
    -- Instruction fetch
    if_in_instruction <= mem_unit_out_inst_data;
    if_in_in_port <= in_port;
    if_in_in_port_enable <= in_port_enable;
    if_in_pc <= pc;
    
    -- Decode 'Inputs'
    decode_instruction <= if_out_instruction;
    reg_rd_index1 <= decode_read_1_select;
    reg_rd_index2 <= decode_read_2_select;
    reg_out_enable <= decode_out_enable;
    --reg_in_port <= if_out_in_port;
    decode_in_in_port <= if_out_in_port;
    reg_in_port <= decode_out_in_port;
    --reg_in_port_enable <= if_out_in_port_enable;
    decode_in_in_port_enable <= if_out_in_port_enable;
    reg_in_port_enable <= decode_out_in_port_enable;
    reg_in_index <= decode_in_port_index;
    
    -- Decode 'Outputs'
    --out_port <= reg_out_port;
    id_in_alu_op <= decode_alu_op;
    id_in_mem_op <= decode_mem_op;
    id_in_wb_op <= decode_wb_op;
    id_in_wb_register <= decode_write_select;
    id_in_cl_value <= decode_cl_value;
    id_in_branch_op <= decode_branch_op;
    id_in_branch_displacement <= decode_branch_displacement;
    id_in_pc <= if_out_pc;
    id_in_rd_data_1 <= reg_rd_data1;
    id_in_rd_data_2 <= reg_rd_data2;
    id_in_rd_data_3 <= reg_rd_data3;
    id_in_m1 <= decode_out_m1;
    id_in_imm <= decode_out_imm;
    
    -- Execute 'Inputs'
    alu_a <= id_out_rd_data_1;
    alu_b <= id_out_rd_data_2;
    alu_f <= id_out_alu_op;
    alu_cl <= id_out_cl_value;
    alu_branch_op <= id_out_branch_op;
    alu_branch_displacement <= id_out_branch_displacement;
    alu_in_pc <= id_out_pc;
    alu_wb_register_in <= id_out_wb_register;
    alu_reg_seven_in <= id_out_rd_data_3;
    
    -- Execute 'Outputs'
    ex_in_alu_result <= alu_result;
    ex_in_alu_result_enable <= alu_result_enable;
    in_pc <= alu_out_pc; -- pass new PC value to PC unit, PC unit will determine whether to use it or not
    ex_in_wb_register <= alu_wb_register_out; -- WB op passes through alu, is modified on BR.SUB instruction
    -- Negative, Zero, Overflow, and extra_16_bits should be added later.
    ex_in_mem_op <= id_out_mem_op;
    ex_in_wb_op <= id_out_wb_op;
    ex_in_m1 <= id_out_m1;
    ex_in_imm <= id_out_imm;
    ex_in_rd_data_1 <= id_out_rd_data_1;
    ex_in_rd_data_2 <= id_out_rd_data_2;
    
    -- Memory 'Inputs'
    mem_unit_in_mem_op <= ex_out_mem_op;
    mem_unit_in_src_data <= ex_out_rd_data_1;
    mem_unit_in_dest_data <= ex_out_rd_data_2;
    mem_unit_in_m1 <= ex_out_m1;
    mem_unit_in_imm <= ex_out_imm;
    -- Memory 'Outputs'
    mem_in_mem_load <= mem_unit_out_dest_data;
    mem_in_mem_load_en <= mem_unit_out_enable;
    mem_in_alu_result <= ex_out_alu_result;
    mem_in_alu_result_en <= ex_out_alu_result_enable;
    mem_in_wb_op <= ex_out_wb_op;
    mem_in_wb_register <= ex_out_wb_register;
    
    -- Writeback
    reg_wr_index <= mem_out_wb_register;
    reg_wr_enable <= mem_out_wb_op;
    reg_wr_data <= mem_out_alu_result when mem_out_alu_result_en else  -- simple MUX
        mem_out_mem_load;  -- mem_load_en doesn't end up used
    -- End of pipeline

end Behavioral;
