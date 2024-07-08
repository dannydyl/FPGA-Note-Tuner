----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/05/2024 09:01:07 PM
-- Design Name: 
-- Module Name: Note_tuner_top_level - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Include the Xilinx UNISIM library
library UNISIM;
use UNISIM.VComponents.all;

entity Note_tuner_top_level is
    port(
        clk_in             : in  std_logic;                      -- system clock (100 MHz on Basys board)
        reset_n            : in  std_logic;                      -- active low asynchronous reset
        mclk               : out std_logic;                      -- master clock
        sclk               : out std_logic;                      -- serial clock (or bit clock)
        lrck               : out std_logic;                      -- word select (or left-right clock)
        sd_rx              : in  std_logic;                      -- serial data in
        uart_tx_serial     : out std_logic                      -- UART TX serial data
    );
end Note_tuner_top_level;

architecture Behavioral of Note_tuner_top_level is

    -- Internal signal for the buffered clock
    signal clk_internal : std_logic;
    signal clk_buf      : std_logic;
    -- Signals for connecting internal modules
    signal l_data_rx       : std_logic_vector(23 downto 0);
    signal r_data_rx       : std_logic_vector(23 downto 0);
    signal data_valid_window : std_logic;
    signal read_data_out   : std_logic_vector(15 downto 0);
    signal read_enable_out : std_logic;
    signal fft_ready       : std_logic;
    signal peak_frequency  : std_logic_vector(15 downto 0);
    signal uart_tx_active   : std_logic;
    signal uart_tx_done     : std_logic;

begin

    -- Instantiate the input buffer (IBUF) for the clock signal
    ibuf_inst : IBUF
        port map (
            I => clk_in,
            O => clk_buf
        );

    -- Instantiate the global buffer (BUFG) for the clock signal
    bufg_inst : BUFG
        port map (
            I => clk_buf,
            O => clk_internal
        );

    -- Instantiate the I2S Top Level module
    i2s_inst : entity work.i2s_toplevel
        generic map(
            d_width => 24
        )
        port map(
            clk_in       => clk_in,
            reset_n      => reset_n,
            mclk         => mclk,
            sclk         => sclk,
            lrck         => lrck,
            sd_rx        => sd_rx,
            l_data_rx    => l_data_rx,
            r_data_rx    => r_data_rx
        );

    -- Instantiate the Pre-FFT Wrapper module
    pre_fft_inst : entity work.pre_fft_wrapper
        port map(
            clk_in           => clk_internal,
            data_valid_window => data_valid_window,
            left_data        => l_data_rx,
            right_data       => r_data_rx,
            reset_n          => reset_n,
            read_data_out    => read_data_out,
            read_enable_out  => read_enable_out
        );

    -- Instantiate the FFT Post FFT Wrapper DUT module
    fft_post_inst : entity work.fft_post_fft_wrapper
        port map(
            clk_in          => clk_internal,
            reset_n         => reset_n,
            fixed_data      => read_data_out,
            data_valid      => read_enable_out,
            fft_ready       => fft_ready,
            peak_frequency  => peak_frequency
        );

    -- Instantiate the Note Identifier module
    note_id_inst : entity work.note_identifier
        port map(
            clk_in           => clk_internal,
            reset_n          => reset_n,
            raw_frequency    => peak_frequency,
            uart_tx_serial   => uart_tx_serial,
            uart_tx_active   => uart_tx_active,
            uart_tx_done     => uart_tx_done
        );

end Behavioral;
