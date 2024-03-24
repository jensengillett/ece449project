
-- ROM component
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

entity rom is
    Port ( 
        data_out: out std_logic_vector(15 downto 0);
        address: in std_logic_vector(7 downto 0);
        clk: in std_logic
    );
end rom;

-- ROM architecture definition
architecture Behavioral of rom is

signal dbiterra: std_logic;
signal douta: std_logic_vector(15 downto 0);
signal sbiterra: std_logic;
signal addra: std_logic_vector(7 downto 0);
signal clka: std_logic;
signal ena: std_logic;
signal injectdbiterra: std_logic;
signal injectsbiterra: std_logic;
signal regcea: std_logic;
signal rsta: std_logic;
signal sleep: std_logic;

begin
    -- From https://docs.xilinx.com/r/en-US/ug974-vivado-ultrascale-libraries/XPM_MEMORY_SPROM
    
    -- xpm_memory_sprom: Single Port ROM
    -- Xilinx Parameterized Macro, version 2023.2
    
    xpm_memory_sprom_inst : xpm_memory_sprom
    generic map (
       ADDR_WIDTH_A => 8,              -- DECIMAL
       AUTO_SLEEP_TIME => 0,           -- DECIMAL
       CASCADE_HEIGHT => 0,            -- DECIMAL
       ECC_BIT_RANGE => "7:0",         -- String
       ECC_MODE => "no_ecc",           -- String
       ECC_TYPE => "none",             -- String
       MEMORY_INIT_FILE => "formatb_testing.mem",     -- String
       MEMORY_INIT_PARAM => "",       -- String
       MEMORY_OPTIMIZATION => "true",  -- String
       MEMORY_PRIMITIVE => "auto",     -- String
       MEMORY_SIZE => 1024,            -- DECIMAL
       MESSAGE_CONTROL => 0,           -- DECIMAL
       RAM_DECOMP => "auto",           -- String
       READ_DATA_WIDTH_A => 16,        -- DECIMAL
       READ_LATENCY_A => 2,            -- DECIMAL
       READ_RESET_VALUE_A => "0",      -- String
       RST_MODE_A => "SYNC",           -- String
       SIM_ASSERT_CHK => 0,            -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       USE_MEM_INIT => 1,              -- DECIMAL
       USE_MEM_INIT_MMI => 0,          -- DECIMAL
       WAKEUP_TIME => "disable_sleep"  -- String
    )
    port map (
       dbiterra => dbiterra,             -- 1-bit output: Leave open.
       douta => douta,                   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
       sbiterra => sbiterra,             -- 1-bit output: Leave open.
       addra => addra,                   -- ADDR_WIDTH_A-bit input: Address for port A read operations.
       clka => clka,                     -- 1-bit input: Clock signal for port A.
       ena => ena,                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                         -- cycles when read operations are initiated. Pipelined internally.
    
       injectdbiterra => injectdbiterra, -- 1-bit input: Do not change from the provided value.
       injectsbiterra => injectsbiterra, -- 1-bit input: Do not change from the provided value.
       regcea => regcea,                 -- 1-bit input: Do not change from the provided value.
       rsta => rsta,                     -- 1-bit input: Reset signal for the final port A output register
                                         -- stage. Synchronously resets output port douta to the value specified
                                         -- by parameter READ_RESET_VALUE_A.
    
       sleep => sleep                    -- 1-bit input: sleep signal to enable the dynamic power saving feature.
    );
    -- End of xpm_memory_sprom_inst instantiation
    
    -- Pass the correct signals and values into the XPM_MEMORY_SPROM component.
    ena <= '1';
    data_out <= douta;
    addra <= address;
    clka <= clk;
    injectdbiterra <= '0';
    injectsbiterra <= '0';
    regcea <= '1';
    sleep <= '0';
end Behavioral;

-- RAM component

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

entity ram is
    Port ( 
        out_data_a: out std_logic_vector(15 downto 0);
        out_data_b: out std_logic_vector(15 downto 0);
        address_a: in std_logic_vector(15 downto 0);
        address_b: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        in_data_a: in std_logic_vector(15 downto 0);
        enable: in std_logic;
        in_write_a: in std_logic
    );
end ram;

architecture Behavioral of ram is

signal douta  : std_logic_vector(15 downto 0);
signal doutb  : std_logic_vector(15 downto 0);
signal addra  : std_logic_vector(15 downto 0);
signal addrb  : std_logic_vector(15 downto 0);
signal clka   : std_logic;
signal clkb   : std_logic;
signal dina   : std_logic_vector(15 downto 0);
signal ena    : std_logic;
signal enb    : std_logic;
signal regcea : std_logic;
signal regceb : std_logic;
signal rsta   : std_logic;
signal rstb   : std_logic;
signal wea    : std_logic_vector(0 downto 0);

