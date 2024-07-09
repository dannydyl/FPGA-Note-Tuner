----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2024 04:53:56 PM
-- Design Name: 
-- Module Name: debounce_frequency - Behavioral
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

entity debounce_frequency is
    port(
        clk_in      : in std_logic;
        reset_n     : in std_logic;
        frequency   : in std_logic_vector(15 downto 0);
        send_ready  : out std_logic := '0';
        debounced_frequency : out std_logic_vector(15 downto 0)
    );
end debounce_frequency;

architecture Behavioral of debounce_frequency is
    -- define state type
    type state_type is (init_state, get_peak_frequency_state, wait_for_state, output_state);
    signal current_state, next_state : state_type;
    
    -- signal for FSM output
    signal debounced_frequency_internal : std_logic_vector(15 downto 0);
    
    -- Counter signal for wait state
    signal wait_counter : unsigned(12 downto 0) := (others => '0');  -- 13 bits to count up to 5000

    constant WAIT_COUNT : unsigned(12 downto 0) := to_unsigned(50000, 13);
    
    -- debug
    signal debug : std_logic := '0';
begin

    -- state register process
    process(clk_in, reset_n)
    begin
        if reset_n = '0' then
            current_state <= init_state;
        elsif rising_edge(clk_in) then
            current_state <= next_state;
            if current_state = wait_for_state then
                if wait_counter < WAIT_COUNT then
                    wait_counter <= wait_counter + 1;
                else
                    wait_counter <= (others => '0');
                end if;
            else
                wait_counter <= (others => '0');
            end if;
        end if;
    end process;
    
    -- next state logic process
    process(current_state, clk_in)
    begin
        case current_state is
            when init_state =>
                debounced_frequency_internal <= (others => '0');
                next_state <= get_peak_frequency_state;
                send_ready <= '0';
                
            when get_peak_frequency_state =>
                debounced_frequency_internal <= frequency;
                next_state <= wait_for_state;
                
            when wait_for_state =>
                if wait_counter = WAIT_COUNT then
                debug <= '1';
                    next_state <= output_state;
                else
                    next_state <= wait_for_state;
                end if;
            
            when output_state =>
                if debounced_frequency_internal = frequency then
                    debounced_frequency <= debounced_frequency_internal;
                else
                    debounced_frequency <= (others => '0');
                end if;
                next_state <= init_state;                
                send_ready <= '1';
        
            when others =>
                next_state <= init_state;
        end case;   
    end process;
end Behavioral;
