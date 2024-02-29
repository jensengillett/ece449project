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

entity alu is
    Port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : out   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
end alu;

architecture Behavioral of alu is
begin  
    process (f, a, b, cl, clk)
    variable foo    :  STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
    variable result_17 : STD_LOGIC_VECTOR(16 DOWNTO 0) := (others => '0');
    variable result_32 : signed(31 DOWNTO 0) := (others => '0');
    variable temp_a, temp_b : signed(15 DOWNTO 0) := (others => '0');
    begin
        if(clk'event and clk='1') then
            result <= (others => '0');
            extra_16_bits <= (others => '0');
            case f is
                when "000" =>
                    -- NOP
                when "001" => 
                    result_17 := std_logic_vector(signed(a(15) & a) + signed(b(15) & b));  -- add
                    result <= result_17(15 DOWNTO 0);
                    overflow <= result_17(16);
                when "010" =>
                    result_17 := std_logic_vector(signed(a(15) & a) - signed(b(15) & b));  -- sub
                    result <= result_17(15 DOWNTO 0);
                    -- Overflow bit is set consistently wrong if one operand is negative; fix it
                    if((a(15) = '1' and b(15) = '0') or (a(15) = '0' and b(15) = '1')) then
                        overflow <= not result_17(16);
                    else
                        overflow <= result_17(16);
                    end if;
                when "011" => 
                    -- mul
                
                    -- We remove the negatives from the original operands before multiplication.
                    if(a(15) = '1' and b(15) = '1') then --two negatives
                        temp_a := signed('0' & a(14 DOWNTO 0));
                        temp_b := signed('0' & b(14 DOWNTO 0));
                    elsif(a(15) = '1' and b(15) = '0') then  -- a is negative
                        temp_a := signed('0' & a(14 DOWNTO 0));
                        temp_b := signed(b(15 DOWNTO 0));
                    elsif(a(15) = '0' and b(15) = '1') then -- b is negative
                        temp_a := signed(a(15 DOWNTO 0));
                        temp_b := signed('0' & b(14 DOWNTO 0));
                    else  -- neither is negative
                        temp_a := signed(a(15 DOWNTO 0));
                        temp_b := signed(b(15 DOWNTO 0));
                    end if;
                    
                    -- multiplication
                    result_32 := signed(temp_a) * signed(temp_b);
                    
                    -- If the result should have been negative, make it negative, otherwise make it positive.
                    if((a(15) = '1' and b(15) = '1') or (a(15) = '0' and b(15) = '0')) then
                        result_32(31) := '0';
                    else
                        result_32(31) := '1';
                    end if;
                    --report "The value of 'result_32' is " & integer'image(to_integer(result_32));
                    -- If the result would overflow a 16-bit value, handle accordingly
                    if(result_32(30 DOWNTO 15) /= X"0000") then
                        result <= std_logic_vector(result_32(15 DOWNTO 0));
                        extra_16_bits <= std_logic_vector(result_32(31 DOWNTO 16));
                        overflow <= '1';
                    else  -- 16-bit value fits in register
                        result <= std_logic_vector(result_32(31) & result_32(14 DOWNTO 0));
                        overflow <= '0';
                    end if;
                when "100" => 
                    result <= a NAND b;  -- nand
                when "101" => 
                    result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(cl)))); -- shl
                when "110" =>
                    result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(cl)))); -- shr
                when others =>  -- test
                    -- test for zero                    
                    if(a = foo) then
                        zero <= '1';
                    else
                        zero <= '0';
                    end if;
                    --test for negative
                    if(a(15) = '1') then
                        negative <= '1';
                    else
                        negative <= '1';
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
