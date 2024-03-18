
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
   MEMORY_INIT_FILE => "formatb.mem",     -- String
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

ena <= '1';
data_out <= douta;
addra <= address;
clka <= clk;
injectdbiterra <= '0';
injectsbiterra <= '0';
regcea <= '1';
sleep <= '0';

end Behavioral;
