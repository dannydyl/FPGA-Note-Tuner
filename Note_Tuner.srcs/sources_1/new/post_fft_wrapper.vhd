----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2024 04:58:10 PM
-- Design Name: 
-- Module Name: post_fft_wrapper - Behavioral
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

entity post_fft_wrapper is
    port(
        clk_in              : in std_logic;
        mag_in              : in std_logic_vector(31 downto 0);
        fft_index           : in std_logic_vector(9 downto 0);
        write_enable        : in std_logic;
        bram_data_out       : out std_logic_vector(31 downto 0);
        peak_frequency      : out std_logic_vector(15 downto 0)
    );
end post_fft_wrapper;

architecture Behavioral of post_fft_wrapper is
    -- Internal signals
    signal mag_out   : std_logic_vector(31 downto 0);
    signal read_ready: std_logic;
    signal read_addr : unsigned(9 downto 0);
begin
    -- Instantiate post_fft_bram
    post_fft_bram_inst : entity work.post_fft_bram
        port map (
            clk_in        => clk_in,
            write_enable  => write_enable,
            fft_index     => fft_index,
            mag_in        => mag_in,
            mag_out       => mag_out,
            read_addr     => read_addr,
            read_ready    => read_ready
        );
        
        -- Instantiate peak_detector
    peak_detector_inst : entity work.peak_detector
        port map (
            clk_in          => clk_in,
            bram_data       => mag_out,
            bram_data_out   => bram_data_out,
            read_ready      => read_ready,
            read_addr       => read_addr,
            peak_frequency  => peak_frequency
        );    

end Behavioral;
