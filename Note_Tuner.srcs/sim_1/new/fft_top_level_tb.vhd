------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 06/20/2024 10:16:51 PM
---- Design Name: 
---- Module Name: fft_top_level_tb - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity fft_top_level_tb is
--end fft_top_level_tb;

--architecture Behavioral of fft_top_level_tb is
--    -- Component declaration of the top-level design
--    component fft_top_level
--        Port (
--            clk_in            : in  std_logic;
--            reset_n           : in  std_logic;  -- asynchronous reset
--            fixed_data        : in  std_logic_vector(15 downto 0);
--            data_valid        : in  std_logic;
--            data_last         : in std_logic;
--            fft_ready         : out std_logic;
--            fft_data_out      : out std_logic_vector(31 downto 0);
--            fft_data_valid    : out std_logic
--        );
--    end component;

--    -- Signals for driving the DUT (Device Under Test)
--    signal clk_in         : std_logic := '0';
--    signal reset_n        : std_logic := '0';
--    signal fixed_data     : std_logic_vector(15 downto 0) := (others => '0');
--    signal data_valid     : std_logic := '0';
--    signal fft_ready      : std_logic;
--    signal fft_data_out   : std_logic_vector(31 downto 0);
--    signal fft_data_valid : std_logic;
--    signal data_last      : std_logic;
--    -- Clock period definition
--    constant clk_period : time := 10 ns;
    
--    signal ct : integer := 0;
--begin
--    -- Instantiate the DUT
--    uut: fft_top_level
--        Port map (
--            clk_in         => clk_in,
--            reset_n        => reset_n,
--            fixed_data     => fixed_data,
--            data_valid     => data_valid,
--            data_last      => data_last,
--            fft_ready      => fft_ready,
--            fft_data_out   => fft_data_out,
--            fft_data_valid => fft_data_valid
--        );

--    -- Clock generation process
--    clk_process : process
--    begin
--        clk_in <= '0';
--        wait for clk_period / 2;
--        clk_in <= '1';
--        wait for clk_period / 2;
--    end process;

--    -- Sample data generation
--    sample : process
--    variable count : integer := 0;
--    begin
--        while true loop
--            wait until rising_edge(clk_in);
--            if fft_ready = '1' then
----                fixed_data <= std_logic_vector(to_unsigned(ct, 16));
--                fixed_data <= "0000000000000011";
--                data_valid <= '1';
--                ct <= ct + 1;
--                count := count + 1;
--                data_last <= '0';
--                if ct = 2048 then
--                    ct <= 0;
--                elsif count = 1023 then
--                    count := 0;
--                    data_last <= '1';
--                end if;
                
--            else
--                data_valid <= '0';
--            end if;
--        end loop;
--    end process;

--    -- Stimulus process
--    stimulus_process : process
--    begin
--        -- Reset the design
--        reset_n <= '0';
--        wait for 20 ns;
--        reset_n <= '1';

--        -- Wait for some time to observe the output
--        wait for 10000 ns;

--        -- Stop the simulation
--        wait;
--    end process;
--end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2024 10:16:51 PM
-- Design Name: 
-- Module Name: fft_top_level_tb - Behavioral
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
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2024 10:16:51 PM
-- Design Name: 
-- Module Name: fft_top_level_tb - Behavioral
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
use IEEE.MATH_REAL.ALL; -- For sine function
use std.textio.all; -- for file operations

entity fft_top_level_tb is
end fft_top_level_tb;

