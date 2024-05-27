********************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 2: Analysis
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
********************************************************

clear 			all
set more 		off, perm

** Run environment & data preparation do-files
run 			"c:\temp\pisa2022vol1_environment.do"
run 			"c:\temp\Chapter 2\pisa2022vol1_preparation_ch2.do"

** Use chapter-specific PISA 2022 dataset
use 			"${infile}/I_B1_CH2_cnt.dta", clear

**Specify options for repest
global 			options "flag pisacoverage"
global 			options2 "flag"

** Current directory
cd 				"$outfile"


cap log close
	log using "${logs}/ch2", text replace


*******************************************************

** Tables I_B1_2_1_math, _read, _scie, _math-sub-scales (mean, sd, percentiles, p10-p90)

foreach domn in $scales { 
	repest PISA, estimate(summarize pv@`domn', stats(mean sd p10 p25 p50 p75 p90 idr)) by(cnt, levels($CNT2022)) betalog(log_stats_`domn'_2022) outfile(I_B1_2_1_`domn') $options2
	}

foreach domn in $mscales { 
	repest PISA, estimate(summarize pv@`domn', stats(mean sd p10 p25 p50 p75 p90 idr)) by(cnt, levels($CNT2022)) outfile(I_B1_2_1_`domn') $options2
	}
	

repest PISA , estimate(summarize pv@math, stats(Var)) outfile(I_B1_2_var_all, replace) svyparms(nbpv(10) final_weight_name(senwt))

preserve
keep if oecd == 1
repest PISA , estimate(summarize pv@math, stats(Var)) outfile(I_B1_2_var_oecd, replace) svyparms(nbpv(10) final_weight_name(senwt))
restore
	
	

** Table I_B1_2_2_WITH (Total variation in mathematics performance, and variation between and within schools - with modal grade restriction)

//Part 1: Sample size and Coverage 
	//Sample size (number of schools)
cap drop *sample
gen sample = (xmodalisced * !missing(w_fstuwt))
egen schsample = tag(cnt cntschid) if sample
	//Coverage
replace sample = sample*100
preserve 
	collapse (rawsum) schsample (mean) sample [aw=w_fstuwt], by(cnt)
	rename ( schsample sample) (nsch_pvbetwith coverage_pvbetwith)
	save sample_pvmath.dta
restore
	
//Part 2: Mean, Total variation, variation between schools, variation within schools, icc
//ICC in outfile will be transformed in export do-file to create index of academic inclusion
preserve
	keep if xmodalisced==1
	repest PISA, estimate (summarize pv@math,stats(mean Var))  by(cnt, levels($CNT2022)) outfile(variance_pvmath, replace) $options
	pisamixed, femodel(pv@math) remodel(cntschid:) wgt(w_fstuwt) bweight(t_fstuwt) options(var) by(cnt, levels($CNT2022)) variance icc qui outfile(decomp_var_pvmath) nbpv(10) 
restore



** Table I.B1.2.2.WITHOUT (Total variation in mathematics performance, and variation between and within schools (without modal grade restriction))
preserve
	repest PISA, estimate (summarize pv@math,stats(mean Var))  by(cnt) outfile(variance_pvmath_nofilter, replace) $options2
	pisamixed, femodel(pv@math) remodel(cntschid:) wgt(w_fstuwt) bweight(t_fstuwt) options(var) by(cnt) variance icc qui outfile(decomp_var_pvmath_nofilter) nbpv(10)
restore




*******************************************************
** END OF DO-FILE
*******************************************************

cap log close

