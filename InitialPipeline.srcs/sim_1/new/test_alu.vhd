----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2024 05:36:35 PM
-- Design Name: 
-- Module Name: test_alu - Behavioral
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

entity test_alu is
    --  Port ( );
end test_alu;


architecture Behavioral of test_alu is

component alu port(
    a, b    : in    STD_LOGIC_VECTOR(15 DOWNTO 0);
    cl      : in    STD_LOGIC_VECTOR(3 DOWNTO 0);
    f       : in    STD_LOGIC_VECTOR(2 DOWNTO 0);
    clk     : in    STD_LOGIC;
    negative, zero, overflow : out   STD_LOGIC;
    result, extra_16_bits  : out   STD_LOGIC_VECTOR(15 DOWNTO 0)
);
end component;

signal a, b    : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal cl      : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal f       : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal clk     : STD_LOGIC;
signal negative, zero, overflow : STD_LOGIC;
signal result, extra_16_bits  : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin
    u0:alu port map(a, b, cl, f, clk, negative, zero, overflow, result, extra_16_bits);
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    process begin
        a <= (others => '0'); b <= (others => '0'); cl <= "0000"; f <= "000";
        wait until (clk = '0' and clk'event); wait until (clk='1' and clk'event); wait until (clk='1' and clk'event);
        wait until (clk = '1' and clk'event); 
        a <= (2 => '1', others => '0'); b <= (1 => '1', others => '0'); f <= "001";
        wait until (clk = '1' and clk'event);
        a <= X"000F"; f <= "101"; cl <= "0100";
        wait until (clk = '1' and clk'event);
        a <= X"FFFF"; b <= X"FFFF"; f <= "001";
        wait until (clk = '1' and clk'event);
        b <= X"7FFF"; f <= "010";
        wait until (clk = '1' and clk'event);
        a <= X"7FFF"; b <= X"0010";
        wait until (clk = '1' and clk'event);
        a <= X"7FFF"; b <= X"FFFF";
        wait until (clk = '1' and clk'event);
        a <= X"0010"; b <= X"0002"; f <= "011";
        wait until (clk = '1' and clk'event);
        a <= X"0010"; b <= X"8002";
        wait until (clk = '1' and clk'event);
        a <= X"7FFF"; b <= X"0002";
        wait until (clk = '1' and clk'event);
        b <= X"8010";
        wait until (clk = '1' and clk'event);
    end process;
end Behavioral;
