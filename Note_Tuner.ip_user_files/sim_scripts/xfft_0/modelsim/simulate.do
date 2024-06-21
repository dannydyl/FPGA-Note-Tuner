onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xbip_utils_v3_0_11 -L axi_utils_v2_0_7 -L c_reg_fd_v12_0_7 -L xbip_dsp48_wrapper_v3_0_5 -L xbip_pipe_v3_0_7 -L xbip_dsp48_addsub_v3_0_7 -L xbip_addsub_v3_0_7 -L c_addsub_v12_0_16 -L c_mux_bit_v12_0_7 -L c_shift_ram_v12_0_15 -L xbip_bram18k_v3_0_7 -L mult_gen_v12_0_19 -L cmpy_v6_0_22 -L floating_point_v7_0_21 -L xfft_v9_1_10 -L xil_defaultlib -L secureip -lib xil_defaultlib xil_defaultlib.xfft_0

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {xfft_0.udo}

run 1000ns

quit -force