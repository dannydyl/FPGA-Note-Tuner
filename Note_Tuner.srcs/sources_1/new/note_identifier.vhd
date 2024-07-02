----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2024 05:48:04 PM
-- Design Name: 
-- Module Name: note_identifier - Behavioral
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

entity note_identifier is
    port(
        clk_in            : in  std_logic;
        reset_n          : in  std_logic;
        raw_frequency  : in  std_logic_vector(15 downto 0);
        note_ascii_out : out std_logic_vector(63 downto 0)
    );
end note_identifier;

architecture Behavioral of note_identifier is

    -- Signals for internal connections
    signal debounced_frequency : std_logic_vector(15 downto 0);
    
begin

    -- Instantiate debounce_frequency
    debounce_frequency_inst : entity work.debounce_frequency
        port map (
            clk_in            => clk_in,
            reset_n           => reset_n,
            frequency         => raw_frequency,
            debounced_frequency => debounced_frequency
        );

    -- Instantiate freq_analyzer
    freq_analyzer_inst : entity work.freq_analyzer
        port map (
            clk_in           => clk_in,
            reset_n         => reset_n,
            frequency     => debounced_frequency,
            note_ascii    => note_ascii_out
        );

end Behavioral;
