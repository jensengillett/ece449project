
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc_unit is
    Port (
        clk: in STD_LOGIC;
        in_pc: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_reset: in STD_LOGIC := '0';
        in_pc_assign: in STD_LOGIC := '0';
        out_pc: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_pc_enable: in STD_LOGIC
     );
end pc_unit;

architecture Behavioral of pc_unit is
signal current_pc: STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
begin

process(clk) begin
    if(rising_edge(clk) and in_pc_enable = '1') then
        if (in_pc_reset = '1') then
            current_pc <= X"0000";
        elsif (in_pc_assign = '1') then
            current_pc <= in_pc;
        else
            current_pc <= STD_LOGIC_VECTOR(unsigned(current_pc) + 2);
        end if;
    end if;
end process;

out_pc <= current_pc;

end Behavioral;
