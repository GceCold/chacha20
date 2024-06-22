onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib result_data_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {result_data_fifo.udo}

run -all

quit -force
