----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/25/2024 09:17:40 PM
-- Design Name: 
-- Module Name: window_function_tb - Behavioral
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
use IEEE.MATH_REAL.ALL;

entity window_function_tb is
end window_function_tb;

architecture Behavioral of window_function_tb is
    -- Component declaration
    component window_function is
        Port (
            clk_in        : in  std_logic;
            reset_n       : in  std_logic;
            fixed_data    : in  std_logic_vector(15 downto 0);
            data_valid    : in  std_logic;
            windowed_data : out std_logic_vector(15 downto 0);
            window_valid  : out std_logic
        );
    end component;

    -- Signal declarations
    signal clk_in        : std_logic := '0';
    signal reset_n       : std_logic := '0';
    signal fixed_data    : std_logic_vector(15 downto 0) := (others => '0');
    signal data_valid    : std_logic := '0';
    signal windowed_data : std_logic_vector(15 downto 0);
    signal window_valid  : std_logic;

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant N : integer := 1024;  -- Number of samples

    -- Function to generate sine wave
    function sine_wave(i : integer) return std_logic_vector is
        variable real_value : real;
        variable fixed_value : signed(15 downto 0);
    begin
        real_value := sin(2.0 * MATH_PI * real(i) / real(N));
        fixed_value := to_signed(integer(real_value * 16384.0), 16);  -- Q1.14 format
        return std_logic_vector(fixed_value);
    end function;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: window_function port map (
        clk_in => clk_in,
        reset_n => reset_n,
        fixed_data => fixed_data,
        data_valid => data_valid,
        windowed_data => windowed_data,
        window_valid => window_valid
    );

    -- Clock process
    clk_process: process
    begin
        clk_in <= '0';
        wait for CLK_PERIOD/2;
        clk_in <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset_n <= '0';
        wait for CLK_PERIOD * 5;
        reset_n <= '1';
        wait for CLK_PERIOD * 2;

        -- Apply sine wave input
        for i in 0 to N-1 loop
            fixed_data <= sine_wave(i);
            data_valid <= '1';
            wait for CLK_PERIOD;
        end loop;

        -- End of simulation
        data_valid <= '0';
        wait for CLK_PERIOD * 10;
        assert false report "Simulation Finished" severity failure;
    end process;

    -- Verification process
    verify_proc: process
        variable expected_output : real;
        variable actual_output : real;
        variable error : real;
        variable max_error : real := 0.0;
    begin
        wait until reset_n = '1';
        wait for CLK_PERIOD * 2;  -- Wait for pipeline to fill

        for i in 0 to N-1 loop
            wait until rising_edge(clk_in) and window_valid = '1';
            
            -- Calculate expected output
            expected_output := sin(2.0 * MATH_PI * real(i) / real(N)) * 
                               (0.5 * (1.0 - cos(2.0 * MATH_PI * real(i) / real(N-1))));
            
            -- Convert actual output to real
            actual_output := real(to_integer(signed(windowed_data))) / 32768.0;
            
            -- Calculate error
            error := abs(expected_output - actual_output);
            
            -- Update max error
            if error > max_error then
                max_error := error;
            end if;

            -- Check if error is within acceptable range
            assert error < 0.001
                report "Output mismatch at sample " & integer'image(i) & 
                       ". Expected: " & real'image(expected_output) & 
                       ", Actual: " & real'image(actual_output)
                severity warning;
        end loop;

        report "Maximum error: " & real'image(max_error);
        wait;
    end process;

end Behavioral;