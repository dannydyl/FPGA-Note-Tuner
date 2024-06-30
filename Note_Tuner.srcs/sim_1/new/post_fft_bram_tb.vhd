----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/28/2024 08:43:08 PM
-- Design Name: 
-- Module Name: post_fft_bram_tb - Behavioral
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

entity tb_post_fft_bram is
end tb_post_fft_bram;

architecture Behavioral of tb_post_fft_bram is
    -- Component Declaration for the Unit Under Test (UUT)
    component post_fft_bram
        port(
            clk_in          : in std_logic;
            write_enable    : in std_logic;
            fft_index       : in std_logic_vector(9 downto 0);
            mag_in          : in std_logic_vector(31 downto 0);
            mag_out         : out std_logic_vector(31 downto 0);
            read_ready      : out std_logic
        );
    end component;

    -- Signals for driving the UUT
    signal clk_in          : std_logic := '0';
    signal write_enable    : std_logic := '0';
    signal fft_index       : std_logic_vector(9 downto 0) := (others => '0');
    signal mag_in          : std_logic_vector(31 downto 0) := (others => '0');
    signal mag_out         : std_logic_vector(31 downto 0);
    signal read_ready      : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: post_fft_bram
        port map (
            clk_in => clk_in,
            write_enable => write_enable,
            fft_index => fft_index,
            mag_in => mag_in,
            mag_out => mag_out,
            read_ready => read_ready
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
        write_enable <= '0';
        fft_index <= (others => '0');
        mag_in <= (others => '0');

        -- Wait for global reset to finish
        wait for 100 ns;

        -- Writing data to BRAM
        for i in 0 to 511 loop
            write_enable <= '1';
            fft_index <= std_logic_vector(to_unsigned(i, 10));
            mag_in <= std_logic_vector(to_unsigned(i * 2, 32));
            wait for clk_period;
        end loop;

        -- Finish writing
        write_enable <= '0';
        wait for 20 ns;

        -- Check if read is ready
        wait until read_ready = '1';

        -- Reading data from BRAM
        for i in 0 to 511 loop
            wait for clk_period;
            assert mag_out = std_logic_vector(to_unsigned(i * 2, 32))
                report "Test failed at index " & integer'image(i)
                severity error;
        end loop;

        -- Test finished
        wait;
    end process;

end Behavioral;

