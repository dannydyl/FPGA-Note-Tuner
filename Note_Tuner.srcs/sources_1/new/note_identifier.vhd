----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2024 05:48:04 PM
-- Design Name: 
-- Module Name: note_identifier - Behavioral
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

entity note_identifier is
    port(
        clk_in            : in  std_logic;
        reset_n          : in  std_logic;
        raw_frequency  : in  std_logic_vector(15 downto 0);
        uart_tx_serial : out std_logic
    );
end note_identifier;

architecture Behavioral of note_identifier is

    -- Signals for internal connections
    signal debounced_frequency : std_logic_vector(15 downto 0);
    signal note_ascii          : std_logic_vector(7 downto 0);
    signal uart_tx_active      : std_logic;
    signal uart_tx_done        : std_logic;
    signal uart_tx_dv          : std_logic := '0';
    signal uart_tx_byte        : std_logic_vector(7 downto 0);
    signal uart_tx_data_valid  : std_logic := '0';
    signal send_ready          : std_logic;
    
    constant CLEAR_SCREEN : std_logic_vector(7 downto 0) := "00001100";  -- ASCII for Form Feed (FF)
begin

    -- Instantiate debounce_frequency
    debounce_frequency_inst : entity work.debounce_frequency
        port map (
            clk_in            => clk_in,
            reset_n           => reset_n,
            frequency         => raw_frequency,
            send_ready        => send_ready,
            debounced_frequency => debounced_frequency
        );

    -- Instantiate freq_analyzer
    freq_analyzer_inst : entity work.freq_analyzer
        port map (
            clk_in           => clk_in,
            reset_n         => reset_n,
            frequency     => debounced_frequency,
            note_ascii    => note_ascii
        );

     UART_TX : entity work.UART_TX
        generic map(g_CLKS_PER_BIT => 9600)
        port map (
            i_Clk       => clk_in,
            i_TX_DV     => uart_tx_dv,
            i_TX_Byte   => uart_tx_byte,
            o_TX_Active => uart_tx_active,
            o_TX_Serial => uart_tx_serial,
            o_TX_Done   => uart_tx_done
        );
        
         -- UART data transmission process
    process(clk_in, reset_n)
    variable index : integer := 0;
    begin
        if reset_n = '0' then
            uart_tx_dv <= '0';
            uart_tx_byte <= CLEAR_SCREEN;
            uart_tx_data_valid <= '0';
        elsif rising_edge(clk_in) then
            if send_ready = '1' then
                if uart_tx_done = '1' then
                    uart_tx_dv <= '0';  -- Deassert data valid signal once transmission is done
                    if index < 7 then
                        index := index + 1;
                    else
                        index := 0;
                    end if;
            elsif uart_tx_active = '0' then
                -- ASCII note transmission logic
                if uart_tx_data_valid = '0' then
                    uart_tx_byte <= note_ascii;  -- Send first character of note
                    uart_tx_data_valid <= '1';
                    uart_tx_dv <= '1';
                else
                    uart_tx_data_valid <= '0';
                    uart_tx_dv <= '0';
                end if;
            end if;
        end if;
     end if;
    end process;
end Behavioral;
