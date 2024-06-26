% Define the file path
file_path = 'C:/Users/danny/OneDrive/Desktop/FPGA/Note_Tuner/Note_Tuner.sim/sim_1/behav/xsim/fft_output.txt';


% Open the file
file_id = fopen(file_path, 'r');

% Read the data
data = textscan(file_id, '%d %d');

% Close the file
fclose(file_id);

% Extract real and imaginary parts
real_out = data{1};
imag_out = data{2};

% Calculate the magnitude
magnitude = sqrt(double(real_out).^2 + double(imag_out).^2);

% Define frequency bins (adjust according to your FFT size and sampling rate)
fft_size = length(magnitude);
sampling_rate = 48000; % Example sampling rate
frequency = (0:fft_size-1) * (sampling_rate / fft_size);

% Plot the FFT results
figure;
plot(frequency, magnitude);
title('FFT Magnitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
