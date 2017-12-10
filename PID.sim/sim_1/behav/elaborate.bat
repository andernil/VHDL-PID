@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto 7ce28330aea94227a67f67834d84e3f8 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot PID_tb_behav xil_defaultlib.PID_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
