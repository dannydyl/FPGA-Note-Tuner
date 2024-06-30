----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2024 05:35:09 PM
-- Design Name: 
-- Module Name: post_fft_wrapper_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity tb_post_fft_wrapper is
end tb_post_fft_wrapper;

architecture Behavioral of tb_post_fft_wrapper is
    -- Component Declaration for the Unit Under Test (UUT)
    component post_fft_wrapper
        port(
            clk_in              : in std_logic;
            mag_in              : in std_logic_vector(31 downto 0);
            fft_index           : in std_logic_vector(9 downto 0);
            write_enable        : in std_logic;
            peak_frequency      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for driving the UUT
    signal clk_in              : std_logic := '0';
    signal mag_in              : std_logic_vector(31 downto 0) := (others => '0');
    signal fft_index           : std_logic_vector(9 downto 0) := (others => '0');
    signal write_enable        : std_logic := '0';
    signal peak_frequency      : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: post_fft_wrapper
        port map (
            clk_in => clk_in,
            mag_in => mag_in,
            fft_index => fft_index,
            write_enable => write_enable,
            peak_frequency => peak_frequency
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period / 2;
        clk_in <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        mag_in <= (others => '0');
        fft_index <= (others => '0');
        write_enable <= '0';

        -- Wait for global reset to finish
        wait for 100 ns;

        -- Simulate writing magnitudes to BRAM
        for i in 0 to 511 loop
            mag_in <= std_logic_vector(to_unsigned(i * 2, 32));
            fft_index <= std_logic_vector(to_unsigned(i, 10));
            write_enable <= '1';
            wait for clk_period;
            write_enable <= '0';
            wait for clk_period;
        end loop;

        -- Wait for peak frequency detection
        wait for 100 ns;

        -- Check the peak frequency result
        assert peak_frequency = std_logic_vector(to_unsigned(511 * 469 / 1000, 16)) -- Adjust this value based on actual implementation
            report "Test failed: Incorrect peak frequency"
            severity error;

        -- Test finished
        wait;
    end process;

end Behavioral;

