::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
vsim -gui -do "run.do 3 0 7777"