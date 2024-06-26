----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/24/2024 11:41:40 PM
-- Design Name: 
-- Module Name: fft_bram - Behavioral
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

entity fft_top_level_with_magnitude_bram is
    Port (
        clk_in           : in  std_logic;
        reset_n          : in  std_logic;
        fixed_data       : in  std_logic_vector(15 downto 0);
        data_valid       : in  std_logic;
        data_last        : in  std_logic;
        fft_ready        : out std_logic; --assert it when it is needed for higher top level, for now fft_ready is used for local signal for verification purpose
        read_addr        : in  std_logic_vector(9 downto 0);
        read_data        : out std_logic_vector(15 downto 0)
    );
end fft_top_level_with_magnitude_bram;

architecture Behavioral of fft_top_level_with_magnitude_bram is

    component fft_top_level
        Port (
            clk_in            : in  std_logic;
            reset_n           : in  std_logic;
            fixed_data        : in  std_logic_vector(15 downto 0);
            data_valid        : in  std_logic;
            data_last         : in  std_logic;
            fft_ready         : out std_logic;
            fft_data_out      : out std_logic_vector(31 downto 0);
            fft_data_valid    : out std_logic
        );
    end component;

    component fft_output_bram
        Port (
            clk_in            : in  std_logic;
            reset_n           : in  std_logic;
            fft_data_in       : in  std_logic_vector(15 downto 0); -- Magnitude data
            fft_data_valid    : in  std_logic;
            fft_data_last     : in  std_logic;
            read_addr         : in  std_logic_vector(9 downto 0);
            read_data         : out std_logic_vector(15 downto 0)
        );
    end component;

    signal fft_data_out_internal   : std_logic_vector(31 downto 0);
    signal fft_data_valid_internal : std_logic;
    signal fft_data_last_internal  : std_logic;

    signal real_part : signed(15 downto 0);
    signal imag_part : signed(15 downto 0);
    signal magnitude : std_logic_vector(15 downto 0);

begin

    -- Instantiate the FFT Core
    fft_inst : fft_top_level
        Port map (
            clk_in            => clk_in,
            reset_n           => reset_n,
            fixed_data        => fixed_data,
            data_valid        => data_valid,
            data_last         => data_last,
            fft_ready         => fft_ready,
            fft_data_out      => fft_data_out_internal,
            fft_data_valid    => fft_data_valid_internal
        );

    -- Calculate Magnitude
    process(clk_in, reset_n)
        variable real_sq   : unsigned(31 downto 0);
        variable imag_sq   : unsigned(31 downto 0);
        variable mag_sq    : unsigned(31 downto 0);
    begin
        if reset_n = '0' then
            magnitude <= (others => '0');
        elsif rising_edge(clk_in) then
            if fft_data_valid_internal = '1' then
                real_part <= signed(fft_data_out_internal(15 downto 0));
                imag_part <= signed(fft_data_out_internal(31 downto 16));
                real_sq := unsigned(real_part) * unsigned(real_part);
                imag_sq := unsigned(imag_part) * unsigned(imag_part);
                mag_sq := real_sq + imag_sq;
                magnitude <= std_logic_vector(mag_sq(31 downto 16)); -- Approximation of magnitude
            end if;
        end if;
    end process;

    -- Instantiate BRAM for Magnitude Storage
    bram_inst : fft_output_bram
        Port map (
            clk_in            => clk_in,
            reset_n           => reset_n,
            fft_data_in       => magnitude,
            fft_data_valid    => fft_data_valid_internal,
            fft_data_last     => fft_data_last_internal,
            read_addr         => read_addr,
            read_data         => read_data
        );

end Behavioral;
