********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Tables for  Ch1
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023
********************************************************

** Load env

run 			"c:\temp\Do-files\EnvVol2.do"

** Load dataset

use 			"$infile/pisa2022completedata.dta", clear

** go to outfile folder

cd "$outfile"

** Table II.B1.1.1

repest PISA, estimate(summarize belong, stats(mean sd))  by(cnt) outfile(pisa22vol2_type1_mean_belong, replace) pisacoverage flag
local variables "st034q*"
foreach vr of varlist `variables' {	
		repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type1_freq_`vr', replace) pisacoverage flag 
}

** Table II.B1.1.2

local variables "belong"
local over "boy lowhighescs iscedlev3 immback"
foreach vr of varlist `variables' {
	foreach o of varlist  `over' {		// Run the estimation for all isced levels
		repest PISA, estimate(means `vr') over(`o', test)  by(cnt) outfile(pisa22vol2_type2st_mean_`vr'_`o', replace) pisacoverage flag 
	}
}

** Table II.B1.1.3


local variables "belong"
local over "lowhighxescs city private lowhighximmback"
foreach vr of varlist `variables' {
	foreach o of varlist  `over' {		// Run the estimation for all isced levels
		repest PISA, estimate(means `vr') over(`o', test)  by(cnt) outfile(pisa22vol2_type2sc_mean_`vr'_`o', replace) pisacoverage flag 
	}
}


local variables "belong"
local over "med_xescs schlocation"
foreach vr of varlist `variables' {
foreach o of varlist  `over' {		// Run the estimation for all isced levels
		repest PISA, estimate(means `vr') over(`o')  by(cnt) outfile(pisa22vol2_type2sc_mean_`vr'_`o', replace) pisacoverage flag 
	}
}

** Table II.B1.1.4

// Here Use the same repest (with the good variable here d_st034q*) than Table II.B1.1.1 for frequency

** Table II.B1.1.5-6-7

// See trend do-files

** Table II.B1.1.8

local variables "belong"
local score "math"
foreach vr of varlist `variables' {
	foreach sc in `score' {		
		// Before and after accounting for student and school ESCS
		repest PISA, estimate (stata: reg pv@`sc' `vr' if !missing(escs) & !missing(xescs)) results(add(r2)) by(cnt) outfile(pisa22vol2_type4st_reg_`sc'_`vr'_BEF, replace) pisacoverage flag 
		repest PISA, estimate (stata: reg pv@`sc' `vr' escs xescs) results(add(r2)) by(cnt) outfile(pisa22vol2_type4st_reg_`sc'_`vr'_AFT, replace) pisacoverage flag 
	}
}

local variables "d_st034q*"
local score "math"
foreach vr of varlist `variables' {
	foreach sc in `score' {	
		repest PISA, estimate (stata: reg pv@`sc' `vr' if !missing(escs) & !missing(xescs)) results(add(r2)) by(cnt) outfile(pisa22vol2_type4st_reg_`sc'_`vr'_BEF, replace) pisacoverage flag 
		repest PISA, estimate (stata: reg pv@`sc' `vr' escs xescs) results(add(r2)) by(cnt) outfile(pisa22vol2_type4st_reg_`sc'_`vr'_AFT, replace) pisacoverage flag 
	}
}

** Table II.B1.1.9

local score "math"
local varlist "belong"
foreach sc in `score' {
 foreach vr in `varlist'  {
      repest PISA, estimate (stata: reg pv@`sc' `vr' x`vr' escs xescs) by(cnt) outfile(pisa22vol2_type4sc_reg_`sc'_`vr'_x`vr', replace) pisacoverage flag 
 }
}


local score "math"
local varlist "xd_st034*"
foreach sc in `score' {	
 foreach vr in `varlist' {
 * Quantiletable: independent variable -> outcome
		repest PISA, estimate (quantiletable `vr' pv@`sc', nq(4) test) by(cnt) outfile(pisa22vol2_type4sc_quantile_`sc'_`vr', replace) pisacoverage flag 
 }
}

** Table II.B1.1.10

// basic frequency repest (see table II.B1.1.1) variable: r_lifesat

** Table II.B1.1.11

See Table II.B1.1.8 variables lifesat r_lifesat wb155*

** Table II.B1.1.12

See Table II.B1.18 variables r_lifesat belong grosagr anxmat sdleff 
