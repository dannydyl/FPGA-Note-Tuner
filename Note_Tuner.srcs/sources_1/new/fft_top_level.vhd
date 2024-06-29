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
        data_last         : in std_logic; 
        fft_ready         : out std_logic; --assert it when it is needed for higher top level, for now fft_ready is used for local signal for verification purpose
        fft_data_out      : out std_logic_vector(31 downto 0);
        event_frame_started : out std_logic;
        mag               : out std_logic_vector(31 downto 0);  -- magnitude for test purposes
        fft_index             : out std_logic_vector(10 downto 0);
        fft_data_valid    : out std_logic
    );
end fft_top_level;

architecture Behavioral of fft_top_level is
    signal s_axis_config_tdata : std_logic_vector(23 downto 0) := "101010101010101010101011"; -- Configuration data / scaling at odd number stages
    signal s_axis_config_tvalid : std_logic := '0';
    signal s_axis_config_tready : std_logic;

    signal s_axis_data_tdata : std_logic_vector(31 downto 0);
    signal s_axis_data_tvalid : std_logic := '0';
    signal s_axis_data_tready : std_logic;
    signal s_axis_data_tlast : std_logic := '0';

    signal fft_data_out_internal : std_logic_vector(31 downto 0);
    signal fft_data_valid_internal : std_logic;
    signal fft_data_tlast_internal : std_logic;
    signal fft_m_axis_data_tuser : std_logic_vector(15 downto 0);

    signal real_part : std_logic_vector(15 downto 0);
    signal imag_part : std_logic_vector(15 downto 0) := (others => '0');

--    signal event_frame_started : std_logic;
    signal event_tlast_unexpected : std_logic;
    signal event_tlast_missing : std_logic;
    signal event_data_in_channel_halt : std_logic;

    signal sample_counter : integer := 0;
    constant FFT_LENGTH : integer := 1024;
    
--    signal fft_ready : std_logic;
    
    component xfft_0
        Port (
            aclk                    : in  std_logic;
            aresetn                 : in std_logic;
            s_axis_config_tdata     : in  std_logic_vector(23 downto 0);
            s_axis_config_tvalid    : in  std_logic;
            s_axis_config_tready    : out std_logic;
            s_axis_data_tdata       : in  std_logic_vector(31 downto 0);
            s_axis_data_tvalid      : in  std_logic;
            s_axis_data_tready      : out std_logic;
            s_axis_data_tlast       : in  std_logic;
            m_axis_data_tdata       : out std_logic_vector(31 downto 0);
            m_axis_data_tuser       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_data_tvalid      : out std_logic;
            m_axis_data_tlast       : out std_logic;
            event_frame_started     : out std_logic;
            event_tlast_unexpected  : out std_logic;
            event_tlast_missing     : out std_logic;
            event_data_in_channel_halt : out std_logic
        );
    end component;
    
    signal im_mag : signed(15 downto 0);
    signal r_mag  : signed(15 downto 0);
    signal real_sq : unsigned(31 downto 0);
    signal imag_sq : unsigned(31 downto 0);
    signal mag_sq : unsigned(31 downto 0);

begin

    --calculating magnitude
    r_mag <= signed(fft_data_out_internal(15 downto 0));
    im_mag <= signed(fft_data_out_internal(31 downto 16));
    
    real_sq <= unsigned(r_mag * r_mag);
    imag_sq <= unsigned(im_mag * im_mag);
    
    mag_sq <= real_sq + imag_sq;
    
    mag <= std_logic_vector(mag_sq);
    

    s_axis_config_tvalid <= '1';
    
    s_axis_data_tdata <= imag_part & fixed_data; -- Combine real and imaginary parts
    s_axis_data_tvalid <= data_valid;
    s_axis_data_tlast <= data_last;
    
    -- Connect internal signals to output ports
    fft_data_out <= fft_data_out_internal;
    fft_data_valid <= fft_data_valid_internal;
    fft_ready <= s_axis_data_tready;
    
    fft_index <= fft_m_axis_data_tuser(10 downto 0);
    -- Instantiate the FFT IP core
    your_instance_name : xfft_0
        Port map (
            aclk                    => clk_in,
            aresetn                 => reset_n,
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
            m_axis_data_tuser       => fft_m_axis_data_tuser,
            event_frame_started     => event_frame_started,
            event_tlast_unexpected  => event_tlast_unexpected,
            event_tlast_missing     => event_tlast_missing,
            event_data_in_channel_halt => event_data_in_channel_halt
        );
end Behavioral;