begin
    -- xpm_memory_dpdistram: Dual Port Distributed RAM
    -- Xilinx Parameterized Macro, version 2023.2
    
    xpm_memory_dpdistram_inst : xpm_memory_dpdistram
    generic map (
       ADDR_WIDTH_A => 16,               -- DECIMAL
       ADDR_WIDTH_B => 16,               -- DECIMAL
       BYTE_WRITE_WIDTH_A => 16,        -- DECIMAL
       CLOCKING_MODE => "common_clock", -- String
       MEMORY_INIT_FILE => "none",      -- String
       MEMORY_INIT_PARAM => "0",        -- String
       MEMORY_OPTIMIZATION => "true",   -- String
       MEMORY_SIZE => 8192,             -- DECIMAL
       MESSAGE_CONTROL => 0,            -- DECIMAL
       READ_DATA_WIDTH_A => 16,         -- DECIMAL
       READ_DATA_WIDTH_B => 16,         -- DECIMAL
       READ_LATENCY_A => 0,             -- DECIMAL
       READ_LATENCY_B => 0,             -- DECIMAL
       READ_RESET_VALUE_A => "0",       -- String
       READ_RESET_VALUE_B => "0",       -- String
       RST_MODE_A => "SYNC",            -- String
       RST_MODE_B => "SYNC",            -- String
       SIM_ASSERT_CHK => 0,             -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
       USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
       USE_MEM_INIT => 1,               -- DECIMAL
       USE_MEM_INIT_MMI => 0,           -- DECIMAL
       WRITE_DATA_WIDTH_A => 16         -- DECIMAL
    )
    port map (
       douta => douta,   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
       doutb => doutb,   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
       addra => addra,   -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
       addrb => addrb,   -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
       clka => clka,     -- 1-bit input: Clock signal for port A. Also clocks port B when parameter
                         -- CLOCKING_MODE is "common_clock".
    
       clkb => clkb,     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                         -- "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
    
       dina => dina,     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
       ena => ena,       -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
                         -- or write operations are initiated. Pipelined internally.
    
       enb => enb,       -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
                         -- or write operations are initiated. Pipelined internally.
    
       regcea => regcea, -- 1-bit input: Clock Enable for the last register stage on the output data path.
       regceb => regceb, -- 1-bit input: Do not change from the provided value.
       rsta => rsta,     -- 1-bit input: Reset signal for the final port A output register stage. Synchronously
                         -- resets output port douta to the value specified by parameter READ_RESET_VALUE_A.
    
       rstb => rstb,     -- 1-bit input: Reset signal for the final port B output register stage. Synchronously
                         -- resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
    
       wea => wea        -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector for port A
                         -- input data port dina. 1 bit wide when word-wide writes are used. In byte-wide write
                         -- configurations, each bit controls the writing one byte of dina to address addra. For
                         -- example, to synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is
                         -- 32, wea would be 4'b0010.
    );
    
    -- End of xpm_memory_dpdistram_inst instantiation
    
    out_data_a <= douta;
    out_data_b <= doutb;
    addra <= address_a;
    addrb <= address_b;
    clka <= clk;
    -- clkb <= clk;
    dina <= in_data_a;
    ena <= enable;
    enb <= enable;
    regcea <= '1';
    regceb <= '1';
    wea(0) <= in_write_a;
end Behavioral;

-- Memory unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_unit is
    port(
        in_mem_op: in std_logic_vector(1 downto 0);
        enable_mem: in std_logic;
        clk: in std_logic
    );
end memory_unit;

architecture Behavioral of memory_unit is

component ram Port ( 
        out_data_a: out std_logic_vector(15 downto 0);
        out_data_b: out std_logic_vector(15 downto 0);
        address_a: in std_logic_vector(15 downto 0);
        address_b: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        in_data_a: in std_logic_vector(15 downto 0);
        enable: in std_logic;
        in_write_a: in std_logic
    );
end component;

signal out_data_a: std_logic_vector(15 downto 0);
signal out_data_b: std_logic_vector(15 downto 0);
signal address_a: std_logic_vector(15 downto 0);
signal address_b: std_logic_vector(15 downto 0);
signal in_data_a: std_logic_vector(15 downto 0);
signal in_write_a: std_logic;

begin
    u_ram: ram port map(
        out_data_a => out_data_a,
        out_data_b => out_data_b,
        address_a => address_a,
        address_b => address_b,
        clk => clk,
        in_data_a => in_data_a,
        enable => enable_mem,
        in_write_a => in_write_a
    );
    
    
end Behavioral;