----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/25/2024 09:53:42 PM
-- Design Name: 
-- Module Name: pre_fft_wrapper - Behavioral
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

entity pre_fft_wrapper is
    port(
        clk_in     : in std_logic;
        data_valid_window : in std_logic;
        left_data : in std_logic_vector(23 downto 0);
        right_data : in std_logic_vector(23 downto 0);
        reset_n     : in std_logic;
        read_data_out   :out std_logic_vector(15 downto 0);
        read_enable_out : out std_logic
        );
end pre_fft_wrapper;

architecture Behavioral of pre_fft_wrapper is
    -- Signal declarations
    signal fixed_data       : std_logic_vector(15 downto 0);
    signal windowed_data    : std_logic_vector(15 downto 0);
    signal data_valid       : std_logic := '0';
    signal window_valid     : std_logic := '0';
    signal write_enable     : std_logic := '0';
    signal read_data        : std_logic_vector(15 downto 0);
    signal read_addr        : std_logic_vector(9 downto 0) := (others => '0'); -- Address signal for BRAM
    signal read_enable_internal : std_logic;

    -- Instantiate data_rx_to_fixed_point
    component data_rx_to_fixed_point is
        Port (
--            reset_n      : in  std_logic;
            left_data_rx : in  std_logic_vector(23 downto 0);
            right_data_rx: in  std_logic_vector(23 downto 0);
            fixed_data   : out std_logic_vector(15 downto 0)
        );
    end component;
    
   -- Instantiate window_function
    component window_function is
        Port (
            clk_in        : in  std_logic;
            reset_n       : in  std_logic;
            fixed_data    : in  std_logic_vector(15 downto 0); -- Q1.15 format
            data_valid    : in  std_logic;
            windowed_data : out std_logic_vector(15 downto 0); -- Q1.15 format
            window_valid  : out std_logic
        );
    end component;

    -- Instantiate fixed_data_bram
    component fixed_data_bram is
        port(
            clk_in       : in  std_logic;
            reset_n      : in  std_logic;
            write_enable : in  std_logic;
            write_data   : in  std_logic_vector(15 downto 0);
            read_enable  : out std_logic;
            read_data    : out std_logic_vector(15 downto 0)
        );
    end component;

begin
    -- Instantiate data_rx_to_fixed_point
    data_rx_inst : data_rx_to_fixed_point
        Port map (
--            reset_n       => reset_n,
            left_data_rx  => left_data,
            right_data_rx => right_data,
            fixed_data    => fixed_data
        );

    -- Instantiate window_function
    window_inst : window_function
        Port map (
            clk_in        => clk_in,
            reset_n       => reset_n,
            fixed_data    => fixed_data,
            data_valid    => data_valid,
            windowed_data => windowed_data,
            window_valid  => window_valid
        );
     
    data_valid <= '1';
    write_enable <= window_valid;   
    read_enable_out <= read_enable_internal;
     
    -- Instantiate fixed_data_bram
    bram_inst : fixed_data_bram
        Port map (
            clk_in       => clk_in,
            reset_n      => reset_n,
            write_enable => write_enable,
            write_data   => windowed_data,
            read_enable  => read_enable_internal,
            read_data    => read_data_out
        );

end Behavioral;
