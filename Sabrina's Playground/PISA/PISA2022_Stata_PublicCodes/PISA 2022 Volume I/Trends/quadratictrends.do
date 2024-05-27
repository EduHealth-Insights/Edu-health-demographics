** compute regression-based trends (quadratic) using betalogs of stats 


clear all
set more off, perm

** Catch arguments
args jobN betalog waves stats

local outfile = subinstr("`betalog'","log_","",1)

** Define FilePaths (global)
run "c:\temp\trends_ENV.do"
cd "${sandbox}"

local day = "$S_DATE"
local day = subinstr("`day'"," ","",.)

cap log close
log using "${sandbox}\logs\trends_`day'_`outfile'_quadratictrend", text replace

 ** Printing arguments inside the log file
forval i = 1/1 {
	display `"jobN = `jobN'"'
	display "`betalog' : `waves' (linear trends for `stats')"	
	display "outputs to `outfile'_lineartrend.dta"
	}
	
** outfile directory for results 
cd "${outfile}"

** number of pvs to use: 5 or 10?

local tenpvs "2015 2018 2022"
local check : list waves - tenpvs
	if "`check'" == "" local PVs = 10	// use all 10 pvs if only PISA15, PISA18 and PISA22 are involved
	else local PVs = 5
		
*** merge logs
	local last "2022"
	local first : list waves - last // all waves, except last
	local logs : subinstr local waves "20" " `betalog'_20", all // all betalogs to merge
	di "`logs'" 	// check that list of betalogs is complete
		clear
		append using `logs', gen(wave)
		gen year = real(word("`waves'",wave))
		replace year = 2017 if (wave == 2015 | wave == 2018) & regexm("GTM KHM PRY",cnt) //pisa d countries, returning in 2022
		replace year = 2010 if wave == 2009 & regexm("CRI GEO MDA MLT MYS ARE",cnt) //pisa plus countries, returning in 2022
		replace year = 2001 if wave == 2000 & regexm("ALB ARG BGR CHL IDN MKD PER THA",cnt) //pisa plus countries, returning in 2022
		replace year = 2002 if wave == 2000 & regexm("HKG ISR ROU",cnt) //pisa plus countries, returning in 2022
		replace year = year - 2022  // center variable year in 2022 to interpret coefficients as rate of change in 2022
	 // only compute curvilinear change if 5 or more data points ? keep if... 
				preserve
					tempfile cntyears
					bys cnt year: keep if _n == 1 // keep 1 obs per country/year
					collapse (count) nyears = year, by(cnt) // count obs per country
					save `cntyears', replace
				restore
			qui merge m:1 cnt using `cntyears', nogen
			keep if nyears >= 5 

	// does the betalog include an over breakdown?
	cap confirm variable over_level 
	if !_rc local over_level "over_level test"

	local betas = "`betalog'" + "_" + subinstr("`waves'"," ","_",.)
	save `betas', replace
		
	// get varname corresponding to stat
	local stats = subinstr("`stats'"," ","* *",.)
	unab stats: *`stats'*
*** compute quadratic trends
		pisa_curv_change, curv betalog(`betas') by(cnt) `over_level' stats(`stats') outfile(`outfile'_quadratictrend) nbpv(`PVs') fast

display "$S_TIME  $S_DATE"

log close

** Create log to check job is done
log using "${sandbox}/logJobs/`jobN'_completed_without_errors", text replace
cap log close

clear all
		
		
