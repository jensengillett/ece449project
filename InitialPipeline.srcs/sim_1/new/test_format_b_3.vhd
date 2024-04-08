
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_format_b_3 is
--  Port ( );
end test_format_b_3;

architecture Behavioral of test_format_b_3 is

component control_path_v3 Port ( 
    out_pc : out std_logic_vector(15 downto 0);
    out_port: out std_logic_vector(15 downto 0);
    in_port: in std_logic_vector(15 downto 0);
    in_port_enable: in std_logic;
    in_clk: in std_logic;
    in_reg_reset: in std_logic
);
end component;
    
signal pc : std_logic_vector(15 downto 0);   
signal out_port: std_logic_vector(15 downto 0);  
signal in_port: std_logic_vector(15 downto 0);    
signal in_port_enable: std_logic;                      
signal clk: std_logic;
signal reg_rst: std_logic;
    
begin
    u0: control_path_v3 port map(
        out_pc => pc,
        out_port => out_port,
        in_port => in_port,
        in_port_enable => in_port_enable,
        in_clk => clk,
        in_reg_reset => reg_rst
    );
    
    -- Clock process. This just clocks the control path automatically every 10us.
    -- TODO: Hook this to hardware eventually
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    process begin
        wait until (pc'event);
        case pc is

            when X"0000" =>   -- Initial state setup. Not part of the ASM file.
                reg_rst <= '1';
                in_port_enable <= '0';
                in_port <= X"0000";
            when X"0004" => 
                reg_rst <= '0';
            when X"0A10" =>
                in_port_enable <= '1';
                in_port <= X"8002";  -- -2
            when X"0A12" =>
                in_port <= X"0003";
            when X"0A14" =>
                in_port <= X"0001";
            when X"0A16" =>
                in_port <= X"0005";
            when X"0A18" =>
                in_port <= X"0000";
                in_port_enable <= '0';
            when others =>
                
        end case;
    end process;

end Behavioral;