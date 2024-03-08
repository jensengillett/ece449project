
-- Authors - Jensen Gillett, Jacob Sanders

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    Port ( 
        clk: in STD_LOGIC;
        decode_enable : in STD_LOGIC;
        instruction: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu_op: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        mem_op: out STD_LOGIC_VECTOR(1 DOWNTO 0);
        wb_op: out STD_LOGIC;
        read_1_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_2_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_select: out STD_LOGIC_VECTOR(2 DOWNTO 0);
        cl_value: out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- for SHL and SHR
        branch_op: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        branch_displacement: out STD_LOGIC_VECTOR(8 DOWNTO 0);
        -- TEMP FOR PRELIMINARY DESIGN REVIEW
        in_in_port: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        out_in_port: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_in_enable: in STD_LOGIC;
        out_in_enable: out STD_LOGIC;
        in_write_data: out STD_LOGIC_VECTOR(15 DOWNTO 0);
        in_port_index : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        out_enable: out STD_LOGIC
    );
end decoder;

architecture Behavioral of decoder is

begin
    process(clk) begin
        if(rising_edge(clk) and decode_enable = '1') then  -- Decode always occurs on rising edge.
            -- Move ra (output register) into between-stage storage.
            -- Thankfully, output (writeback) is always to ra, so we can just hardcode it.
            write_select <= instruction(8 DOWNTO 6);
            branch_op(7) <= '0'; -- branch disabled at the start of each cycle.
            -- This could be removed if there is a guarantee that all instructions will have MSB = 0
            -- i.e. not have any opcodes > 127
        
            -- Determine which registers get loaded into the register file dependant on opcode
            -- This is required because for _some reason_ there's inconsistency on which registers are read from.
            -- Some instructions read from rb and rc, while others read from ra.
            -- Thus we need to actually check so that we make sure to read the right data from the register file.
            if(instruction(15 DOWNTO 9) < "0000101") then   -- ADD, SUB, MUL, and NAND all read from rb and rc
                read_1_select <= instruction(5 DOWNTO 3);
                read_2_select <= instruction(2 DOWNTO 0);
            elsif(instruction(15 DOWNTO 9) >= "0000101" and instruction(15 DOWNTO 9) < "0100001") then  -- SHL, SHR, TEST, and OUT all read from ra
                read_1_select <= instruction(8 DOWNTO 6);
                read_2_select <= "000";
            end if;
            
            -- SHL and SHR use part of what would be rb/rc as cl.
            if((instruction(15 DOWNTO 9) = "0000101") or (instruction(15 DOWNTO 9) = "0000110")) then
                cl_value <= instruction(3 DOWNTO 0);
            else
                cl_value <= "0000";
            end if;
            
            -- Pass ALU mode to the ALU dependant on opcode.
            if(instruction(15 DOWNTO 9) < "0001000") then  -- ALU opcodes are from 0 to 7
                alu_op <= instruction(11 DOWNTO 9);  -- low three bits of opcode determine ALU operator
            else
                alu_op <= "000";
            end if;
            
            -- If this is a memory operation, we pass along the mem_opr flag.
            -- TODO: Format L instructions require this. Implement later!
            
            -- If this instruction writes data back to the register file, pass along the write flag.
            -- Writeback is enabled on format A instructions between 1 and 6.
            if((instruction(15 DOWNTO 9) > "0000000") and (instruction(15 DOWNTO 9) < "0000111")) then
                wb_op <= '1';
            --elsif (instruction(15 DOWNTO 9) = "0100001") then  -- 'IN'
                --wb_op <= '1';
            else
                wb_op <= '0';
            end if;
            
            -- Branch notes from March 07 lecture
            
            -- Could calculate branch address in decode stage (additional adder) to improve efficiency
            -- See pipeline notes starting at slide 261/262 (consider predict taken/not taken methods)
            -- Assume branch is not taken, if we reach a future stage and find out branch is taken, then clear previous stages.
            -- This does not affect state of pipeline since we have not written to anything (registers).
            
            -- Decode branch instructions (opcodes from 64 to 71)
            
            if ((instruction(15 DOWNTO 9) <= "1000010") and (instruction(15 DOWNTO 9) >= "1000000")) then     -- opcodes 64, 65, 66 are relative branches, so only provide displacement (Format B1)
            
                branch_displacement <= instruction(8 DOWNTO 0);
                branch_op <= ('1' & instruction(15 DOWNTO 9)); -- This system has no opcodes > 2^7 - 1, thus the 6th opcode bit is free for use
                -- Use this as a flag that a branch is occurring.    
                
            elsif ((instruction(15 DOWNTO 9) <= "1000110") and (instruction(15 DOWNTO 9) >= "1000011")) then     -- opcodes 67, 68, 69, 70 are absolute branches, provide displacement and register A (Format B2)
                
                branch_displacement <= ("000" & instruction(5 DOWNTO 0)); -- branch displacement is 9 bits long so pad displacement with 3 zeroes
                branch_op <= ('1' & instruction(15 DOWNTO 9)); -- see above comment
                read_1_select <= instruction(8 DOWNTO 6); -- rA register select
                
            elsif (instruction(15 DOWNTO 9) = "1110000") then -- opcode 71, RETURN
            
                branch_op <= ("1" & instruction(15 DOWNTO 9));    
                branch_displacement <= (others => '0');
                 
            else
                
                branch_op <= (others => '0');
                        
            end if;
            
            -- If this is an OUT instruction, tell the register file to read the data.
            -- TEMPORARY FOR PRELIMINARY DESIGN REVIEW
            if(instruction(15 DOWNTO 9) = "0100000") then
                out_enable <= '1';
            else
                out_enable <= '0';
            end if;
        elsif(falling_edge(clk) and decode_enable = '1') then  -- Latch for input port.
            if(instruction(15 DOWNTO 9) = "0100001") then
                in_port_index <= instruction(8 DOWNTO 6);
            else
                in_port_index <= "000";
            end if;
            out_in_port <= in_in_port;
            out_in_enable <= in_in_enable;
        end if;
    end process;

end Behavioral;
