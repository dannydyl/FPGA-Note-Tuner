----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2024 10:30:22 PM
-- Design Name: 
-- Module Name: note_identifier_tb - Behavioral
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

entity note_identifier_tb is
end note_identifier_tb;

architecture Behavioral of note_identifier_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component note_identifier
        port(
            clk_in          : in  std_logic;
            reset_n         : in  std_logic;
            raw_frequency   : in  std_logic_vector(15 downto 0);
            uart_tx_serial  : out std_logic
        );
    end component;

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- Signals for the testbench
    signal clk_in         : std_logic := '0';
    signal reset_n        : std_logic := '0';
    signal raw_frequency  : std_logic_vector(15 downto 0) := (others => '0');
    signal uart_tx_serial : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: note_identifier
        port map (
            clk_in          => clk_in,
            reset_n         => reset_n,
            raw_frequency   => raw_frequency,
            uart_tx_serial  => uart_tx_serial
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize signals
        reset_n <= '0';
        wait for 20 ns;

        reset_n <= '1';
        wait for 20 ns;
        
        -- Apply a frequency value to test note C
        raw_frequency <= std_logic_vector(to_unsigned(261, 16)); -- Frequency for C
        wait for 1000 ns;

        -- Apply a frequency value to test note D
        raw_frequency <= std_logic_vector(to_unsigned(293, 16)); -- Frequency for D
        wait for 1000 ns;
        
        -- Apply a frequency value to test failure (0 frequency)
        raw_frequency <= (others => '0');
        wait for 1000 ns;

        -- Apply another frequency value to test note E
        raw_frequency <= std_logic_vector(to_unsigned(329, 16)); -- Frequency for E
        wait for 1000 ns;

        -- Stop simulation
        wait;
    end process;

end Behavioral;
