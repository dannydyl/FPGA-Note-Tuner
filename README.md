# FPGA-Note-Tuner

# FPGA Note Tuner Project

## Overview
This project involves designing a guitar tuner using an Artix-7 FPGA from Xilinx. The tuner processes 24-bit, 48 kHz stereo audio input, performs Fast Fourier Transform (FFT) to analyze frequencies, and identifies the note being played. The results are then transmitted via UART to a terminal in ASCII code to indicate the detected note. This project was developed from scratch by me, and it demonstrates the use of various FPGA components and techniques.

## Project Components
1. **I2S Top-Level Module**: Handles stereo audio input and output.
2. **Pre-FFT Wrapper**: Prepares audio data for FFT analysis.
3. **FFT Post-FFT Wrapper**: Performs FFT on the audio data and identifies the peak frequency.
4. **Note Identifier**: Converts the frequency to a musical note and transmits the result over UART.

## Design Process
### Step 1: I2S Audio Interface
- **Entity**: `i2s_toplevel`
- **Description**: This module interfaces with the I2S audio input, capturing 24-bit, 48 kHz stereo audio data.
- **Clock Management**: Used a Phase-Locked Loop (PLL) to generate the I2S master and channel clocks.

### Step 2: Pre-FFT Data Preparation
- **Entity**: `pre_fft_wrapper`
- **Description**: This module prepares the captured audio data for FFT analysis by converting the audio signal into fixed-point format Q1.15 and applying a Hann window function.
- **Data Storage**: Data is stored in Block RAM (BRAM) before FFT processing.

### Step 3: FFT and Frequency Detection
- **Entity**: `fft_post_fft_wrapper`
- **Description**: This module performs a radix-2 FFT on the prepared audio data, calculates the magnitude of the frequency components, and identifies the peak frequency.
- **FFT Size**: 1024 points.
- **Data Storage**: Data and magnitudes are stored in BRAM both pre- and post-FFT.
- **AXI Stream**: Utilized AXI stream protocol for FFT data handling.

### Step 4: Note Identification and UART Transmission
- **Entity**: `note_identifier`
- **Description**: This module converts the peak frequency to a musical note and transmits the result via UART.
- **Output**: The detected note is transmitted as ASCII code over UART.

### Step 5: Verification
- **DUT/Testbench**: Developed and used DUT/testbenches for verifying all entities.
- **Integrated Logic Analyzer (ILA)**: Used ILA for verifying the internal signals and data flow throughout the design.

### Step 6: Timing Analysis
- **Tool Used**: Xilinx Vivado
- **Key Metrics**:
  - **Worst Negative Slack (WNS)**: 5.212 ns
  - **Total Negative Slack (TNS)**: 0.000 ns
  - **Worst Hold Slack (WHS)**: 0.063 ns
  - **Total Hold Slack (THS)**: 0.000 ns
  - **Worst Pulse Width Slack (WPWS)**: 3.000 ns
  - **Total Pulse Width Negative Slack (TPWS)**: 0.000 ns

All user-specified timing constraints are met, with no setup, hold, or pulse width violations.

## Conclusion
The FPGA Guitar Tuner project successfully integrates multiple modules to process audio input, perform FFT analysis, identify musical notes, and transmit the results via UART in ASCII code. The design meets all specified timing constraints, ensuring reliable operation at the intended clock frequency. The use of BRAM for data storage, Hann window function, radix-2 FFT, AXI stream, and fixed-point format ensures efficient and accurate processing. All components were verified using DUT/testbenches, and internal signal verification was performed using the Integrated Logic Analyzer (ILA).

## License
This project is licensed under the MIT License.