architecture Behavioral of fft_top_level_tb is
    -- Component declaration of the top-level design
    component fft_top_level
        Port (
            clk_in            : in  std_logic;
            reset_n           : in  std_logic;  -- asynchronous reset
            fixed_data        : in  std_logic_vector(15 downto 0);
            data_valid        : in  std_logic;
            data_last         : in std_logic;
            fft_ready         : out std_logic;
            fft_data_out      : out std_logic_vector(31 downto 0);
            fft_data_valid    : out std_logic;
            event_frame_started : out std_logic;
            mag               : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals for driving the DUT (Device Under Test)
    signal clk_in         : std_logic := '0';
    signal reset_n        : std_logic := '0';
    signal fixed_data     : std_logic_vector(15 downto 0) := (others => '0');
    signal data_valid     : std_logic := '0';
    signal fft_ready      : std_logic;
    signal fft_data_out   : std_logic_vector(31 downto 0);
    signal fft_data_valid : std_logic;
    signal data_last      : std_logic := '0';

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- Variables for sine wave generation
    signal sample_index : integer := 0;
    signal sample_count : integer := 0;
    constant PI : real := 3.141592653589793;
    constant FREQ : real := 1.0; -- Frequency of sine wave in Hz
    constant SAMPLE_RATE : real := 48000.0; -- Sample rate in Hz
    constant NUM_SAMPLES : integer := 1024; -- Number of samples per FFT frame

    signal mag : std_logic_vector(31 downto 0);
    signal index : integer := 1024;
    signal event_frame_started : std_logic;
    
begin
    -- Instantiate the DUT
    uut: fft_top_level
        Port map (
            clk_in         => clk_in,
            reset_n        => reset_n,
            fixed_data     => fixed_data,
            data_valid     => data_valid,
            data_last      => data_last,
            fft_ready      => fft_ready,
            fft_data_out   => fft_data_out,
            fft_data_valid => fft_data_valid,
            event_frame_started => event_frame_started,
            mag => mag
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period / 2;
        clk_in <= '1';
        wait for clk_period / 2;
    end process;

    -- Sample data generation
    sample : process
    variable sine_value : real;
    variable sine_int : integer;
    begin
        while true loop
            wait until rising_edge(clk_in);
            if fft_ready = '1' then
                -- Generate sine wave
                sine_value := sin(2.0 * PI * FREQ * real(sample_index) / SAMPLE_RATE);
                sine_int := integer(sine_value * 32767.0); -- Scale to 16-bit range
                fixed_data <= std_logic_vector(to_signed(sine_int, 16));
                data_valid <= '1';
                sample_index <= sample_index + 1;
                sample_count <= sample_count + 1;
--                data_last <= '0';
                if sample_index = NUM_SAMPLES then
                    sample_index <= 0;
                elsif sample_count = NUM_SAMPLES - 1 then
                    sample_count <= 0;
--                    data_last <= '1';
                end if;
            else
                data_valid <= '0';
            end if;
        end loop;
    end process;
    
    -- for event sync
    process
    begin
    while true loop
        wait until rising_edge(clk_in);
            if event_frame_started = '1' then
                index <= 0;
                data_last <= '0';
            else   
                index <= index + 1;
                data_last <= '0';
                if index = 1021 then
                    data_last <= '1';
                    index <= 0;
                 end if;
            end if;
    end loop;
    end process;
    
    -- Stimulus process
    stimulus_process : process
    begin
        -- Reset the design
        reset_n <= '0';
        wait for 20 ns;
        reset_n <= '1';

        -- Wait for some time to observe the output
        wait for 20000 ns;

        -- Stop the simulation
        wait;
    end process;
    
       -- Capture FFT output and write to file
    process(clk_in)
        -- File operations
        file fft_output_file : text open write_mode is "C:\Users\danny\OneDrive\Desktop\FPGA\Note_Tuner\Note_Tuner.sim\sim_1\behav\xsim/fft_output.txt";
        variable line_buf : line;
        variable real_part : signed(15 downto 0);
        variable imag_part : signed(15 downto 0);
        variable data_written : boolean := false;
    begin
        if rising_edge(clk_in) then
            if fft_data_valid = '1' then
                real_part := signed(fft_data_out(15 downto 0));
                imag_part := signed(fft_data_out(31 downto 16));
                write(line_buf, integer'image(to_integer(real_part)) & " " & integer'image(to_integer(imag_part)));
                writeline(fft_output_file, line_buf);
                data_written := true;
            end if;
        end if;
        if now = 20 ms then
            assert data_written report "No data was written to the file" severity warning;
        end if;
    end process;

end Behavioral;
