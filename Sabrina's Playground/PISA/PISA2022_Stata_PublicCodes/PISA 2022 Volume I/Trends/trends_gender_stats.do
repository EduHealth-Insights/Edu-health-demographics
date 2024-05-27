clear all
set more off, perm

** Catch arguments
args jobN database domn outfile countries  repestoptions betalog gender
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
	display `"param1 = `betalog'"' 
	display `"param2 = `gender'"' 
}

** outfile directory for results 
cd "${outfile}"

** check if betalog is required, and name it based on outfile. Note "betalog" does not work with option "fast"
if "`betalog'" != "" local betalog "betalog(log_`outfile')"

** core of the program: load dataset and run repest line
use *cnt *sch*id *st*id* `gender' pv*`domn' w_* using "`database'"
cap ren  fcnt* cnt*
		repest PISA , estimate(summarize pv@`domn', stats(mean p10 p90 idr)) over(`gender', test) by(cnt, levels(`countries')) outfile(`outfile') `betalog' `repestoptions'

log close

** Create log to check job is done
log using "${sandbox}/logJobs/`jobN'_completed_without_errors", text replace
cap log close

clear all