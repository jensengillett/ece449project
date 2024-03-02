
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path is
    Port (
        OUT_PORT: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_PORT: in STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
end control_path;

architecture Behavioral of control_path is

-- Main system clock
signal clk : STD_LOGIC;
-- Program Counter (PC)
signal pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";  -- 16-bit addressing
-- TEMPORARY: For Preliminary Design Review, this stores the current 'memory' value.
signal loaded_value : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

-- Include ALU as a component.
component alu port(
    a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
    cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
    f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
    clk     : in    STD_LOGIC;
    negative, zero, overflow : out   STD_LOGIC;
    result, extra_16_bits  : out   STD_LOGIC_VECTOR(15 DOWNTO 0)
);
end component;

-- ALU signals.
signal alu_a, alu_b : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_cl : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal alu_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal alu_negative, alu_zero, alu_overflow : STD_LOGIC;
signal alu_result, alu_extra_16_bits : STD_LOGIC_VECTOR(15 DOWNTO 0);

-- Include Register File as a component.
component register_file port(
    rst : in std_logic; clk: in std_logic;
    --read signals
    rd_index1: in std_logic_vector(2 downto 0); 
    rd_index2: in std_logic_vector(2 downto 0); 
    rd_data1: out std_logic_vector(15 downto 0); 
    rd_data2: out std_logic_vector(15 downto 0);
    --write signals
    wr_index: in std_logic_vector(2 downto 0); 
    wr_data: in std_logic_vector(15 downto 0); wr_enable: in std_logic
);
end component;

-- Reg file signals.
signal reg_rst : std_logic;
signal reg_rd_index1: std_logic_vector(2 downto 0); 
signal reg_rd_index2: std_logic_vector(2 downto 0); 
signal reg_rd_data1: std_logic_vector(15 downto 0); 
signal reg_rd_data2: std_logic_vector(15 downto 0);
signal reg_wr_index: std_logic_vector(2 downto 0); 
signal reg_wr_data: std_logic_vector(15 downto 0); 
signal reg_wr_enable: std_logic;

-- Include memory component here.


-- Memory signals.


-- Pipeline registers

-- IF/ID Registers
-- Opcode = 15:9, other contents dependant on how the opcode decodes.
signal if_id_register : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
-- Register for writeback
signal if_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

-- ID/EX Registers
-- Two registers for read data, rd1 and rd2.
signal id_rd1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal id_rd2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
-- Register for writeback
signal id_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

-- EX/MEM Registers
-- ex_ar = ALU Result, ex_hr = Hidden Result (extra 16 bits of MUL)
signal ex_ar : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal ex_hr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal ex_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

-- MEM/WB Registers
signal mem_ar : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal mem_hr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal mem_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";

begin
    -- Port map ALU
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
        extra_16_bits => alu_extra_16_bits
    );
    
    -- Port map register file
    u_regfile: register_file port map(
        rst => reg_rst,
        clk => clk,
        rd_index1 => reg_rd_index1,
        rd_index2 => reg_rd_index2,
        rd_data1 => reg_rd_data1,
        rd_data2 => reg_rd_data2,
        wr_index => reg_wr_index,
        wr_data => reg_wr_data,
        wr_enable => reg_wr_enable
    );
    
    -- Clock process. This just clocks the control path automatically every 10us.
    -- TODO: Does this work on the BASYS 3, or just in sim?
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    -- Update the program counter by a word (2 bytes)
    -- TODO: Branch support.
    process begin
        wait until (clk='1' and clk'event);
        pc <= std_logic_vector(unsigned(pc) + 2);
    end process;
    
    -- Main system process
    process(clk) begin
        -- Instruction Fetch
        
        -- Decode
        
        -- Execute
        
        -- Memory Access
        
        -- Write Back
        
    end process;
    
    -- TEMPORARY: For Preliminary Design Review, this loads values based on the PC from fake memory.
    process begin
        wait until (pc'event);
        case pc is
            -- For some reason there's an offset set at the start of the assembly file that makes it not have data until 0x0216.
            -- This was replicated here just in case it was important.
            when X"0216" =>
                loaded_value <= X"4240";
            when X"0218" =>
                loaded_value <= X"4280";
            when X"021A" =>
                loaded_value <= X"0000";
            when X"021C" =>
                loaded_value <= X"0000";
            when X"021E" => 
                loaded_value <= X"0000";
            when X"0220" =>
                loaded_value <= X"0000";
            when X"0222" =>
                loaded_value <= X"02D1";
            when X"0224" =>
                loaded_value <= X"0000";
            when X"0226" =>
                loaded_value <= X"0000";
            when X"0228" =>
                loaded_value <= X"0000";
            when X"022A" =>
                loaded_value <= X"0000";
            when X"022C" =>
                loaded_value <= X"0AC2";
            when X"022E" =>
                loaded_value <= X"0000";
            when X"0230" =>
                loaded_value <= X"0000";
            when X"0232" =>
                loaded_value <= X"0000";
            when X"0234" =>
                loaded_value <= X"0000";
            when X"0236" =>
                loaded_value <= X"068B";
            when X"0238" =>
                loaded_value <= X"0000";
            when X"023A" =>
                loaded_value <= X"0000";
            when X"023C" =>
                loaded_value <= X"0000";
            when X"023E" =>
                loaded_value <= X"0000";
            when X"0240" =>
                loaded_value <= X"4080";
            when X"0242" =>
                loaded_value <= X"0000";
            when X"FFFF" =>
                pc <= X"0000";
            when others =>
                loaded_value <= X"0000";
        end case;
    end process;
end Behavioral;
