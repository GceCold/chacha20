onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib origin_data_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {origin_data_fifo.udo}

run -all

quit -force
