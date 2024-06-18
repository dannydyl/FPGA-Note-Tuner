----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 04:51:15 PM
-- Design Name: 
-- Module Name: Clock_Divider_tb - Behavioral
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

entity clock_divider_tb is
end clock_divider_tb;

architecture Behavioral of clock_divider_tb is



    -- Testbench signals
    signal clk_in   : std_logic := '0';
    signal reset    : std_logic := '0';
    signal mclk     : std_logic;
    signal sclk     : std_logic;
    signal lrck     : std_logic;

    -- Clock period definitions
    constant CLK_IN_PERIOD : time := 10 ns;  -- 100 MHz clock period

begin

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

    -- Instantiate the Unit Under Test (UUT)
    uut: entity clock_divider
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

    -- Stimulus Process
    stim_proc: process
    begin
        -- Reset the system
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        
        -- Wait for some time to observe the output clocks
        wait for 1 ms;
        
        -- Stop simulation
        wait;
    end process;

end Behavioral;
