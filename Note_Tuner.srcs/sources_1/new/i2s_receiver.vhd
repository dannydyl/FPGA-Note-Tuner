----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 05:10:49 PM
-- Design Name: 
-- Module Name: i2s_receiver - Behavioral
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

entity i2s_toplevel is
    GENERIC(
        d_width     :  INTEGER := 24);                    --data width
    PORT(
        clk_in       :  IN  STD_LOGIC;                     --system clock (100 MHz on Basys board)
        reset_n     :  IN  STD_LOGIC;                     --active low asynchronous reset
        mclk        :  OUT std_logic;  --master clock
        sclk        :  OUT STD_LOGIC;  --serial clock (or bit clock)
        lrck        :  OUT STD_LOGIC;  --word select (or left-right clock)
        sd_rx       :  IN  STD_LOGIC;                     --serial data in
        l_data_rx    : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data received from I2S Transceiver component
        r_data_rx    : out STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)  --right channel data received from I2S Transceiver component
        );                    --serial data out
end i2s_toplevel;

architecture Behavioral of i2s_toplevel is
    SIGNAL master_clk   :  STD_LOGIC;                             --internal master clock signal
    SIGNAL serial_clk   :  STD_LOGIC := '0';                      --internal serial clock signal
    SIGNAL left_right_clock  : STD_LOGIC := '0';                      --internal word select signal
    SIGNAL wire_l_data_rx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  -- wire connection between i2s receiver and top level
    SIGNAL wire_r_data_rx    :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  -- wire connection between i2s receiver and top level
    
     SIGNAL clk_in_bufg  :  STD_LOGIC;                             -- buffered clk_in signal
 
    --declare PLL to create 12.29508 which is nearest to 12.288MHz master clock from 100 MHz system clock
        component clk_wiz_0
        port
         (-- Clock in ports
          -- Clock out ports
          clk_out1          : out    std_logic;
          -- Status and control signals
          resetn             : in     std_logic;
          clk_in1           : in     std_logic
         );
        end component;
        
    --declare I2S Transceiver component
    COMPONENT i2s_receiver IS
        GENERIC(
            mclk_sclk_ratio :  INTEGER := 4;    --number of mclk periods per sclk period
            sclk_lrck_ratio   :  INTEGER := 64;   --number of sclk periods per word select period
            d_width         :  INTEGER := 24);  --data width
        PORT(
            reset_n     :  IN   STD_LOGIC;                              --asynchronous active low reset
            mclk        :  IN   STD_LOGIC;                              --master clock
            sclk        :  OUT  STD_LOGIC;                              --serial clock (or bit clock)
            lrck          :  OUT  STD_LOGIC;                              --word select (or left-right clock)
            sd_rx       :  IN   STD_LOGIC;                             --serial data receive
            l_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);   --left channel data received
            r_data_rx   :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0));  --right channel data received
    END COMPONENT;

BEGIN
    --instantiate PLL to create master clock
    i2s_clock: clk_wiz_0 
    PORT MAP(
             clk_in1 => clk_in_bufg, 
            resetn => reset_n,
            clk_out1 => master_clk);
  
    --instantiate I2S Transceiver component
    i2s_transceiver_0: i2s_receiver
    GENERIC MAP(mclk_sclk_ratio => 4, sclk_lrck_ratio => 64, d_width => 24)
        PORT MAP(
                    reset_n => reset_n, 
                    mclk => master_clk, 
                    sclk => serial_clk, 
                    lrck => left_right_clock, 
                    sd_rx => sd_rx,
                    l_data_rx => wire_l_data_rx,
                    r_data_rx => wire_r_data_rx
                    );


    r_data_rx <= wire_r_data_rx;
    l_data_rx <= wire_l_data_rx;    
    mclk <= master_clk;  --output master clock to ADC
    sclk <= serial_clk;  --output serial clock (from I2S Transceiver) to ADC
    lrck <= left_right_clock;   --output word select (from I2S Transceiver) to ADC


end Behavioral;