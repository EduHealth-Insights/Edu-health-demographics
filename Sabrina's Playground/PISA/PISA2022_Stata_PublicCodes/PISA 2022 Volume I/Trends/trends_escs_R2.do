clear all
set more off, perm

** Catch arguments
args jobN database domn outfile countries repestoptions escs
foreach arg in repestoptions escs {
	if "``arg''" == "NULL" local `arg' ""
	}
	
** Define FilePaths (global)
run "c:\temp\trends_ENV.do"
cd "${sandbox}"

** Load country lists
run "c:\temp\Trends\infile\averages.txt"
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
	display `"param1 = `escs'"' 
	display `"param2 = "' 
}

** outfile directory for results 
cd "${outfile}"

** core of the program: load dataset and run repest line
use cnt *sch*id *st*id* `escs' pv*`domn' w_* using "`database'"
		repest PISA , estimate(reg pv@`domn' `escs') results(add(r2)) by(cnt, levels(`countries')) outfile(`outfile') `repestoptions'

log close

** Create log to check job is done
log using "${sandbox}/logJobs/`jobN'_completed_without_errors", text replace
cap log close

clear all