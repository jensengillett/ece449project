
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Since this is a simulation module, we don't define any ports.
entity test_control_path is
--  Port ( );
end test_control_path;

-- Start architecture definition.
architecture Behavioral of test_control_path is

component control_path port(
    clk : in STD_LOGIC;
    OUT_PORT: out STD_LOGIC_VECTOR(15 DOWNTO 0);
    IN_PORT: in STD_LOGIC_VECTOR(15 DOWNTO 0);
    pc: inout STD_LOGIC_VECTOR(15 DOWNTO 0);
    loaded_value : in STD_LOGIC_VECTOR(15 DOWNTO 0)
);
end component;

-- Set up internal signals to manipulate control path
signal clk : STD_LOGIC := '0';
signal out_port : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_port : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal loaded_value : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin
    u_ctrl: control_path port map(
        clk => clk,
        OUT_PORT => out_port,
        IN_PORT => in_port,
        pc => pc,
        loaded_value => loaded_value
    );
    
    -- Clock process. This just clocks the control path automatically every 10us.
    -- TODO: Does this work on the BASYS 3, or just in sim?
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;

    -- TEMPORARY: For Preliminary Design Review, this loads values based on the PC from fake memory.
    process begin
        wait until (pc'event);
        case pc is
            -- For some reason there's an offset set at the start of the assembly file that makes it not have data until 0x0216.
            -- This was replicated here just in case it was important.
            when X"0216" =>
                loaded_value <= X"4240";
                in_port <= X"3";
            when X"0218" =>
                loaded_value <= X"4280";
                in_port <= X"5";
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
