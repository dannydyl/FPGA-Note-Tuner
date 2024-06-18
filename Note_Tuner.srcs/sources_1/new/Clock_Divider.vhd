----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/10/2024 04:43:58 PM
-- Design Name: 
-- Module Name: Clock_Divider - Behavioral
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


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY i2s_receiver IS
  GENERIC(
    mclk_sclk_ratio  :  INTEGER := 4;    --number of mclk periods per sclk period
    sclk_lrck_ratio  :  INTEGER := 64;   --number of sclk periods per word select period
    d_width          :  INTEGER := 24);  --data width
  PORT(
    reset_n    :  IN   STD_LOGIC;                             --asynchronous active low reset
    mclk       :  IN   STD_LOGIC;                             --master clock
    sclk       :  OUT  STD_LOGIC;                             --serial clock (or bit clock)
    lrck         :  OUT  STD_LOGIC;                             --word select (or left-right clock)
    sd_rx      :  IN   STD_LOGIC;                             --serial data receive
    l_data_rx  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --left channel data received
    r_data_rx  :  OUT  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --right channel data received
END i2s_receiver;

ARCHITECTURE logic OF i2s_receiver IS

  SIGNAL sclk_int       :  STD_LOGIC := '0';                      --internal serial clock signal
  SIGNAL lrck_int         :  STD_LOGIC := '0';                      --internal word select signal
  SIGNAL l_data_rx_int  :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --internal left channel rx data buffer
  SIGNAL r_data_rx_int  :  STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --internal right channel rx data buffer
BEGIN  
  
  PROCESS(mclk, reset_n)
    VARIABLE sclk_cnt  :  INTEGER := 0;  --counter of master clocks during half period of serial clock
    VARIABLE lrck_cnt    :  INTEGER := 0;  --counter of serial clock toggles during half period of word select
  BEGIN
    
    IF(reset_n = '0') THEN                                           --asynchronous reset
      sclk_cnt := 0;                                                   --clear mclk/sclk counter
      lrck_cnt := 0;                                                     --clear sclk/lrck counter
      sclk_int <= '0';                                                 --clear serial clock signal
      lrck_int <= '0';                                                   --clear word select signal
      l_data_rx_int <= (OTHERS => '0');                                --clear internal left channel rx data buffer
      r_data_rx_int <= (OTHERS => '0');                                --clear internal right channel rx data buffer
      l_data_rx <= (OTHERS => '0');                                    --clear left channel received data output
      r_data_rx <= (OTHERS => '0');                                    --clear right channel received data output
      
    ELSIF rising_edge(mclk) THEN                            --master clock rising edge
      IF(sclk_cnt < mclk_sclk_ratio / 2 - 1) THEN                          --less than half period of sclk
        sclk_cnt := sclk_cnt + 1;                                        --increment mclk/sclk counter
      ELSE                                                             --half period of sclk
        sclk_cnt := 0;                                                   --reset mclk/sclk counter
        sclk_int <= NOT sclk_int;                                        --toggle serial clock
        IF(lrck_cnt < sclk_lrck_ratio-1) THEN                                --less than half period of lrck
          lrck_cnt := lrck_cnt + 1;                                            --increment sclk/lrck counter
          IF(sclk_int = '0' AND lrck_cnt > 1 AND lrck_cnt < d_width*2+2) THEN  --rising edge of sclk during data word
            IF(lrck_int = '1') THEN                                            --right channel
              r_data_rx_int <= r_data_rx_int(d_width-2 DOWNTO 0) & sd_rx;      --shift data bit into right channel rx data buffer
            ELSE                                                             --left channel
              l_data_rx_int <= l_data_rx_int(d_width-2 DOWNTO 0) & sd_rx;      --shift data bit into left channel rx data buffer
            END IF;
          END IF;   
        ELSE                                                            --half period of lrck
          lrck_cnt := 0;                                                    --reset sclk/lrck counter
          lrck_int <= NOT lrck_int;                                           --toggle word select
          r_data_rx <= r_data_rx_int;                                     --output right channel received data
          l_data_rx <= l_data_rx_int;                                     --output left channel received data
        END IF;
      END IF;
    END IF;    
  END PROCESS;
  
  sclk <= sclk_int;  --output serial clock
  lrck <= lrck_int;      --output word select
  
END logic;
    


