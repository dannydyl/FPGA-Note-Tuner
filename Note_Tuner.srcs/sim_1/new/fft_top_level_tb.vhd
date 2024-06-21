----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2024 10:16:51 PM
-- Design Name: 
-- Module Name: fft_top_level_tb - Behavioral
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

entity fft_top_level_tb is
end fft_top_level_tb;

architecture Behavioral of fft_top_level_tb is
    -- Component declaration of the top-level design
    component fft_top_level
        Port (
            clk_in            : in  std_logic;
            reset_n           : in  std_logic;  -- asynchronous reset
            fixed_data        : in  std_logic_vector(15 downto 0);
            data_valid        : in  std_logic;
            fft_ready         : out std_logic;
            fft_data_out      : out std_logic_vector(31 downto 0);
            fft_data_valid    : out std_logic
        );
    end component;

    -- Signals for driving the DUT (Device Under Test)
    signal clk_in         : std_logic := '0';
    signal reset_n        : std_logic := '0';
    signal fixed_data     : std_logic_vector(15 downto 0) := (others => '0');
    signal data_valid     : std_logic := '0';
    signal fft_ready      : std_logic;
    signal fft_data_out   : std_logic_vector(31 downto 0);
    signal fft_data_valid : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the DUT
    uut: fft_top_level
        Port map (
            clk_in         => clk_in,
            reset_n        => reset_n,
            fixed_data     => fixed_data,
            data_valid     => data_valid,
            fft_ready      => fft_ready,
            fft_data_out   => fft_data_out,
            fft_data_valid => fft_data_valid
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
    stimulus_process : process
    begin
        -- Reset the design
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        data_valid <= '1';
        wait for 50ns;
        -- Send input data samples
        for i in 0 to 1023 loop
            fixed_data <= std_logic_vector(to_unsigned(i, 16));
            wait until rising_edge(clk_in);
        end loop;
        
        wait for 100ns;
        data_valid <= '0';

        -- Wait for some time to observe the output
        wait for 200 ns;

        -- Stop the simulation
        wait;
    end process;
end Behavioral;
