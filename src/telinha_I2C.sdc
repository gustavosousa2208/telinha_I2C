//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.07 
//Created Time: 2022-12-17 01:25:44
create_clock -name clk_in -period 37.037 -waveform {0 5} [get_ports {clk_in}]
create_clock -name scl -period 370.37 -waveform {0 185.185} [get_ports {scl}]
set_operating_conditions -grade c -model slow -speed 6 -setup -hold -max -min -max_min
