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
            data_last         : in std_logic;
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
    signal data_last      : std_logic;
    -- Clock period definition
    constant clk_period : time := 10 ns;
    
    signal ct : integer := 0;
begin
    -- Instantiate the DUT
    uut: fft_top_level
        Port map (
            clk_in         => clk_in,
            reset_n        => reset_n,
            fixed_data     => fixed_data,
            data_valid     => data_valid,
            data_last      => data_last,
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

    -- Sample data generation
    sample : process
    variable count : integer := 0;
    begin
        while true loop
            wait until rising_edge(clk_in);
            if fft_ready = '1' then
                fixed_data <= std_logic_vector(to_unsigned(ct, 16));
                data_valid <= '1';
                ct <= ct + 1;
                count := count + 1;
                data_last <= '0';
                if ct = 2048 then
                    ct <= 0;
                elsif count = 1023 then
                    count := 0;
                    data_last <= '1';
                end if;
                
            else
                data_valid <= '0';
            end if;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Reset the design
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        -- Wait for some time to observe the output
        wait for 10000 ns;

        -- Stop the simulation
        wait;
    end process;
end Behavioral;
