
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_path is
    Port (
        -- Main system clock
        clk : in STD_LOGIC;
        OUT_PORT: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_PORT: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Program Counter (PC)
        pc : inout STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- TEMPORARY: For Preliminary Design Review, this stores the current 'memory' value.
        loaded_value : in STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
end control_path;

architecture Behavioral of control_path is

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

-- ID/EX Registers
-- Two registers for read data, rd1 and rd2.
signal id_rd1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal id_rd2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
-- Register for passing CL to the ALU a cycle later.
signal id_cl : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
-- Register for writeback
signal id_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
signal id_alu_mode : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
signal id_mem_opr : STD_LOGIC := '0';
signal id_wb_opr : STD_LOGIC := '0';

-- EX/MEM Registers
-- ex_ar = ALU Result, ex_hr = Hidden Result (extra 16 bits of MUL)
signal ex_ar : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal ex_hr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal ex_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
signal ex_mem_opr : STD_LOGIC := '0';
signal ex_wb_opr : STD_LOGIC := '0';

-- MEM/WB Registers
signal mem_ar : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal mem_hr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal mem_ra : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
signal mem_wb_opr : STD_LOGIC := '0';

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

    -- Update the program counter by a word (2 bytes)
    -- TODO: Branch support.
    process begin
        wait until (clk='1' and clk'event);
        pc <= std_logic_vector(unsigned(pc) + 2);
    end process;
    
    -- Main system process
    process(clk) begin
        ---- Instruction Fetch
        -- TEMPORARY: The loaded value is currently being stored in 'loaded_value' for the Preliminary Design Review.
        -- This will be replaced with actual fetch by final design.
        if_id_register <= loaded_value;
        
        ---- Decode
        -- Move ra (output register) into between-stage storage.
        -- Thankfully, output (writeback) is always to ra, so we can just hardcode it.
        id_ra <= if_id_register(8 DOWNTO 6);
        
        -- Determine which registers get loaded into the register file dependant on opcode
        -- This is required because for _some reason_ there's inconsistency on which registers are read from.
        -- Some instructions read from rb and rc, while others read from ra.
        -- Thus we need to actually check so that we make sure to read the right data from the register file.
        if(if_id_register(15 DOWNTO 9) < X"5") then   -- ADD, SUB, MUL, and NAND all read from rb and rc
            reg_rd_index1 <= if_id_register(5 DOWNTO 3);
            reg_rd_index2 <= if_id_register(2 DOWNTO 0);
        elsif(if_id_register(15 DOWNTO 9) >= X"5") then  -- SHL, SHR, TEST, OUT, and IN all read from ra
            reg_rd_index1 <= if_id_register(8 DOWNTO 6);
            reg_rd_index2 <= "000";
        end if;
        
        -- SHL and SHR use part of what would be rb/rc as cl.
        if((if_id_register(15 DOWNTO 9) = X"5") or (if_id_register(15 DOWNTO 9) = X"6")) then
            id_cl <= if_id_register(3 DOWNTO 0);
        end if;
        
        -- Pass ALU mode to the ALU dependant on opcode.
        if(if_id_register(15 DOWNTO 9) < X"8") then  -- ALU opcodes are from 0 to 7
            id_alu_mode <= if_id_register(11 DOWNTO 9);  -- low three bits of opcode determine ALU operator
        end if;
        
        -- If this is a memory operation, we pass along the mem_opr flag.
        -- TODO: Format L instructions require this. Implement later!
        
        -- If this instruction writes data back to the register file, pass along the wb_opr flag.
        -- Writeback is enabled on format A instructions between 1 and 6.
        if((if_id_register(15 DOWNTO 9) > X"0") and (if_id_register(15 DOWNTO 9) < X"7")) then
            id_wb_opr <= '1';
        end if;
        
        -- If this is an IN instruction, write the data into the register file.
        -- IN instructions don't actually provide the value
        -- TEMPORARY: This won't work with a full pipeline, but this is only being used for the Format A test.
        if(if_id_register(15 DOWNTO 9) = X"21") then
            reg_wr_index <= if_id_register(8 DOWNTO 6);  -- store ra
            reg_wr_data <= IN_PORT;
            reg_wr_enable <= '1';
        end if;
        
        ---- Execute
        
        ---- Memory Access
        
        ---- Write Back
        
    end process;
    
    
end Behavioral;
