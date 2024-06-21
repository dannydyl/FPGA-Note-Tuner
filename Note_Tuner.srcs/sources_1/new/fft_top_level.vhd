----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2024 04:11:26 PM
-- Design Name: 
-- Module Name: fft_top_level - Behavioral
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

entity fft_top_level is
    Port (
        clk_in            : in  std_logic;
        reset_n           : in  std_logic;  -- asynchronous reset
        fixed_data        : in  std_logic_vector(15 downto 0);
        data_valid        : in  std_logic;
        fft_ready         : out std_logic;
        fft_data_out      : out std_logic_vector(31 downto 0);
        fft_data_valid    : out std_logic
    );
end fft_top_level;

architecture Behavioral of fft_top_level is
    signal s_axis_config_tdata : std_logic_vector(23 downto 0) := "000000001000000000001010"; -- Configuration data
    signal s_axis_config_tvalid : std_logic := '0';
    signal s_axis_config_tready : std_logic;

    signal s_axis_data_tdata : std_logic_vector(31 downto 0);
    signal s_axis_data_tvalid : std_logic := '0';
    signal s_axis_data_tready : std_logic;
    signal s_axis_data_tlast : std_logic := '0';

    signal fft_data_out_internal : std_logic_vector(31 downto 0);
    signal fft_data_valid_internal : std_logic;
    signal fft_data_tlast_internal : std_logic;

    signal real_part : std_logic_vector(15 downto 0);
    signal imag_part : std_logic_vector(15 downto 0) := (others => '0');

    signal event_frame_started : std_logic;
    signal event_tlast_unexpected : std_logic;
    signal event_tlast_missing : std_logic;
    signal event_data_in_channel_halt : std_logic;

    signal sample_counter : integer := 0;
    constant FFT_LENGTH : integer := 1024;
    
    component xfft_0
        Port (
            aclk                    : in  std_logic;
            s_axis_config_tdata     : in  std_logic_vector(23 downto 0);
            s_axis_config_tvalid    : in  std_logic;
            s_axis_config_tready    : out std_logic;
            s_axis_data_tdata       : in  std_logic_vector(31 downto 0);
            s_axis_data_tvalid      : in  std_logic;
            s_axis_data_tready      : out std_logic;
            s_axis_data_tlast       : in  std_logic;
            m_axis_data_tdata       : out std_logic_vector(31 downto 0);
            m_axis_data_tvalid      : out std_logic;
            m_axis_data_tlast       : out std_logic;
            event_frame_started     : out std_logic;
            event_tlast_unexpected  : out std_logic;
            event_tlast_missing     : out std_logic;
            event_data_in_channel_halt : out std_logic
        );
    end component;

begin
    -- Configuration process
    process(clk_in, reset_n)
    begin
        if reset_n = '0' then
            s_axis_config_tvalid <= '0';
        elsif rising_edge(clk_in) then
                if s_axis_config_tready = '1' then
                    s_axis_config_tvalid <= '1';
                else
                    s_axis_config_tvalid <= '0';
                end if;
        end if;
    end process;

    -- Data input preparation process
    process(clk_in, reset_n)
    begin
        if reset_n = '0' then
            s_axis_data_tvalid <= '0';
            s_axis_data_tdata <= (others => '0');
        elsif rising_edge(clk_in) then
                if data_valid = '1' then
                    real_part <= fixed_data;
                    s_axis_data_tdata <= imag_part & real_part; -- Combine real and imaginary parts
                    s_axis_data_tvalid <= '1';
                    
                    if sample_counter = FFT_LENGTH - 1 then
                        s_axis_data_tlast <= '1';   -- assert tlast for the last sample
                        sample_counter <= 0;
                    else
                        s_axis_data_tlast <= '0'; -- deassert tlast
                        sample_counter <= sample_counter + 1;
                    end if;
                else
                    s_axis_data_tvalid <= '0';
                end if;
        end if;
    end process;

    -- Connect internal signals to output ports
    fft_data_out <= fft_data_out_internal;
    fft_data_valid <= fft_data_valid_internal;
    fft_ready <= s_axis_data_tready;

    -- Instantiate the FFT IP core
    your_instance_name : xfft_0
        Port map (
            aclk                    => clk_in,
            s_axis_config_tdata     => s_axis_config_tdata,
            s_axis_config_tvalid    => s_axis_config_tvalid,
            s_axis_config_tready    => s_axis_config_tready,
            s_axis_data_tdata       => s_axis_data_tdata,
            s_axis_data_tvalid      => s_axis_data_tvalid,
            s_axis_data_tready      => s_axis_data_tready,
            s_axis_data_tlast       => s_axis_data_tlast,
            m_axis_data_tdata       => fft_data_out_internal,
            m_axis_data_tvalid      => fft_data_valid_internal,
            m_axis_data_tlast       => fft_data_tlast_internal,
            event_frame_started     => event_frame_started,
            event_tlast_unexpected  => event_tlast_unexpected,
            event_tlast_missing     => event_tlast_missing,
            event_data_in_channel_halt => event_data_in_channel_halt
        );

end Behavioral;
