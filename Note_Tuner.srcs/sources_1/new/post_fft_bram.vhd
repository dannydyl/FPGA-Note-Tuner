----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/28/2024 06:31:06 PM
-- Design Name: 
-- Module Name: post_fft_bram - Behavioral
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
use ieee.numeric_std.all;

entity post_fft_bram is
    port(
        clk_in          : in std_logic;
        write_enable    : in std_logic;
        fft_index       : in std_logic_vector(9 downto 0);
        mag_in          : in std_logic_vector(31 downto 0);
        mag_out         : out std_logic_vector(31 downto 0);
        read_ready      : out std_logic
    );
end post_fft_bram;

architecture Behavioral of post_fft_bram is
    type bram_type is array (0 to 512) of std_logic_vector(31 downto 0);
    signal bram : bram_type := (others => ( others => '0'));
    signal addr : std_logic_vector(9 downto 0);
    signal read_addr : unsigned(9 downto 0) := (others => '0');
    signal write_done : std_logic := '0';
    signal state : std_logic := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            case state is
                when '0' =>  -- Write state
                    if write_enable = '1' then
                        bram(to_integer(unsigned(fft_index))) <= mag_in;
                        read_ready <= '0';
                        if fft_index = std_logic_vector(to_unsigned(511, 10)) then
                            state <= '1';  -- Transition to read state
                        end if;
                    end if;
                when '1' =>  -- Read state
                    read_ready <= '1';
                    mag_out <= bram(to_integer(read_addr));
                    if read_addr < 511 then
                        read_addr <= read_addr + 1;
                    else
                        read_addr <= (others => '0');
                        state <= '0';  -- Transition back to write state
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
