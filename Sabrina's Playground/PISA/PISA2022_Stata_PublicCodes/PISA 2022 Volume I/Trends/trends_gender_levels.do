clear all
set more off, perm

** Catch arguments
args jobN database domn outfile countries repestoptions gender
foreach arg in repestoptions gender {
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
	display `"param1 = `gender'"' 
	display `"param2 = "' 
}
** outfile directory for results 
cd "${outfile}"

** core of the program: load dataset and run repest line
use cnt *sch*id *st*id* `gender' lp_pv*`domn'_l tp_pv*`domn'_l w_* using "`database'"
		repest PISA , estimate(means lp_pv@`domn'_l tp_pv@`domn'_l, pct)  over(`gender', test) by(cnt, levels(`countries')) outfile(`outfile') `repestoptions'

log close

** Create log to check job is done
log using "${sandbox}/logJobs/`jobN'_completed_without_errors", text replace
cap log close

clear all