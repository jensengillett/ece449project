
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity preliminary_design_review is
--  Port ( );
end preliminary_design_review;

architecture Behavioral of preliminary_design_review is

signal clk: STD_LOGIC := '0';
signal is_startup: STD_LOGIC := '1';
-- TEMPORARY: For Preliminary Design Review, this stores the current 'memory' value.
signal loaded_value : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

component alu
 port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : out   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_enable: in  STD_LOGIC
    );
end component;

signal alu_a, alu_b, alu_result, alu_extra_16_bits : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_cl : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal alu_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal alu_negative, alu_zero, alu_overflow : STD_LOGIC;

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
        out_port: out std_logic_vector(15 downto 0)
    );
end component;

signal reg_rst, reg_wr_enable, reg_out_enable: STD_LOGIC;
signal reg_rd_index1, reg_rd_index2, reg_wr_index: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal reg_rd_data1, reg_rd_data2, reg_wr_data, reg_out_port: STD_LOGIC_VECTOR(15 DOWNTO 0);

component decoder Port ( 
        clk: in STD_LOGIC;
        decode_enable : in STD_LOGIC;
        instruction: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_op: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_enable: out STD_LOGIC;
        write_enable: out STD_LOGIC;
        read_1_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_2_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        cl_value: out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- for SHL and SHR
        -- TEMP FOR PRELIMINARY DESIGN REVIEW
        in_port: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_write_data: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_enable: out STD_LOGIC
    );
end component;

signal decode_mem_enable, decode_write_enable, decode_out_enable: STD_LOGIC;
signal decode_instruction, decode_in_port, decode_in_write_data: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal decode_alu_op, decode_read_1_select, decode_read_2_select, decode_write_select: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal decode_cl_value: STD_LOGIC_VECTOR(3 DOWNTO 0);

component simple_control_path Port ( 
        clk : in STD_LOGIC;
        control_reset : in STD_LOGIC;
        control_state : out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end component;

signal control_reset: STD_LOGIC;
signal control_state: STD_LOGIC_VECTOR(3 DOWNTO 0);

component pc_unit Port (
        clk: in STD_LOGIC;
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_reset: in STD_LOGIC;
        in_pc_assign: in STD_LOGIC;
        out_pc: out STD_LOGIC_VECTOR(15 DOWNTO 0)
     );
end component;

signal in_pc, pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_pc_reset, in_pc_assign: STD_LOGIC;

-- Enable lines
signal en_decode: STD_LOGIC := '0';
signal en_regread: STD_LOGIC := '0';
signal en_alu: STD_LOGIC := '0';
signal en_regwrite: STD_LOGIC := '0';


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
        alu_enable => en_alu
    );
    
    u_register: register_file port map(
        rst => reg_rst,
        clk => clk,
        reg_enable => en_regread or en_regwrite,
        rd_index1 => reg_rd_index1,
        rd_index2 => reg_rd_index2,
        wr_index => reg_wr_index,
        wr_data => reg_wr_data,
        wr_enable => reg_wr_enable and en_regwrite,
        out_enable => reg_out_enable,
        out_port => reg_out_port
    );
    
    u_decode: decoder port map(
        clk => clk,
        decode_enable => en_decode,
        instruction => decode_instruction,
        alu_op => decode_alu_op,
        mem_enable => decode_mem_enable,
        write_enable => decode_write_enable,
        read_1_select => decode_read_1_select,
        read_2_select => decode_read_2_select,
        write_select => decode_write_select,
        cl_value => decode_cl_value,
        -- TEMP FOR PRELIMINARY DESIGN REVIEW
        in_port => decode_in_port,
        in_write_data => decode_in_write_data,
        out_enable => decode_out_enable
    );
    
    u_control: simple_control_path port map(
        clk => clk,
        control_reset => control_reset,
        control_state => control_state
    );
    
    u_pc: pc_unit port map(
        clk => clk,
        in_pc => in_pc,
        in_pc_reset => in_pc_reset,
        in_pc_assign => in_pc_assign,
        out_pc => pc
    );
    
    en_decode <= control_state(0);
    en_regread <= control_state(1);
    en_alu <= control_state(2);
    en_regwrite <= control_state(3);
    
    -- Instruction Fetch
    decode_instruction <= loaded_value;
    
    -- Decode stage
    reg_rd_index1 <= decode_read_1_select;
    reg_rd_index2 <= decode_read_2_select;
    reg_out_enable <= decode_out_enable;
    
    -- Execute stage
    alu_a <= reg_rd_data1;
    alu_b <= reg_rd_data2;
    alu_f <= decode_alu_op;
    alu_cl <= decode_cl_value;
    
    -- Writeback stage
    reg_wr_data <= alu_result;
    reg_wr_index <= decode_write_select;
    reg_wr_enable <= decode_write_enable;
    
    -- Clock process. This just clocks the control path automatically every 10us.
    -- TODO: Does this work on the BASYS 3, or just in sim?
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    process(clk) begin
        if(rising_edge(clk) and is_startup = '1') then
            is_startup <= '0';
        end if;
    end process;

    -- TEMPORARY: For Preliminary Design Review, this loads values based on the PC from fake memory.
    process begin
        wait until (pc'event);
        case pc is
            -- For some reason there's an offset set at the start of the assembly file that makes it not have data until 0x0216.
            -- This was not replicated here.
            when X"0010" =>
                loaded_value <= X"4240";
                decode_in_port <= X"0003";
                reg_wr_data <= decode_in_write_data;
            when X"0012" =>
                loaded_value <= X"4280";
                decode_in_port <= X"0005";
                reg_wr_data <= decode_in_write_data;
            when X"0014" =>
                loaded_value <= X"0000";
            when X"0016" =>
                loaded_value <= X"0000";
            when X"0018" => 
                loaded_value <= X"0000";
            when X"001A" =>
                loaded_value <= X"0000";
            when X"001C" =>
                loaded_value <= X"02D1";
            when X"001E" =>
                loaded_value <= X"0000";
            when X"0020" =>
                loaded_value <= X"0000";
            when X"0022" =>
                loaded_value <= X"0000";
            when X"0024" =>
                loaded_value <= X"0000";
            when X"0026" =>
                loaded_value <= X"0AC2";
            when X"0028" =>
                loaded_value <= X"0000";
            when X"002A" =>
                loaded_value <= X"0000";
            when X"002C" =>
                loaded_value <= X"0000";
            when X"002E" =>
                loaded_value <= X"0000";
            when X"0030" =>
                loaded_value <= X"068B";
            when X"0032" =>
                loaded_value <= X"0000";
            when X"0034" =>
                loaded_value <= X"0000";
            when X"0036" =>
                loaded_value <= X"0000";
            when X"0038" =>
                loaded_value <= X"0000";
            when X"003A" =>
                loaded_value <= X"4080";
            when X"003C" =>
                loaded_value <= X"0000";
            when others =>
                loaded_value <= X"0000";
        end case;
    end process;
end Behavioral;
