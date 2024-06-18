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

entity i2s_receiver is
    Port (
        clk_in    : in  std_logic;               -- 100 MHz input clock
        reset     : in  std_logic;               -- Reset signal
        sdin     : in  std_logic;               -- Serial data input (from I2S)
        left_data  : out std_logic_vector(23 downto 0);  -- Left channel data output
        right_data : out std_logic_vector(23 downto 0)   -- Right channel data output
    );
end i2s_receiver;

architecture Behavioral of i2s_receiver is

    -- Signals for clock divider outputs
    signal mclk     : std_logic;
    signal sclk     : std_logic;
    signal lrck     : std_logic;

    -- Signals for I2S data reception
    signal bit_count : integer range 0 to 23 := 0;
    signal left_reg  : std_logic_vector(23 downto 0) := (others => '0');
    signal right_reg : std_logic_vector(23 downto 0) := (others => '0');
    signal current_channel : std_logic := '0';  -- '0' for left, '1' for right

begin

    -- Instantiate Clock Divider
    clock_divider_inst: entity work.clock_divider
        port map (
            clk_in => clk_in,
            reset  => reset,
            mclk   => mclk,
            sclk   => sclk,
            lrck   => lrck
        );

    -- I2S data reception
    process(sclk, reset)
        variable bit_count_var : integer range 0 to 23 := 0;
        variable current_channel_var : std_logic := '0';
    begin
        if reset = '1' then
            bit_count <= 0;
            left_reg <= (others => '0');
            right_reg <= (others => '0');
            current_channel <= '0';
        elsif rising_edge(sclk) then
            if lrck = '0' then -- left channel
                left_reg <= left_reg(22 downto 0) & sdin;
            else
                right_reg <= right_reg(22 downto 0) & sdin;        
            end if;
--            if bit_count_var = 0 then
--                if lrck = '0' then
--                    current_channel_var := '0';  -- Left channel
--                else
--                    current_channel_var := '1';  -- Right channel
--                end if;
--            end if;
            
--            if current_channel_var = '0' then  -- Left channel
----                left_reg(23 - bit_count_var) <= sdin;
--                left_reg <= left_reg(22 downto 0) & sdin;
--            else  -- Right channel
----                right_reg(23 - bit_count_var) <= sdin;
--                right_reg <= right_reg(22 downto 0) & sdin;
--            end if;

--            bit_count_var := bit_count_var + 1;
--            if bit_count_var = 24 then
--                bit_count_var := 0;
--            end if;
        end if;

        bit_count <= bit_count_var;
        current_channel <= current_channel_var;
    end process;

    -- Assign internal signals to output ports
    left_data <= left_reg;
    right_data <= right_reg;

end Behavioral;