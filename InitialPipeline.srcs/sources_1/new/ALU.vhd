
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Declare the ALU ports as an entity.
entity alu is
    Port(
        a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
        cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
        f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
        clk     : in    STD_LOGIC;
        negative, zero, overflow : out   STD_LOGIC;
        result  : out   STD_LOGIC_VECTOR(15 DOWNTO 0);
        extra_16_bits : out STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_enable: in  STD_LOGIC;
        -- Data for branching
        branch_op: in STD_LOGIC_VECTOR(6 DOWNTO 0);
        branch_displacement: in STD_LOGIC_VECTOR(8 DOWNTO 0)
    );
end alu;

-- Start architecture definition.
architecture Behavioral of alu is 

begin 
    process (clk)  -- define local inputs
    -- Set up some internal variables used for different operations.
    variable foo    :  STD_LOGIC_VECTOR(14 DOWNTO 0) := (others => '0');  -- 15-bit, all zeros (for testing against zero)
    variable result_17 : STD_LOGIC_VECTOR(16 DOWNTO 0) := (others => '0');  -- Used for ADD/SUB results
    variable result_32 : signed(31 DOWNTO 0) := (others => '0');  -- Used for MUL results
    variable temp_a, temp_b : signed(15 DOWNTO 0) := (others => '0');  -- Used for MUL operands
    begin -- Begin process
        if(rising_edge(clk) and alu_enable = '1') then  -- On each clock tick
            result <= (others => '0'); -- reset result signal
            extra_16_bits <= (others => '0');  -- reset MUL extra bits
            negative <= '0'; zero <= '0'; overflow <= '0';  -- reset flags
            
            if (branch_op(6) = '1') then -- take branch actions when required
            
                -- do stuff
            
            else -- otherwise do regular ALU calculations
                case f is
                    when "000" =>  -- NOP
                        -- No inputs, no outputs.
                    when "001" =>  -- ADD
                        -- Perform signed addition. We sign-extend a and b beforehand to get the correct 17-bit result with overflow.
                        result_17 := std_logic_vector(signed(a(15) & a) + signed(b(15) & b));  
                        result <= result_17(15 DOWNTO 0);  -- Store the 16-bit true result.
                        overflow <= result_17(16);  -- Store overflow bit.
                    when "010" =>  -- SUB
                        -- Perform signed subtraction. See addition above.
                        result_17 := std_logic_vector(signed(a(15) & a) - signed(b(15) & b)); 
                        result <= result_17(15 DOWNTO 0);
                        -- Overflow bit is set consistently wrong if one operand (but not both) is negative; this if/else fixes the overflow bit.
                        if((a(15) = '1' and b(15) = '0') or (a(15) = '0' and b(15) = '1')) then
                            overflow <= not result_17(16);
                        else
                            overflow <= result_17(16);
                        end if;
                    when "011" => -- MUL
                        -- Amazingly, this actually completes in one cycle, meaning all operations in this ALU complete in one cycle.
                        -- This makes things nice when this is integrated with the rest of the system.
                    
                        -- We remove the negatives from the original operands before multiplication.
                        -- Multiplication results are always provably positive or negative dependant on operands.
                        -- If we don't do this, the sign extension we'd have to do later screws all the calculations up.
                        temp_a := signed('0' & a(14 DOWNTO 0));
                        temp_b := signed('0' & b(14 DOWNTO 0));
                        
                        -- Perform signed multiplication of two 16-bit variables into a 32-bit variable.
                        result_32 := signed(temp_a) * signed(temp_b);
                        
                        -- If the result should have been negative, make it negative, otherwise make it positive.
                        -- (This is doing the inverse of what we did before the multiplication)
                        if((a(15) = '1' and b(15) = '1') or (a(15) = '0' and b(15) = '0')) then
                            result_32(31) := '0';
                        else
                            result_32(31) := '1';
                        end if;
                        
                        -- If the result would overflow a 16-bit value, we raise the overflow flag and store
                        -- the extra bits into the 'extra_16_bits' signal.
                        -- Otherwise, we just store the 16-bit value.
                        if(result_32(30 DOWNTO 15) /= X"0000") then  -- 32-bit values have sign at position 31. We check the next 16 values.
                            result <= std_logic_vector(result_32(15 DOWNTO 0));
                            extra_16_bits <= std_logic_vector(result_32(31 DOWNTO 16));
                            overflow <= '1';
                        else  -- 16-bit value fits in the regular output register.
                            result <= std_logic_vector(result_32(31) & result_32(14 DOWNTO 0));
                            overflow <= '0';
                        end if;
                    when "100" =>  -- NAND
                        result <= a NAND b;  
                    when "101" =>  -- SHL (Shift Left)
                        -- Both SHL and SHR use the built-in NUMERIC_STD operators, but they require type conversion of a and cl to unsigned and integer, respectively.
                        result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(cl))));
                        -- TODO: Because this operator (and SHR) write the output to the same register as the input, for one cycle the input becomes the output value.
                        -- This does not affect the correctness of the code; it is an issue with the 'fake concurrency' method we're using to pipeline.
                    when "110" =>  -- SHR (Shift Right)
                        result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(cl))));
                    when others =>  -- TEST
                        -- test for zero                    
                        if(a(14 DOWNTO 0) = foo) then
                            zero <= '1';
                        else
                            zero <= '0';
                        end if;
                        --test for negative
                        if(a(15) = '1') then
                            negative <= '1';
                        else
                            negative <= '0';
                        end if;
                end case;
            end if;          
        end if;
    end process;

end Behavioral;
