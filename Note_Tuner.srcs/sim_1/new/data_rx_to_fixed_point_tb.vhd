----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2024 08:52:49 PM
-- Design Name: 
-- Module Name: data_rx_to_fixed_point_tb - Behavioral
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
use work.all;

entity data_rx_to_fixed_point_tb is
end data_rx_to_fixed_point_tb;

architecture Behavioral of data_rx_to_fixed_point_tb is
signal clk_in : std_logic;
signal reset_n : std_logic;
signal left_data_rx : std_logic_vector(23 downto 0);
signal right_data_rx : std_logic_vector(23 downto 0);
signal left_fixed : std_logic_vector(15 downto 0);
signal right_fixed : std_logic_vector(15 downto 0);
begin

    uut : entity data_rx_to_fixed_point
    port map(
        clk_in => clk_in,
        reset_n => reset_n,
        left_data_rx => left_data_rx,
        right_data_rx => right_data_rx,
        left_fixed => left_fixed,
        right_fixed => right_fixed
        );
        
        clock : process
        begin
            while true loop
                clk_in <= '0';
                wait for 10ns;
                clk_in <= '1';
                wait for 10ns;
            end loop;
       end process;
       
       tb : process
       begin
            reset_n <= '0';
            
            wait for 100ns;
            
            reset_n <= '1';
            
            wait for 50ns;
            
            left_data_rx <= "101101110111101111101111";
            
            wait for 50ns;
            
            right_data_rx <= "010010001000010000010000";
            
            wait for 50ns;
            
       end process;
            


end Behavioral;
