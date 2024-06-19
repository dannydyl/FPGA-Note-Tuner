----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2024 03:59:26 PM
-- Design Name: 
-- Module Name: i2s_toplevel_tb - Behavioral
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
use work.all;

entity tb_i2s_toplevel is
end tb_i2s_toplevel;

architecture Behavioral of tb_i2s_toplevel is
    -- Parameters
    constant d_width : integer := 24;

    -- Testbench Signals
    signal clk_in : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal mclk : std_logic;
    signal sclk : std_logic;
    signal lrck : std_logic;
    signal sd_rx : std_logic := '0';
    signal l_data_rx : std_logic_vector(d_width-1 downto 0);
    signal r_data_rx : std_logic_vector(d_width-1 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns; -- 100 MHz clock

    -- Instantiate the Unit Under Test (UUT)
    component i2s_toplevel
        GENERIC(
            d_width : INTEGER := 24
        );
        PORT(
            clk_in : IN std_logic;
            reset_n : IN std_logic;
            mclk : OUT std_logic;
            sclk : OUT std_logic;
            lrck : OUT std_logic;
            sd_rx : IN std_logic;
            l_data_rx : OUT std_logic_vector(d_width-1 downto 0);
            r_data_rx : OUT std_logic_vector(d_width-1 downto 0)
        );
    end component;

    -- PLL component declaration
    component clk_wiz_0
        port (
            -- Clock in ports
            clk_in1 : in std_logic;
            -- Clock out ports
            clk_out1 : out std_logic;
            -- Status and control signals
            resetn : in std_logic
        );
    end component;

begin
    -- Clock generation
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period / 2;
        clk_in <= '1';
        wait for clk_period / 2;
    end process;


    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns
        reset_n <= '0';
        wait for 100 ns;

        reset_n <= '1';

        -- Add stimulus here
        -- For example, you can drive sd_rx with a sample I2S data pattern

        -- Sample pattern for sd_rx (you can customize this part)
        wait for 500 ns;
        sd_rx <= '1';
        wait for clk_period;


        -- Wait for more cycles and observe the output
        wait for 1000 ns;

        -- Finish the simulation
        wait;
    end process;

    -- Instantiate the PLL
    pll_inst: clk_wiz_0
        port map (
            clk_in1 => clk_in,
            resetn => reset_n,
            clk_out1 => mclk
        );

    -- Instantiate the UUT
    uut: i2s_toplevel
        GENERIC MAP(
            d_width => d_width
        )
        PORT MAP(
            clk_in => clk_in,
            reset_n => reset_n,
            mclk => mclk,
            sclk => sclk,
            lrck => lrck,
            sd_rx => sd_rx,
            l_data_rx => l_data_rx,
            r_data_rx => r_data_rx
        );

end Behavioral;
