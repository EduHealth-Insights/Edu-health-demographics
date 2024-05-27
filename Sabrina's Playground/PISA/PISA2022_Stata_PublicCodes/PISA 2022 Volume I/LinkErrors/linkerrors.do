//// PISA 2022 

//// Computation of complex Link Errors (linear and curvilinear trends)



clear all
set more 		off, perm 

** File paths
global linkerrors "V:\PISA_INITIALREPORT_2022\results\Trends\linkerrors"
global infile "V:\PISA_INITIALREPORT_2022\results\Trends\infile"
global logs "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"

** Country lists
	do "$infile\averages.txt"


** Initialise log file
cd "$logs"
cap log close
local day = "$S_DATE"
local day = subinstr("`day'"," ","",.)
log using "pisa2018volume1_linkerrors_`day'", text replace nomsg
display "$S_TIME  $S_DATE"


*** Start the core of the programme

do "G:\Code\PISA2022\volume1\LinkErrors\linkerrors_annch.do" 


*** End the programme
display "$S_TIME  $S_DATE"
cap log close
