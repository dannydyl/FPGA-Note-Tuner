----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2024 01:06:43 PM
-- Design Name: 
-- Module Name: fixed_data_bram_tb - Behavioral
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

entity tb_fixed_data_bram is
end tb_fixed_data_bram;

architecture Behavioral of tb_fixed_data_bram is
    -- Constants for clock period
    constant clk_period : time := 10 ns;

    -- Signal declarations
    signal clk_in : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal write_enable : std_logic := '0';
    signal write_data : std_logic_vector(15 downto 0) := (others => '0');
    signal read_addr : std_logic_vector(9 downto 0) := (others => '0');
    signal read_data : std_logic_vector(15 downto 0);

    -- Instantiate the DUT (Device Under Test)
    component fixed_data_bram
        port(
            clk_in : in std_logic;
            reset_n : in std_logic;
            write_enable : in std_logic;
            write_data : in std_logic_vector(15 downto 0);
            read_addr : in std_logic_vector(9 downto 0);
            read_data : out std_logic_vector(15 downto 0)      
        );
    end component;

begin
    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk_in <= '0';
            wait for clk_period / 2;
            clk_in <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- DUT instantiation
    uut : fixed_data_bram
        port map (
            clk_in => clk_in,
            reset_n => reset_n,
            write_enable => write_enable,
            write_data => write_data,
            read_addr => read_addr,
            read_data => read_data
        );

    -- Stimulus process
    stimulus : process
    begin
        -- Apply reset
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';
        wait for 20 ns;
        
        -- Write data to BRAM
        write_enable <= '1';
        for i in 0 to 1023 loop
            write_data <= std_logic_vector(to_unsigned(i, 16));
            wait for clk_period;
        end loop;
        write_enable <= '0';
        wait for 20 ns;

        -- Read back the data
        for i in 0 to 1023 loop
            read_addr <= std_logic_vector(to_unsigned(i, 10));
            wait for clk_period;
            assert read_data = std_logic_vector(to_unsigned(i, 16))
                report "Read data mismatch at address " & integer'image(i) severity error;
        end loop;

        -- End simulation
        wait;
    end process;

end Behavioral;
