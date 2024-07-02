----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/01/2024 12:30:00 PM
-- Design Name: 
-- Module Name: fft_post_fft_wrapper_DUT_tb - Testbench
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
use std.textio.all;     -- For file IO

entity fft_post_fft_wrapper_DUT_tb is
end fft_post_fft_wrapper_DUT_tb;

architecture Behavioral of fft_post_fft_wrapper_DUT_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component fft_post_fft_wrapper_DUT
        port(
            clk_in          : in std_logic;
            reset_n         : in std_logic;
            fixed_data      : in std_logic_vector(15 downto 0);
            data_valid      : in std_logic;
            data_last       : in std_logic;
            fft_ready       : out std_logic;
            bram_data_out   : out std_logic_vector(31 downto 0);
            peak_frequency  : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for the UUT
    signal clk_in          : std_logic := '0';
    signal reset_n         : std_logic := '0';
    signal fixed_data      : std_logic_vector(15 downto 0) := (others => '0');
    signal data_valid      : std_logic := '0';
    signal data_last       : std_logic := '0';
    signal peak_frequency  : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

    -- Signals for driving the DUT (Device Under Test)
    signal fft_ready      : std_logic;
    signal fft_data_out   : std_logic_vector(31 downto 0);
    signal fft_data_valid : std_logic;
    signal fft_index      : std_logic_vector(10 downto 0);

    -- Variables for sine wave generation
    signal sample_index : integer := 0;
    signal sample_count : integer := 0;
    constant PI : real := 3.141592653589793;
    constant FREQ : real := 440.0; -- Frequency of sine wave in Hz
    constant SAMPLE_RATE : real := 48000.0; -- Sample rate in Hz
    constant NUM_SAMPLES : integer := 1024; -- Number of samples per FFT frame

    signal mag : std_logic_vector(31 downto 0);
    signal index : integer := 1024;
    signal event_frame_started : std_logic;
    
    signal bram_data_out : std_logic_vector(31 downto 0);
    
    type coeff_array is array (0 to 1023) of std_logic_vector(15 downto 0);
    constant hann_coefficients : coeff_array := (
        x"0000",     x"0000",     x"0001",     x"0003",     x"0005",     x"0008",     x"000B",     x"000F",
        x"0014",     x"0019",     x"001F",     x"0025",     x"002C",     x"0034",     x"003D",     x"0045",
        x"004F",     x"0059",     x"0064",     x"006F",     x"007B",     x"0088",     x"0095",     x"00A3",
        x"00B2",     x"00C1",     x"00D0",     x"00E1",     x"00F2",     x"0103",     x"0115",     x"0128",
        x"013B",     x"014F",     x"0164",     x"0179",     x"018F",     x"01A5",     x"01BC",     x"01D4",
        x"01EC",     x"0205",     x"021E",     x"0238",     x"0253",     x"026E",     x"028A",     x"02A6",
        x"02C3",     x"02E0",     x"02FF",     x"031D",     x"033D",     x"035C",     x"037D",     x"039E",
        x"03C0",     x"03E2",     x"0405",     x"0428",     x"044C",     x"0471",     x"0496",     x"04BB",
        x"04E2",     x"0508",     x"0530",     x"0558",     x"0580",     x"05A9",     x"05D3",     x"05FD",
        x"0628",     x"0653",     x"067F",     x"06AC",     x"06D9",     x"0706",     x"0734",     x"0763",
        x"0792",     x"07C2",     x"07F2",     x"0823",     x"0855",     x"0886",     x"08B9",     x"08EC",
        x"091F",     x"0953",     x"0988",     x"09BD",     x"09F3",     x"0A29",     x"0A60",     x"0A97",
        x"0ACE",     x"0B07",     x"0B3F",     x"0B79",     x"0BB2",     x"0BED",     x"0C27",     x"0C63",
        x"0C9E",     x"0CDB",     x"0D17",     x"0D55",     x"0D92",     x"0DD0",     x"0E0F",     x"0E4E",
        x"0E8E",     x"0ECE",     x"0F0F",     x"0F50",     x"0F91",     x"0FD3",     x"1016",     x"1059",
        x"109C",     x"10E0",     x"1124",     x"1169",     x"11AE",     x"11F4",     x"123A",     x"1281",
        x"12C8",     x"130F",     x"1357",     x"139F",     x"13E8",     x"1431",     x"147B",     x"14C5",
        x"150F",     x"155A",     x"15A5",     x"15F1",     x"163D",     x"1689",     x"16D6",     x"1723",
        x"1771",     x"17BF",     x"180E",     x"185C",     x"18AC",     x"18FB",     x"194B",     x"199B",
        x"19EC",     x"1A3D",     x"1A8F",     x"1AE0",     x"1B32",     x"1B85",     x"1BD8",     x"1C2B",
        x"1C7F",     x"1CD3",     x"1D27",     x"1D7B",     x"1DD0",     x"1E25",     x"1E7B",     x"1ED1",
        x"1F27",     x"1F7E",     x"1FD4",     x"202C",     x"2083",     x"20DB",     x"2133",     x"218B",
        x"21E4",     x"223D",     x"2296",     x"22F0",     x"2349",     x"23A3",     x"23FE",     x"2458",
        x"24B3",     x"250E",     x"256A",     x"25C6",     x"2621",     x"267E",     x"26DA",     x"2737",
        x"2794",     x"27F1",     x"284E",     x"28AC",     x"2909",     x"2967",     x"29C6",     x"2A24",
        x"2A83",     x"2AE2",     x"2B41",     x"2BA0",     x"2C00",     x"2C5F",     x"2CBF",     x"2D1F",
        x"2D80",     x"2DE0",     x"2E41",     x"2EA1",     x"2F02",     x"2F63",     x"2FC5",     x"3026",
        x"3088",     x"30E9",     x"314B",     x"31AD",     x"320F",     x"3272",     x"32D4",     x"3337",
        x"3399",     x"33FC",     x"345F",     x"34C2",     x"3525",     x"3588",     x"35EC",     x"364F",
        x"36B3",     x"3716",     x"377A",     x"37DE",     x"3841",     x"38A5",     x"3909",     x"396D",
        x"39D2",     x"3A36",     x"3A9A",     x"3AFE",     x"3B63",     x"3BC7",     x"3C2B",     x"3C90",
        x"3CF4",     x"3D59",     x"3DBE",     x"3E22",     x"3E87",     x"3EEB",     x"3F50",     x"3FB5",
        x"4019",     x"407E",     x"40E2",     x"4147",     x"41AC",     x"4210",     x"4275",     x"42D9",
        x"433E",     x"43A2",     x"4407",     x"446B",     x"44D0",     x"4534",     x"4598",     x"45FC",
        x"4661",     x"46C5",     x"4729",     x"478D",     x"47F0",     x"4854",     x"48B8",     x"491C",
        x"497F",     x"49E3",     x"4A46",     x"4AA9",     x"4B0D",     x"4B70",     x"4BD3",     x"4C35",
        x"4C98",     x"4CFB",     x"4D5D",     x"4DC0",     x"4E22",     x"4E84",     x"4EE6",     x"4F48",
        x"4FA9",     x"500B",     x"506C",     x"50CD",     x"512E",     x"518F",     x"51F0",     x"5250",
        x"52B1",     x"5311",     x"5371",     x"53D1",     x"5430",     x"548F",     x"54EF",     x"554E",
        x"55AC",     x"560B",     x"5669",     x"56C8",     x"5725",     x"5783",     x"57E1",     x"583E",
        x"589B",     x"58F8",     x"5954",     x"59B1",     x"5A0D",     x"5A68",     x"5AC4",     x"5B1F",
        x"5B7A",     x"5BD5",     x"5C2F",     x"5C8A",     x"5CE4",     x"5D3D",     x"5D97",     x"5DF0",
        x"5E48",     x"5EA1",     x"5EF9",     x"5F51",     x"5FA9",     x"6000",     x"6057",     x"60AE",
        x"6104",     x"615A",     x"61B0",     x"6205",     x"625A",     x"62AF",     x"6303",     x"6357",
        x"63AB",     x"63FF",     x"6452",     x"64A4",     x"64F7",     x"6549",     x"659A",     x"65EB",
        x"663C",     x"668D",     x"66DD",     x"672D",     x"677C",     x"67CB",     x"681A",     x"6868",
        x"68B6",     x"6903",     x"6950",     x"699D",     x"69E9",     x"6A35",     x"6A81",     x"6ACC",
        x"6B16",     x"6B60",     x"6BAA",     x"6BF4",     x"6C3C",     x"6C85",     x"6CCD",     x"6D15",
        x"6D5C",     x"6DA3",     x"6DE9",     x"6E2F",     x"6E74",     x"6EB9",     x"6EFE",     x"6F42",
        x"6F86",     x"6FC9",     x"700B",     x"704E",     x"708F",     x"70D1",     x"7112",     x"7152",
        x"7192",     x"71D1",     x"7210",     x"724F",     x"728D",     x"72CA",     x"7307",     x"7344",
        x"7380",     x"73BB",     x"73F6",     x"7431",     x"746B",     x"74A4",     x"74DD",     x"7516",
        x"754D",     x"7585",     x"75BC",     x"75F2",     x"7628",     x"765D",     x"7692",     x"76C7",
        x"76FA",     x"772E",     x"7760",     x"7793",     x"77C4",     x"77F5",     x"7826",     x"7856",
        x"7885",     x"78B4",     x"78E3",     x"7911",     x"793E",     x"796B",     x"7997",     x"79C2",
        x"79ED",     x"7A18",     x"7A42",     x"7A6B",     x"7A94",     x"7ABC",     x"7AE4",     x"7B0B",
        x"7B32",     x"7B58",     x"7B7D",     x"7BA2",     x"7BC6",     x"7BEA",     x"7C0D",     x"7C2F",
        x"7C51",     x"7C73",     x"7C93",     x"7CB4",     x"7CD3",     x"7CF2",     x"7D11",     x"7D2E",
        x"7D4C",     x"7D68",     x"7D84",     x"7DA0",     x"7DBB",     x"7DD5",     x"7DEF",     x"7E08",
        x"7E20",     x"7E38",     x"7E4F",     x"7E66",     x"7E7C",     x"7E92",     x"7EA6",     x"7EBB",
        x"7ECE",     x"7EE1",     x"7EF4",     x"7F06",     x"7F17",     x"7F27",     x"7F37",     x"7F47",
        x"7F56",     x"7F64",     x"7F71",     x"7F7E",     x"7F8B",     x"7F96",     x"7FA1",     x"7FAC",
        x"7FB6",     x"7FBF",     x"7FC8",     x"7FD0",     x"7FD7",     x"7FDE",     x"7FE4",     x"7FEA",
        x"7FEF",     x"7FF3",     x"7FF7",     x"7FFA",     x"7FFC",     x"7FFE",     x"7FFF",     x"7FFF",
        x"7FFF",     x"7FFF",     x"7FFE",     x"7FFC",     x"7FFA",     x"7FF7",     x"7FF3",     x"7FEF",
        x"7FEA",     x"7FE4",     x"7FDE",     x"7FD7",     x"7FD0",     x"7FC8",     x"7FBF",     x"7FB6",
        x"7FAC",     x"7FA1",     x"7F96",     x"7F8B",     x"7F7E",     x"7F71",     x"7F64",     x"7F56",
        x"7F47",     x"7F37",     x"7F27",     x"7F17",     x"7F06",     x"7EF4",     x"7EE1",     x"7ECE",
        x"7EBB",     x"7EA6",     x"7E92",     x"7E7C",     x"7E66",     x"7E4F",     x"7E38",     x"7E20",
        x"7E08",     x"7DEF",     x"7DD5",     x"7DBB",     x"7DA0",     x"7D84",     x"7D68",     x"7D4C",
        x"7D2E",     x"7D11",     x"7CF2",     x"7CD3",     x"7CB4",     x"7C93",     x"7C73",     x"7C51",
        x"7C2F",     x"7C0D",     x"7BEA",     x"7BC6",     x"7BA2",     x"7B7D",     x"7B58",     x"7B32",
        x"7B0B",     x"7AE4",     x"7ABC",     x"7A94",     x"7A6B",     x"7A42",     x"7A18",     x"79ED",
        x"79C2",     x"7997",     x"796B",     x"793E",     x"7911",     x"78E3",     x"78B4",     x"7885",
        x"7856",     x"7826",     x"77F5",     x"77C4",     x"7793",     x"7760",     x"772E",     x"76FA",
        x"76C7",     x"7692",     x"765D",     x"7628",     x"75F2",     x"75BC",     x"7585",     x"754D",
        x"7516",     x"74DD",     x"74A4",     x"746B",     x"7431",     x"73F6",     x"73BB",     x"7380",
        x"7344",     x"7307",     x"72CA",     x"728D",     x"724F",     x"7210",     x"71D1",     x"7192",
        x"7152",     x"7112",     x"70D1",     x"708F",     x"704E",     x"700B",     x"6FC9",     x"6F86",
        x"6F42",     x"6EFE",     x"6EB9",     x"6E74",     x"6E2F",     x"6DE9",     x"6DA3",     x"6D5C",
        x"6D15",     x"6CCD",     x"6C85",     x"6C3C",     x"6BF4",     x"6BAA",     x"6B60",     x"6B16",
        x"6ACC",     x"6A81",     x"6A35",     x"69E9",     x"699D",     x"6950",     x"6903",     x"68B6",
        x"6868",     x"681A",     x"67CB",     x"677C",     x"672D",     x"66DD",     x"668D",     x"663C",
        x"65EB",     x"659A",     x"6549",     x"64F7",     x"64A4",     x"6452",     x"63FF",     x"63AB",
        x"6357",     x"6303",     x"62AF",     x"625A",     x"6205",     x"61B0",     x"615A",     x"6104",
        x"60AE",     x"6057",     x"6000",     x"5FA9",     x"5F51",     x"5EF9",     x"5EA1",     x"5E48",
        x"5DF0",     x"5D97",     x"5D3D",     x"5CE4",     x"5C8A",     x"5C2F",     x"5BD5",     x"5B7A",
        x"5B1F",     x"5AC4",     x"5A68",     x"5A0D",     x"59B1",     x"5954",     x"58F8",     x"589B",
        x"583E",     x"57E1",     x"5783",     x"5725",     x"56C8",     x"5669",     x"560B",     x"55AC",
        x"554E",     x"54EF",     x"548F",     x"5430",     x"53D1",     x"5371",     x"5311",     x"52B1",
        x"5250",     x"51F0",     x"518F",     x"512E",     x"50CD",     x"506C",     x"500B",     x"4FA9",
        x"4F48",     x"4EE6",     x"4E84",     x"4E22",     x"4DC0",     x"4D5D",     x"4CFB",     x"4C98",
        x"4C35",     x"4BD3",     x"4B70",     x"4B0D",     x"4AA9",     x"4A46",     x"49E3",     x"497F",
        x"491C",     x"48B8",     x"4854",     x"47F0",     x"478D",     x"4729",     x"46C5",     x"4661",
        x"45FC",     x"4598",     x"4534",     x"44D0",     x"446B",     x"4407",     x"43A2",     x"433E",
        x"42D9",     x"4275",     x"4210",     x"41AC",     x"4147",     x"40E2",     x"407E",     x"4019",
        x"3FB5",     x"3F50",     x"3EEB",     x"3E87",     x"3E22",     x"3DBE",     x"3D59",     x"3CF4",
        x"3C90",     x"3C2B",     x"3BC7",     x"3B63",     x"3AFE",     x"3A9A",     x"3A36",     x"39D2",
        x"396D",     x"3909",     x"38A5",     x"3841",     x"37DE",     x"377A",     x"3716",     x"36B3",
        x"364F",     x"35EC",     x"3588",     x"3525",     x"34C2",     x"345F",     x"33FC",     x"3399",
        x"3337",     x"32D4",     x"3272",     x"320F",     x"31AD",     x"314B",     x"30E9",     x"3088",
        x"3026",     x"2FC5",     x"2F63",     x"2F02",     x"2EA1",     x"2E41",     x"2DE0",     x"2D80",
        x"2D1F",     x"2CBF",     x"2C5F",     x"2C00",     x"2BA0",     x"2B41",     x"2AE2",     x"2A83",
        x"2A24",     x"29C6",     x"2967",     x"2909",     x"28AC",     x"284E",     x"27F1",     x"2794",
        x"2737",     x"26DA",     x"267E",     x"2621",     x"25C6",     x"256A",     x"250E",     x"24B3",
        x"2458",     x"23FE",     x"23A3",     x"2349",     x"22F0",     x"2296",     x"223D",     x"21E4",
        x"218B",     x"2133",     x"20DB",     x"2083",     x"202C",     x"1FD4",     x"1F7E",     x"1F27",
        x"1ED1",     x"1E7B",     x"1E25",     x"1DD0",     x"1D7B",     x"1D27",     x"1CD3",     x"1C7F",
        x"1C2B",     x"1BD8",     x"1B85",     x"1B32",     x"1AE0",     x"1A8F",     x"1A3D",     x"19EC",
        x"199B",     x"194B",     x"18FB",     x"18AC",     x"185C",     x"180E",     x"17BF",     x"1771",
        x"1723",     x"16D6",     x"1689",     x"163D",     x"15F1",     x"15A5",     x"155A",     x"150F",
        x"14C5",     x"147B",     x"1431",     x"13E8",     x"139F",     x"1357",     x"130F",     x"12C8",
        x"1281",     x"123A",     x"11F4",     x"11AE",     x"1169",     x"1124",     x"10E0",     x"109C",
        x"1059",     x"1016",     x"0FD3",     x"0F91",     x"0F50",     x"0F0F",     x"0ECE",     x"0E8E",
        x"0E4E",     x"0E0F",     x"0DD0",     x"0D92",     x"0D55",     x"0D17",     x"0CDB",     x"0C9E",
        x"0C63",     x"0C27",     x"0BED",     x"0BB2",     x"0B79",     x"0B3F",     x"0B07",     x"0ACE",
        x"0A97",     x"0A60",     x"0A29",     x"09F3",     x"09BD",     x"0988",     x"0953",     x"091F",
        x"08EC",     x"08B9",     x"0886",     x"0855",     x"0823",     x"07F2",     x"07C2",     x"0792",
        x"0763",     x"0734",     x"0706",     x"06D9",     x"06AC",     x"067F",     x"0653",     x"0628",
        x"05FD",     x"05D3",     x"05A9",     x"0580",     x"0558",     x"0530",     x"0508",     x"04E2",
        x"04BB",     x"0496",     x"0471",     x"044C",     x"0428",     x"0405",     x"03E2",     x"03C0",
        x"039E",     x"037D",     x"035C",     x"033D",     x"031D",     x"02FF",     x"02E0",     x"02C3",
        x"02A6",     x"028A",     x"026E",     x"0253",     x"0238",     x"021E",     x"0205",     x"01EC",
        x"01D4",     x"01BC",     x"01A5",     x"018F",     x"0179",     x"0164",     x"014F",     x"013B",
        x"0128",     x"0115",     x"0103",     x"00F2",     x"00E1",     x"00D0",     x"00C1",     x"00B2",
        x"00A3",     x"0095",     x"0088",     x"007B",     x"006F",     x"0064",     x"0059",     x"004F",
        x"0045",     x"003D",     x"0034",     x"002C",     x"0025",     x"001F",     x"0019",     x"0014",
        x"000F",     x"000B",     x"0008",     x"0005",     x"0003",     x"0001",     x"0000",     x"0000"
    );

    signal window_sine_debug : integer;
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: fft_post_fft_wrapper_DUT
        port map (
            clk_in          => clk_in,
            reset_n         => reset_n,
            fixed_data      => fixed_data,
            fft_ready       => fft_ready,
            data_valid      => data_valid,
            bram_data_out   => bram_data_out,
            data_last       => data_last,
            peak_frequency  => peak_frequency
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;


    -- Sample data generation
    sample : process
    variable sine_value : real;
    variable sine_int : integer;
    variable window_sine : integer;
    variable coeff_int : integer;
    begin
        while true loop
            wait until rising_edge(clk_in);
            if fft_ready = '1' then
                -- Generate sine wave
                sine_value := sin(2.0 * PI * FREQ * real(sample_index) / SAMPLE_RATE);
                sine_int := integer(sine_value * 32767.0); -- Scale to 16-bit range`
                
                -- Convert coefficient from std_logic_vector to integer
                coeff_int := to_integer(signed(hann_coefficients(sample_index)));
               
                -- Ensure windowed_sine is within 16-bit signed range
                if window_sine > 32767 then
                    window_sine := 32767;
                elsif window_sine < -32768 then
                    window_sine := -32768;
                end if;
                
                 -- Apply windowing
                window_sine := sine_int * coeff_int / 32767; -- Scale down
                window_sine_debug <= coeff_int;
                fixed_data <= std_logic_vector(to_signed(window_sine, 16));
                data_valid <= '1';
                data_last <= '0';
                sample_index <= sample_index + 1;
                if sample_index = NUM_SAMPLES - 1 then
                    sample_index <= 0;
                elsif sample_count = NUM_SAMPLES - 1 then
                    sample_count <= 0;
                    data_last <= '1';
                end if;
            else
                data_valid <= '0';
            end if;
        end loop;
    end process;
    
    -- Write bram_data_out to a file for MATLAB analysis
    write_output : process(clk_in)
            -- File handling
    file bram_data_out_file : text open write_mode is "C:\\Users\\danny\\OneDrive\\Desktop\\FPGA\\Note_Tuner\\Note_Tuner.sim\\sim_1\\behav\\xsim\\bram_data_out_file.txt";
    variable line_buf : line;
    begin
        if rising_edge(clk_in) then
            if fft_ready = '1' then
                -- Write bram_data_out to the file
                write(line_buf, integer'image(to_integer(unsigned(bram_data_out))));
                writeline(bram_data_out_file, line_buf);
            end if;
        end if;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns.
        reset_n <= '0';
        wait for 20 ns;
        
        -- Release reset and start test
        reset_n <= '1';
        -- Wait for a few clock cycles
        wait for 20000 ns;
    
        -- End of test
        wait;
    end process;

end Behavioral;
