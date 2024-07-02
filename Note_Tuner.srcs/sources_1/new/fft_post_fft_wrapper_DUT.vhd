----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/01/2024 11:54:56 AM
-- Design Name: 
-- Module Name: fft_post_fft_wrapper_DUT - Behavioral
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


entity fft_post_fft_wrapper_DUT is
    port(
        clk_in          : in std_logic;
        reset_n         : in std_logic;
        fixed_data      : in std_logic_vector(15 downto 0);
        data_valid      : in std_logic;
        data_last       : in std_logic;
        fft_ready       : out std_logic;
        bram_data_out   : out std_logic_vector(31 downto 0);
        peak_frequency  : out std_logic_vector(15 downto 0)
    );
end fft_post_fft_wrapper_DUT;

architecture Behavioral of fft_post_fft_wrapper_DUT is
   -- Declare components
    component fft_top_level
        Port (
            clk_in               : in  std_logic;
            reset_n              : in  std_logic;  -- asynchronous reset
            fixed_data           : in  std_logic_vector(15 downto 0);
            data_valid           : in  std_logic;
            data_last            : in std_logic; 
            fft_ready            : out std_logic; --assert it when it is needed for higher top level, for now fft_ready is used for local signal for verification purpose
            fft_data_out         : out std_logic_vector(31 downto 0);
            event_frame_started  : out std_logic;
            mag                  : out std_logic_vector(31 downto 0);  -- magnitude for test purposes
            fft_index            : out std_logic_vector(10 downto 0);
            fft_data_valid       : out std_logic
        );
    end component;

    component post_fft_wrapper
        port(
            clk_in              : in std_logic;
            mag_in              : in std_logic_vector(31 downto 0);
            fft_index           : in std_logic_vector(9 downto 0);
            write_enable        : in std_logic;
            bram_data_out       : out std_logic_vector(31 downto 0);
            peak_frequency      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signal declarations
    signal fft_ready_internal  : std_logic;
    signal fft_data_out        : std_logic_vector(31 downto 0);
    signal event_frame_started : std_logic;
    signal mag                 : std_logic_vector(31 downto 0);
    signal fft_index_out       : std_logic_vector(10 downto 0);
    signal fft_data_valid      : std_logic;
    signal mag_in              : std_logic_vector(31 downto 0);
    signal fft_index_in        : std_logic_vector(9 downto 0);
    signal write_enable        : std_logic;

begin
    -- Instantiate fft_top_level
    u_fft_top_level: fft_top_level
        port map (
            clk_in               => clk_in,
            reset_n              => reset_n,
            fixed_data           => fixed_data,
            data_valid           => data_valid,
            data_last            => data_last,
            fft_ready            => fft_ready,
            fft_data_out         => fft_data_out,
            event_frame_started  => event_frame_started,
            mag                  => mag,
            fft_index            => fft_index_out,
            fft_data_valid       => fft_data_valid
        );

    -- Instantiate post_fft_wrapper
    u_post_fft_wrapper: post_fft_wrapper
        port map (
            clk_in              => clk_in,
            mag_in              => mag,
            fft_index           => fft_index_out(9 downto 0), -- Taking the lower 10 bits
            write_enable        => fft_data_valid,           -- Assuming write_enable is tied to fft_data_valid
            bram_data_out       => bram_data_out,
            peak_frequency      => peak_frequency
        );
end Behavioral;
