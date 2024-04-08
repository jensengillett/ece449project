
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Since this is a simulation module, we don't define any ports.
entity test_alu is
    --  Port ( );
end test_alu;

-- Start architecture definition.
architecture Behavioral of test_alu is

-- Include ALU as a component.
component alu 
    Port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : inout   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        result_enable : out STD_LOGIC;
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_enable: in  STD_LOGIC;
        -- Data for branching
        branch_op: in STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: in STD_LOGIC_VECTOR(8 DOWNTO 0);
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_pc: out STD_LOGIC_VECTOR(16 DOWNTO 0);
        flush_pipeline: out STD_LOGIC; -- ALU signal to indicate that control path that a branch was taken
        wb_register_in: in STD_LOGIC_VECTOR(2 downto 0); -- writeback op input to select R7 for BR.SUB and RETURN instructions
        wb_register_out: out STD_LOGIC_VECTOR(2 downto 0);
        reg_seven_in: in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- Set up signals internally for each of the ALU signals.
signal a, b    : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal cl      : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal f       : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal clk     : STD_LOGIC;
signal negative, zero, overflow : STD_LOGIC;
signal result, extra_16_bits  : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal alu_enable : STD_LOGIC;
signal branch_op: STD_LOGIC_VECTOR(7 DOWNTO 0);
signal branch_displacement: STD_LOGIC_VECTOR(8 DOWNTO 0);
signal in_pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal out_pc: STD_LOGIC_VECTOR(16 DOWNTO 0);
signal flush_pipeline: STD_LOGIC; -- ALU signal to indicate that control path that a branch was taken
signal wb_register_in: STD_LOGIC_VECTOR(2 downto 0); -- writeback op input to select R7 for BR.SUB and RETURN instructions
signal wb_register_out: STD_LOGIC_VECTOR(2 downto 0);
signal reg_seven_in: STD_LOGIC_VECTOR(15 downto 0);


begin
    -- Port map the internal signals to the ALU.
    u0:alu port map(
        a => a,
        b => b,
        cl => cl,
        f => f,
        clk => clk,
        negative => negative, 
        zero => zero, 
        overflow => overflow, 
        result => result, 
        extra_16_bits => extra_16_bits,
        alu_enable => alu_enable,
        branch_op             =>  branch_op             ,
        branch_displacement   =>  branch_displacement   ,
        in_pc                 =>  in_pc                 ,
        out_pc                =>  out_pc                ,
        flush_pipeline        =>  flush_pipeline        ,
        wb_register_in        =>  wb_register_in        ,
        wb_register_out       =>  wb_register_out       ,
        reg_seven_in          =>  reg_seven_in       
    );
    
    -- Clock process. This just clocks the ALU automatically every 10us.
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    -- Test process. This feeds values into each signal to test that it matches the expected output.
    process begin
        -- Clear signals.
        a <= (others => '0'); b <= (others => '0'); cl <= "0000"; f <= "000";
        -- Enable ALU
        alu_enable <= '1';
        -- Add some delay before starting.
        wait until (clk = '0' and clk'event); wait until (clk='1' and clk'event); wait until (clk='1' and clk'event);
        wait until (clk = '1' and clk'event); 
        -- f = 'NOP'
        f <= "000";
        wait until (clk = '1' and clk'event);
        -- a = 0x0004, b = 0x0002, f = 'ADD', result should be 0x0006
        a <= (2 => '1', others => '0'); b <= (1 => '1', others => '0'); f <= "001";
        wait until (clk = '1' and clk'event);
        -- a = 0xFFFF, b = 0xFFFF, f = 'ADD', result should be 0xFFFE with overflow = 1
        a <= X"FFFF"; b <= X"FFFF";
        wait until (clk = '1' and clk'event);
        -- a = 0xFFFF, b = 0x7FFF, f = 'SUB', result should be 0x8000
        b <= X"7FFF"; f <= "010";
        wait until (clk = '1' and clk'event);
        -- a = 0x7FFF, b = 0x0010, f = 'SUB', result should be 0x7FEF
        a <= X"7FFF"; b <= X"0010";
        wait until (clk = '1' and clk'event);
        -- a = 0x7FFF, b = 0xFFFF, f = 'SUB', result should be 0x8000 with overflow = 1
        b <= X"FFFF";
        wait until (clk = '1' and clk'event);
        -- a = 0x0010, b = 0x0002, f = 'MUL', result should be 0x0020
        a <= X"0010"; b <= X"0002"; f <= "011";
        wait until (clk = '1' and clk'event);
        -- a = 0x0010, b = 0x8002, f = 'MUL', result should be 0x8020
        b <= X"8002";
        wait until (clk = '1' and clk'event);
        -- a = 0x7FFF, b = 0x0002, f = 'MUL', result should be 0x0000FFFE with overflow = 1
        a <= X"7FFF"; b <= X"0002";
        wait until (clk = '1' and clk'event);
        -- a = 0x7FFF, b = 0x8010, f = 'MUL', result should be 0x8007FFF0 with overflow = 1
        b <= X"8010";
        wait until (clk = '1' and clk'event);
        -- a = 0xFFFF, b = 0x0110, f = 'NAND', result should be 0xEDCB
        a <= X"FFFF"; b <= X"1234"; f <= "100";
        wait until (clk = '1' and clk'event);
        -- a = 0x0123, b = 0x1234, f = 'NAND', result should be 0xFFDF
        a <= X"0123";
        wait until (clk = '1' and clk'event);
        -- a = 0x000F, cl = 4, f = 'SHL', result should be 0x00F0
        a <= X"000F"; cl <= "0100"; f <= "101"; 
        wait until (clk = '1' and clk'event);
        -- a = 0xF000, cl = 4, f = 'SHL', result should be 0x0000
        a <= X"F000";
        wait until (clk = '1' and clk'event);
        -- a = 0xF000, cl = 4, f = 'SHR', result should be 0x0F00
        f <= "110";
        wait until (clk = '1' and clk'event);
        -- a = 0x000F, cl = 4, f = 'SHR', result should be 0x0000
        a <= X"000F";
        wait until (clk = '1' and clk'event);
        -- a = 0x0000, f = 'TEST', result should be zero = 1, negative = 0
        a <= X"0000"; f <= "111";
        wait until (clk = '1' and clk'event);
        -- a = 0x8000, f = 'TEST', result should be zero = 1, negative = 1
        a <= X"8000";
        wait until (clk = '1' and clk'event);
        -- a = 0x8001, f = 'TEST', result should be zero = 0, negative = 1
        a <= X"8001";
        wait until (clk = '1' and clk'event);
    end process;
end Behavioral;
