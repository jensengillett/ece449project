----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2024 04:33:32 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : out   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
end alu;

architecture Behavioral of alu is
begin  
    process (f, a, b, cl, clk)
    variable foo    :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    begin
        if(clk'event and clk='1') then
            result <= (others => '0');
            case f is
                when "000" =>
                    -- NOP
                when "001" => 
                    result <= a + b;  -- add
                    -- TODO: ADD OVERFLOW
                when "010" =>
                    result <= a - b;  -- sub
                    -- TODO: ADD OVERFLOW
                when "011" => 
                    -- mul
                    -- TODO: ADD OVERFLOW
                when "100" => 
                    result <= a NAND b;  -- nand
                when "101" => 
                    result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(cl)))); -- shl
                when "110" =>
                    result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(cl)))); -- shr
                when others =>  -- test
                    -- test for zero                    
                    foo := (others => '0');
                    if(a = foo) then
                        zero <= '1';
                    else
                        zero <= '0';
                    end if;
                    --test for negative
                    if(a = (15 => '1')) then
                        negative <= '1';
                    else
                        negative <= '1';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
