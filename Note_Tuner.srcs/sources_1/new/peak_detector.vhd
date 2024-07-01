----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2024 02:19:33 AM
-- Design Name: 
-- Module Name: peak_detector - Behavioral
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

entity peak_detector is
    port(
        clk_in              : in std_logic;
        bram_data           : in std_logic_vector(31 downto 0);
        read_ready          : in std_logic;
        peak_frequency      : out std_logic_vector(15 downto 0)
        );
end peak_detector;

architecture Behavioral of peak_detector is
    signal max_mag : std_logic_vector(31 downto 0) := (others => '0');
    signal current_index : unsigned(9 downto 0) := (others => '0'); -- 9 bits for 512 indexes
    signal max_index : unsigned(9 downto 0) := (others => '0');
    signal frequency : unsigned(15 downto 0) := (others => '0');
    constant FREQUENCY_RESOLUTION : unsigned(31 downto 0) := to_unsigned(469, 32); -- 46.875 Hz scaled by 10
    signal debug : std_logic := '0';
begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if read_ready = '1' then
                if unsigned(bram_data) > unsigned(max_mag) then
                    max_mag <= bram_data;
                    max_index <= current_index;
                end if;
                if current_index < 511 then
                    current_index <= current_index + 1;
                else
                    debug <= '1';
                    -- Divide by 1000 to get the correct frequency
                    frequency <= resize((max_index * FREQUENCY_RESOLUTION) / 1000, 16);
                    peak_frequency <= std_logic_vector(resize(frequency, 16));
                    max_mag <= (others => '0');
                    current_index <= (others => '0');
                    max_index <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end Behavioral;
