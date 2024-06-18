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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    generic (
        INPUT_CLK_FREQ : integer := 100_000_000;  -- Input clock frequency in Hz (e.g., 100 MHz)
        MCLK_FREQ      : integer := 12_288_000;   -- Desired MCLK frequency in Hz (e.g., 12.288 MHz)
        SCLK_FREQ      : integer := 2_304_000;    -- Desired SCLK frequency in Hz (e.g., 2.304 MHz)
        LRCK_FREQ      : integer := 48_000        -- Desired LRCK frequency in Hz (e.g., 48 kHz)
    );
    Port (
        clk_in   : in  std_logic;       -- 100 MHz input clock
        reset    : in  std_logic;       -- Reset signal
        mclk     : out std_logic;       -- 12.288 MHz output clock
        sclk     : out std_logic;       -- 2.304 MHz output clock
        lrck     : out std_logic        -- 48 kHz output clock
    );
end clock_divider;

architecture Behavioral of clock_divider is
    -- Calculated division factors
    constant MCLK_DIV : integer := INPUT_CLK_FREQ / MCLK_FREQ / 2;
    constant SCLK_DIV : integer := INPUT_CLK_FREQ / SCLK_FREQ / 2;  -- for 2.304 MHz
    constant LRCK_DIV : integer := INPUT_CLK_FREQ / LRCK_FREQ / 2;

    signal mclk_div_counter  : integer range 0 to MCLK_DIV-1 := 0;
    signal sclk_div_counter  : integer range 0 to SCLK_DIV-1 := 0;
    signal lrck_div_counter  : integer range 0 to LRCK_DIV-1 := 0;

    signal mclk_int  : std_logic := '0';
    signal sclk_int  : std_logic := '0';
    signal lrck_int  : std_logic := '0';
begin

    -- MCLK generation
    process(clk_in, reset)
    begin
        if reset = '1' then
            mclk_div_counter <= 0;
            mclk_int <= '0';
        elsif rising_edge(clk_in) then
            if mclk_div_counter = MCLK_DIV - 1 then
                mclk_div_counter <= 0;
                mclk_int <= not mclk_int;
            else
                mclk_div_counter <= mclk_div_counter + 1;
            end if;
        end if;
    end process;

    -- SCLK generation
    process(clk_in, reset)
    begin
        if reset = '1' then
            sclk_div_counter <= 0;
            sclk_int <= '0';
        elsif rising_edge(clk_in) then
            if sclk_div_counter = SCLK_DIV - 1 then
                sclk_div_counter <= 0;
                sclk_int <= not sclk_int;
            else
                sclk_div_counter <= sclk_div_counter + 1;
            end if;
        end if;
    end process;

    -- LRCK generation
    process(clk_in, reset)
    begin
        if reset = '1' then
            lrck_div_counter <= 0;
            lrck_int <= '0';
        elsif rising_edge(clk_in) then
            if lrck_div_counter = LRCK_DIV - 1 then
                lrck_div_counter <= 0;
                lrck_int <= not lrck_int;
            else
                lrck_div_counter <= lrck_div_counter + 1;
            end if;
        end if;
    end process;

    -- Assign internal signals to output ports
    mclk <= mclk_int;
    sclk <= sclk_int;
    lrck <= lrck_int;

end Behavioral;

