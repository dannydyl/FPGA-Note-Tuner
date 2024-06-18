----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 11:02:52 PM
-- Design Name: 
-- Module Name: i2s_receiver_tb - Behavioral
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
use work.all;

entity i2s_receiver_tb is
end i2s_receiver_tb;

architecture Behavioral of i2s_receiver_tb is

    -- Component Declaration for the Unit Under Test (UUT)
--    component i2s_receiver
--        Port (
--            clk_in    : in  std_logic;
--            reset     : in  std_logic;
--            sdout     : in  std_logic;
--            left_data  : out std_logic_vector(23 downto 0);
--            right_data : out std_logic_vector(23 downto 0)
--        );
--    end component;

    -- Testbench Signals
    signal clk_in    : std_logic := '0';
    signal reset     : std_logic := '0';
    signal sdin   : std_logic := '0';
    signal left_data  : std_logic_vector(23 downto 0);
    signal right_data : std_logic_vector(23 downto 0);

    signal mclk     : std_logic;
    signal sclk     : std_logic;
    signal lrck     : std_logic;

    -- Clock Period Definitions
    constant CLK_IN_PERIOD : time := 10 ns;  -- 100 MHz clock period

    -- Simulated I2S Data
    constant LEFT_SAMPLE  : std_logic_vector(23 downto 0) := "101001000100001000000000";  -- Example left channel data
    constant RIGHT_SAMPLE : std_logic_vector(23 downto 0) := "101001000100001000000000";  -- Example right channel data
    -- Derived Clock Signals

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity i2s_receiver
        Port map (
            clk_in    => clk_in,
            reset     => reset,
            sdin     => sdin,
            left_data  => left_data,
            right_data => right_data
        );
        
    uut1: entity clock_divider
        generic map (
            INPUT_CLK_FREQ => 100_000_000,  -- 100 MHz input clock
            MCLK_FREQ      => 12_288_000,   -- 12.288 MHz MCLK
            SCLK_FREQ      => 2_304_000,    -- 2.304 MHz SCLK
            LRCK_FREQ      => 48_000        -- 48 kHz LRCK
        )
        port map (
            clk_in => clk_in,
            reset  => reset,
            mclk   => mclk,
            sclk   => sclk,
            lrck   => lrck
        );
 -- Clock Generation
    clk_gen : process
    begin
        while true loop
            clk_in <= '0';
            wait for CLK_IN_PERIOD / 2;
            clk_in <= '1';
            wait for CLK_IN_PERIOD / 2;
        end loop;
    end process;



    -- Stimulus Process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Wait for clocks to stabilize
        wait for 40 ns;

        -- Send LEFT_SAMPLE data
        for i in 0 to 23 loop
            wait until rising_edge(sclk);
            sdin <= LEFT_SAMPLE(23 - i);
        end loop;

        -- Wait for LRCK to switch to right channel
        wait until lrck = '1';

        -- Send RIGHT_SAMPLE data
        for i in 0 to 23 loop
            wait until rising_edge(sclk);
            sdin <= RIGHT_SAMPLE(23 - i);
        end loop;

        -- Wait for some time to observe the output data
        wait for 500 ns;

        -- Stop simulation
        wait;
    end process;

end Behavioral;

