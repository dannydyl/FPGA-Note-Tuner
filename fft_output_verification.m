% Define file paths
input_file_path = 'C:\Users\danny\OneDrive\Desktop\FPGA\Note_Tuner\Note_Tuner.sim\sim_1\behav\xsim\input_data.txt';
fft_output_file_path = 'C:\Users\danny\OneDrive\Desktop\FPGA\Note_Tuner\Note_Tuner.sim\sim_1\behav\xsim\fft_output.txt';

% Read input data
input_data = dlmread(input_file_path);

% Read FFT output data
fft_output_data = dlmread(fft_output_file_path);

% Perform FFT in MATLAB
fft_size = 1024;
sampling_rate = 48000; % Example sampling rate

% Perform FFT using MATLAB
matlab_fft = fft(input_data, fft_size);
% Manually compute the magnitude of the FFT
real_part = real(matlab_fft);
imag_part = imag(matlab_fft);
matlab_fft_magnitude = real_part.^2 + imag_part.^2;

% Create complex numbers from VHDL FFT output (assuming real and imaginary parts are stored sequentially)
vhdl_fft_complex = fft_output_data(1:2:end) + 1i * fft_output_data(2:2:end);

% Perform inverse FFT using MATLAB
inverse_fft_vhdl = ifft(vhdl_fft_complex, fft_size);

% Define frequency bins
half_size = fft_size / 2;
frequency = (0:half_size-1) * (sampling_rate / fft_size);

% Plot the input data
figure;
plot(input_data);
title('Windowed Input Data');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;

% Plot the FFT results from VHDL
figure;
subplot(2, 1, 1);
plot(frequency, fft_output_data(1:half_size));
title('FFT Magnitude Spectrum from VHDL (Positive Frequencies)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% Plot the FFT results from MATLAB
subplot(2, 1, 2);
plot(frequency, matlab_fft_magnitude(1:half_size));
title('FFT Magnitude Spectrum from MATLAB (Positive Frequencies)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% Plot the inverse FFT results from VHDL output
% subplot(3, 1, 3);
% plot(real(inverse_fft_vhdl));
% title('Inverse FFT of VHDL Output Data (Real Part)');
% xlabel('Sample Index');
% ylabel('Amplitude');
% grid on;