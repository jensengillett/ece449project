
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

-- Include memory component here.

-- Main system clock
signal clk : STD_LOGIC;
-- Program Counter (PC)
signal pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";  -- 16-bit addressing

-- IF/ID Register
-- Opcode = 15:9, other contents dependant on how the opcode decodes.
signal if_id_register : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

-- ID/EX Registers
-- Two registers for read data, rd1 and rd2.
signal rd1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal rd2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";

-- EX/MEM Registers
-- ar = ALU Result, hr = Hidden Result (extra 16 bits of MUL)
signal ar : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
signal hr : STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";


begin
    
    -- Port maps here
    
    -- Main system process
    process(clk) begin
        -- Instruction Fetch
        
        -- Decode
        
        -- Execute
        
        -- Memory Access
        
        -- Write Back
        
        
    end process;
    
    -- Update the program counter
    -- TODO: Branch support.
    process begin
        wait until (clk='1' and clk'event);
        pc <= std_logic_vector(unsigned(pc) + 1);
    end process;
        
end Behavioral;
