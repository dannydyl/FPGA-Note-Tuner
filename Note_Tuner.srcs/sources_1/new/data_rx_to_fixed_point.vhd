----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2024 11:37:23 PM
-- Design Name: 
-- Module Name: data_rx_to_fixed_point - Behavioral
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

entity data_rx_to_fixed_point is
    Port (
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        left_data_rx : in  std_logic_vector(23 downto 0);
        right_data_rx: in  std_logic_vector(23 downto 0);
        left_fixed   : out std_logic_vector(15 downto 0);
        right_fixed  : out std_logic_vector(15 downto 0)
    );
end data_rx_to_fixed_point;

architecture Behavioral of data_rx_to_fixed_point is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                left_fixed <= (others => '0');
                right_fixed <= (others => '0');
            else
            -- might need better approach such as normalizing and scaling before just simply truncating. study how other ppl did and make sure of this entity
                -- Scale down 24-bit to 16-bit fixed-point (Q1.15)
                left_fixed <= std_logic_vector(resize(signed(left_data_rx(23 downto 8)), 16));
                right_fixed <= std_logic_vector(resize(signed(right_data_rx(23 downto 8)), 16));
            end if;
        end if;
    end process;
end Behavioral;

