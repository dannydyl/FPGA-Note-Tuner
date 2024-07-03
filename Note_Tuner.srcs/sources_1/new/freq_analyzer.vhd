----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2024 05:38:44 PM
-- Design Name: 
-- Module Name: freq_analyzer - Behavioral
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
use ieee.numeric_std.all;


entity freq_analyzer is
    port(
        clk_in           : in  std_logic;
        reset_n         : in  std_logic;
        frequency     : in  std_logic_vector(15 downto 0);
        note_ascii    : out std_logic_vector(7 downto 0)  -- 8 characters * 8 bits = 64 bits
    );
end freq_analyzer;

architecture Behavioral of freq_analyzer is
    signal freq : unsigned(15 downto 0);
begin

    process(clk_in, reset_n)
    begin
        if reset_n = '0' then
            note_ascii <= (others => '0');
        elsif rising_edge(clk_in) then
            freq <= unsigned(frequency);

                -- Determine the note based on frequency ranges
                -- 4th octave full notes
                if (freq >= to_unsigned(256, 16) and freq < to_unsigned(279, 16)) then
                    note_ascii <= "01000011"; -- ASCII for 'C'
                elsif (freq >= to_unsigned(279, 16) and freq < to_unsigned(311, 16)) then
                    note_ascii <= "01000100"; -- ASCII for 'D'
                elsif (freq >= to_unsigned(311, 16) and freq < to_unsigned(339, 16)) then
                    note_ascii <= "01000101"; -- ASCII for 'E'
                elsif (freq >= to_unsigned(339, 16) and freq < to_unsigned(370, 16)) then
                    note_ascii <= "01000110"; -- ASCII for 'F'
                elsif (freq >= to_unsigned(370, 16) and freq < to_unsigned(416, 16)) then
                    note_ascii <= "01000111"; -- ASCII for 'G'
                elsif (freq >= to_unsigned(416, 16) and freq < to_unsigned(467, 16)) then
                    note_ascii <= "01000001"; -- ASCII for 'A'
                elsif (freq >= to_unsigned(467, 16) and freq < to_unsigned(523, 16)) then
                    note_ascii <= "01000010"; -- ASCII for 'B'
                else
                    note_ascii <= (others => '0'); -- Default case, invalid frequency range
                end if;
            end if;

    end process;


end Behavioral;
