----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2024 10:40:13 PM
-- Design Name: 
-- Module Name: fixed_data_bram - Behavioral
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
use ieee.numeric_std.all;

entity fixed_data_bram is
    port(
        clk_in : in std_logic;
        reset_n : in std_logic;
        write_enable : in std_logic;
        write_data : in std_logic_vector(15 downto 0);
        addr : in std_logic_vector(9 downto 0); -- 1024 addresses
        read_enable : out std_logic;
        read_data : out std_logic_vector(15 downto 0)      
        );
end fixed_data_bram;

architecture Behavioral of fixed_data_bram is
    
    -- define BRAM as an array of std_logic_vector
    type ram_type is array (0 to 1023) of std_logic_vector(15 downto 0);
    signal bram : ram_type := (others => (others => '0')); -- outer others is the 0 to 1023 elements and inner others is the vector 
    
    -- signal to keep track of the address
    signal write_addr : integer := 0;
    signal read_addr : integer := 0;
    
    signal state : std_logic := '0';
    -- attribute to infer BRAM
--    attribute ram_style : string;
--    attribute ram_style of bram : signal is "block";
    
begin

    write : process(clk_in, reset_n)
    begin
        if reset_n = '0' then
            write_addr <= 0;
            read_addr <= 0;
            state <= '0';
        elsif rising_edge(clk_in) then
            if state = '0' then
                if write_enable = '1' then
                    bram(write_addr) <= write_data;
                    write_addr <= write_addr + 1;
                    if write_addr = 1023 then
                        write_addr <= 0;
                    end if;
                    state <= '1';
                end if;
             else
                read_enable <= '1';
                read_data <= bram(read_addr);
                read_addr <= read_addr + 1;
                if read_addr = 1023 then
                    read_addr <= 0;
                end if;
                state <= '0';
            end if;
        end if;
    end process;    

    read : process(clk_in)
    begin
        if rising_edge(clk_in) then
            read_data <= bram(to_integer(unsigned(addr)));
        end if;
    end process;

    
end Behavioral;
