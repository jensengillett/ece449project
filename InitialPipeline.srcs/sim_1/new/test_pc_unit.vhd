
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_pc_unit is
--  Port ( );
end test_pc_unit;

architecture Behavioral of test_pc_unit is

component pc_unit Port (
        clk: in STD_LOGIC;
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_reset: in STD_LOGIC;
        out_pc: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_enable: in STD_LOGIC;
     );
end component;

signal clk: STD_LOGIC;
signal in_pc, out_pc: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal in_pc_reset, in_pc_enable: STD_LOGIC;

begin
    u_pc: pc_unit port map(
        clk => clk,
        in_pc => in_pc,
        in_pc_reset => in_pc_reset,
        out_pc => out_pc,
        in_pc_enable => in_pc_enable
    );
    
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    process begin
        in_pc <= (others => '0'); in_pc_reset <= '1'; in_pc_enable <= '1';
        wait until (clk = '0' and clk'event); wait until (clk = '1' and clk'event); wait until (clk='1' and clk'event);
        in_pc_reset <= '0'; 
        while(true) loop
            wait until (clk='1' and clk'event);
        end loop;
    end process;

end Behavioral;
