
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_format_b is
--  Port ( );
end test_format_b;

architecture Behavioral of test_format_b is

component control_path_v3 Port ( 
    out_pc : out std_logic_vector(15 downto 0);
    out_port: out std_logic_vector(15 downto 0);
    in_port: in std_logic_vector(15 downto 0);
    in_enable: in std_logic;
    in_clk: in std_logic;
    in_reg_reset: in std_logic
);
end component;
    
signal pc : std_logic_vector(15 downto 0);   
signal out_port: std_logic_vector(15 downto 0);  
signal in_port: std_logic_vector(15 downto 0);    
signal in_enable: std_logic;                      
signal clk: std_logic;
signal reg_rst: std_logic;
    
begin
    u0: control_path_v3 port map(
        out_pc => pc,
        out_port => out_port,
        in_port => in_port,
        in_enable => in_enable,
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
            -- For some reason there's an offset set at the start of the assembly file that makes it not have data until 0x0216.
            -- This was not replicated here.
            
    /*      IN r1   ; 01
		    IN r2	; 03
		    IN r3	; 05
		    NOP
		    NOP
		    ADD r4, r1, r1
		    ADD r5, r2, r2
		    ADD r6, r3, r3
		    TEST r4
		    BRR.n 40
		    ADD r4, r1, r2
		    ADD r5, r2, r3
		    ADD r6, r1, r3 */
		
            when X"0000" =>   -- Initial state setup. Not part of the ASM file.
                reg_rst <= '1';
                in_enable <= '0';
                in_port <= X"0000";
            when X"0004" => 
                reg_rst <= '0';
                in_enable <= '1';
                in_port <= X"0001";
            when X"0006" =>
                in_enable <= '1';
                in_port <= X"0003";
            when X"0008" =>
                in_enable <= '1';
                in_port <= X"0005";
            when X"0010" =>
                in_port <= X"0000";
                in_enable <= '0';
            when others =>
                
               
        end case;
    end process;

end Behavioral;