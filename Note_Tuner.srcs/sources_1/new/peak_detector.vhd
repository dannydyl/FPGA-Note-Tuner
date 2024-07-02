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
        read_addr           : in unsigned(9 downto 0);
        peak_frequency      : out std_logic_vector(15 downto 0)
        );
end peak_detector;

architecture Behavioral of peak_detector is
    signal max_mag : std_logic_vector(31 downto 0) := (others => '0');
    signal current_index : unsigned(9 downto 0) := (others => '0'); -- 9 bits for 512 indexes
    signal max_index : unsigned(9 downto 0) := (others => '0');
    signal frequency : unsigned(15 downto 0) := (others => '0');
    constant FREQUENCY_RESOLUTION : unsigned(7 downto 0) := to_unsigned(47, 8); -- 46.875 Hz scaled by 10
    signal debug : std_logic := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if read_ready = '1' then
                if unsigned(bram_data) > unsigned(max_mag) then
                    max_mag <= bram_data;
                    max_index <= read_addr;
                end if;
                if read_addr < 512 then
                    debug <= '1';
                else
                    -- end of stream
--                    frequency <= resize((max_index * FREQUENCY_RESOLUTION), 16);
--                    peak_frequency <= std_logic_vector(resize(frequency, 16));
                    peak_frequency <= std_logic_vector(resize(((max_index - 1) * FREQUENCY_RESOLUTION), 16));
                    max_mag <= (others => '0');
                    max_index <= (others => '0');
                    debug <= '0'; 
                end if;
            end if;
        end if;
    end process;
end Behavioral;
