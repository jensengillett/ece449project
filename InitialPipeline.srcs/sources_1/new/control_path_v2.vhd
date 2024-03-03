
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_control_path is
    Port ( 
        clk : in STD_LOGIC;
        control_reset : in STD_LOGIC;
        control_state : out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end simple_control_path;

architecture Behavioral of simple_control_path is
signal current_state : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
begin
    process(clk) begin
        if(rising_edge(clk)) then
            if(control_reset = '1') then
                current_state <= "0001";
            else
                case current_state is
                    when "0001" =>
                        current_state <= "0010";
                    when "0010" =>
                        current_state <= "0100";
                    when "0100" =>
                        current_state <= "1000";
                    when "1000" =>
                        current_state <= "0001";
                    when others =>
                        current_state <= "0001";
               end case;
            end if;
        end if;
    end process;
    
    control_state <= current_state;
end Behavioral;
