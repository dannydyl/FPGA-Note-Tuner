----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2024 08:29:36 PM
-- Design Name: 
-- Module Name: Note_tuner_top_level_tb - Behavioral
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
use IEEE.MATH_REAL.ALL; -- For sine function

entity Note_tuner_top_level_tb is
end Note_tuner_top_level_tb;

architecture Behavioral of Note_tuner_top_level_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component Note_tuner_top_level
        port(
            clk_in             : in  std_logic;                      -- system clock (100 MHz on Basys board)
            reset_n            : in  std_logic;                      -- active low asynchronous reset
            mclk               : out std_logic;                      -- master clock
            sclk               : out std_logic;                      -- serial clock (or bit clock)
            lrck               : out std_logic;                      -- word select (or left-right clock)
            sd_rx              : in  std_logic;                      -- serial data in
            uart_tx_serial     : out std_logic                       -- UART TX serial data
        );
    end component;

    -- Clock period definition
    constant clk_period : time := 10 ns; -- 100 MHz clock

    -- Signals for the testbench
    signal clk_in         : std_logic := '0';
    signal reset_n        : std_logic := '0';
    signal mclk           : std_logic;
    signal sclk           : std_logic;
    signal lrck           : std_logic;
    signal sd_rx          : std_logic := '0';
    signal uart_tx_serial : std_logic;

    -- Parameters for generating a sine wave
    constant sine_freq : real := 440.0;  -- Frequency of the sine wave (A4 note)
    constant sample_rate : real := 48000.0; -- Sampling rate
    constant num_samples : integer := 480; -- Number of samples to simulate

    -- Signal to hold the audio sample
    signal audio_sample : std_logic_vector(23 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: Note_tuner_top_level
        port map (
            clk_in          => clk_in,
            reset_n         => reset_n,
            mclk            => mclk,
            sclk            => sclk,
            lrck            => lrck,
            sd_rx           => sd_rx,
            uart_tx_serial  => uart_tx_serial
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period / 2;
        clk_in <= '1';
        wait for clk_period / 2;
    end process;

    -- Generate a 24-bit sine wave audio signal for sd_rx
    audio_signal_process : process
        variable phase : real := 0.0;
        variable sine_value : real;
        variable audio_sample_int : integer;
    begin
        -- Initialize signals
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        for i in 0 to num_samples - 1 loop
            -- Calculate the sine wave value
            phase := 2.0 * MATH_PI * sine_freq * real(i) / sample_rate;
            sine_value := sin(phase);

            -- Convert sine wave value to 24-bit signed integer
            audio_sample_int := integer(sine_value * (2**23 - 1));
            audio_sample <= std_logic_vector(to_signed(audio_sample_int, 24));

            -- Send the 24-bit audio sample over sd_rx
            for j in 23 downto 0 loop
                sd_rx <= audio_sample(j);
                wait for clk_period; -- Assuming 1 bit per clock cycle for simplicity
            end loop;
        end loop;

        -- Continue with other test cases as needed
        wait for 2000 ns;

        -- End of test
        wait;
    end process;

end Behavioral;

