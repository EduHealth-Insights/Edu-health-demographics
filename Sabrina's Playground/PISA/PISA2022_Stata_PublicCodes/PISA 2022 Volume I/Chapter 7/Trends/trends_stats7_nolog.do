clear all
set more off, perm

** Catch arguments
args jobN database domn outfile countries repestoptions coverage group
foreach arg in repestoptions coverage group {
	if "``arg''" == "NULL" local `arg' ""
	}

** Define FilePaths (global)
run "V:\PISA_INITIALREPORT_2022\results\Trends\infile\trends_ENV.do"
cd "${sandbox}"

** Load country lists
run "V:\PISA_INITIALREPORT_2022\results\Trends\infile\averages.txt"
if "`countries'" == "CNT2022" local countries "$CNT2022"

local day = "$S_DATE"
local day = subinstr("`day'"," ","",.)

cap log close
log using "${sandbox}/logs/trends_`day'_`outfile'", text replace


 ** Printing arguments inside the log file
forval i = 1/1 {
	display `"jobN = `jobN'"'
	display `"database = `database'"'
	display `"domn = `domn'"' 
	display `"outfile = `outfile'"'
	display `"countries = `countries'"' 
	display `"repestoptions = `repestoptions'"' 
	display `"coverage = `coverage'"' 
	display `"param1 = `group'"' 
	display `"param2 = "' 
}

** outfile directory for results 
cd "V:\PISA_INITIALREPORT_2022\sandbox\Trends_CH7\Outfile"

** core of the program: load dataset and run repest line
use *cnt *sch*id *st*id* `group' pv*`domn' w_* using "`database'"
cap ren  fcnt* cnt*

repest PISA , estimate(means pv@`domn') over(`group', test) by(cnt, levels(`countries')) outfile(`outfile') `repestoptions' `coverage'

log close

** Create log to check job is done
log using "${sandbox}/logJobs/`jobN'_completed_without_errors", text replace
cap log close

clear all