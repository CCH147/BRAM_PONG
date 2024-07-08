set_property IOSTANDARD LVCMOS25 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS25} [get_ports {reset}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS25} [get_ports {sw}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS25} [get_ports {Rst}]

set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS25}   [get_ports {btn1}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS25}   [get_ports {btn2}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS25}   [get_ports {btn3}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS25}   [get_ports {btn4}]


set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS25} [get_ports {red[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS25} [get_ports {red[1]}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS25} [get_ports {red[2]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS25} [get_ports {red[3]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS25} [get_ports {green[0]}]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS25} [get_ports {green[1]}]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS25} [get_ports {green[2]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS25} [get_ports {green[3]}]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS25} [get_ports {blue[0]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS25} [get_ports {blue[1]}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS25} [get_ports {blue[2]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS25} [get_ports {blue[3]}]


set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS25} [get_ports {vsync}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS25} [get_ports {hsync}]