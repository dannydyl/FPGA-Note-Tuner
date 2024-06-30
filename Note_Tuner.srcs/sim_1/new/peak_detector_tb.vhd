----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2024 11:13:44 AM
-- Design Name: 
-- Module Name: peak_detector_tb - Behavioral
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

entity tb_peak_detector is
end tb_peak_detector;

architecture Behavioral of tb_peak_detector is
    -- Component Declaration for the Unit Under Test (UUT)
    component peak_detector
        port(
            clk_in          : in std_logic;
            bram_data       : in std_logic_vector(31 downto 0);
            read_ready      : in std_logic;
            peak_frequency  : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for driving the UUT
    signal clk_in          : std_logic := '0';
    signal bram_data       : std_logic_vector(31 downto 0) := (others => '0');
    signal read_ready      : std_logic := '0';
    signal peak_frequency  : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;
    constant FFT_SIZE : integer := 1024;  -- FFT size is 1024

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: peak_detector
        port map (
            clk_in => clk_in,
            bram_data => bram_data,
            read_ready => read_ready,
            peak_frequency => peak_frequency
        );

    -- Clock generation process
    clk_process :process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        bram_data <= (others => '0');
        read_ready <= '0';

        -- Wait for global reset to finish
        wait for 100 ns;

        -- Simulate BRAM data reading
        for i in 0 to 511 loop
            bram_data <= std_logic_vector(to_unsigned(i * 2, 32));
            read_ready <= '1';
            wait for clk_period;
        end loop;


        -- Test finished
        wait;
    end process;

end Behavioral;
