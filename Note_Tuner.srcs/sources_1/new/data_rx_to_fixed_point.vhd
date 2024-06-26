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
-- 여기 굳이 클락이 있어야되나 싶은데 
entity data_rx_to_fixed_point is
    Port (
--        clk_in          : in  std_logic;
--        reset_n      : in  std_logic;
        left_data_rx : in  std_logic_vector(23 downto 0);
        right_data_rx: in  std_logic_vector(23 downto 0);
        fixed_data : out std_logic_vector(15 downto 0)
    );
end data_rx_to_fixed_point;

architecture Behavioral of data_rx_to_fixed_point is
    signal left_signed  : signed(23 downto 0);
    signal right_signed : signed(23 downto 0);
    signal average      : signed(23 downto 0);
begin

--                Convert input to signed
                left_signed <= signed(left_data_rx);
                right_signed <= signed(right_data_rx);
                
                -- Average the left and right channel data
                average <= (resize(left_signed, 24) + resize(right_signed, 24)) / 2;

                -- Convert the average to Q1.15 fixed-point format
                fixed_data <= std_logic_vector(resize(average(23 downto 8), 16));
--    process(clk_in)
--    begin
--        if rising_edge(clk_in) then
--            if reset_n = '0' then
--                fixed_data <= (others => '0');
--            else
--                -- Convert input to signed
--                left_signed <= signed(left_data_rx);
--                right_signed <= signed(right_data_rx);
                
--                -- Average the left and right channel data
--                average <= (resize(left_signed, 24) + resize(right_signed, 24)) / 2;

--                -- Convert the average to Q1.15 fixed-point format
--                fixed_data <= std_logic_vector(resize(average(23 downto 8), 16));
--            end if;
--        end if;
--    end process;
end Behavioral;

