*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 4: Data Analysis
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
*******************************************************

clear 			all
set more 		off, perm

run 			"c:\temp\pisa2022vol1_environment.do"
run 			"c:\temp\Chapter 4\pisa2022vol1_preparation_ch4.do"

** Use chapter-specific PISA 2022 dataset
use 			"${infile}\I_B1_CH4_cnt.dta", clear

**Specify options for repest
global 			options "flag pisacoverage"
global 			options2 "flag"

** Current directory
cd "$outfile"

*******************************************************

** Table B1_I_4_1 ------> not computed in Stata

** Table B1_I_4_2:  Students' socio-economic status
	*Part 1/2: ESCS mean & st. dev., 10th and 90th percentile
repest PISA, estimate(summarize escs, stats(mean sd p10 p90 idr)) by(cnt) outfile(I_B1_4_2_part1, replace) $options
	*Part 2/2: national quarters
cap drop one
gen one=1
repest PISA, estimate (quantiletable escs one, nq(4)) by(cnt) results(combine(escs_difq4q1: _b[escs_q4] - _b[escs_q1])) outfile(I_B1_4_2_part2, replace) $options
   
** Table B1_I_4_3_math, _read, _scie: performance by socioeconomic gradients, quarter ESCS and (NEW) disadvantaged who are resilient
	*Part 1/3: gradients
foreach domn in $scales {
    repest PISA, estimate(stata: reg pv@`domn' escs) results(add(r2)) by(cnt) outfile(I_B1_4_3`domn'_part1, replace) $options

    preserve
		use I_B1_4_3`domn'_part1, clear 
		keep cnt *r2* escs*
			rename escs_b slope_`domn'escs_b
			rename escs_se slope_`domn'escs_se
			rename e_r2_b strength_`domn'escs_b
			rename e_r2_se strength_`domn'escs_se  
			qui save I_B1_4_3_`domn'_part1, replace
    restore
}
	*Part 2/3: mean score by national quarter of escs (and diff top-bottom quarter)
foreach domn in $scales {
    repest PISA, estimate (quantiletable escs pv@`domn', nq(4) noindexq test) by(cnt) outfile(I_B1_4_3_`domn'_part2) $options
}

foreach domn in $scales {
	repest PISA, estimate (summarize pv@`domn', stats(mean sd p10 p50 p90 idr)) over(escs_q, test) by(cnt) betalog(log_escs_stats_`domn'_2022) outfile(I_B1_4_3_`domn'_sum,replace) $options2
}

	*Part 3/3: Percentage of academically resilient students
	gen _sample_4_3_3 = 1 if low_escs == 1
foreach domn in $scales {
	repest PISA if _sample_4_3_3==1, estimate (means nresilient@`domn', pct) by(cnt) outfile(I_B1_4_3_`domn'_part3) $options
}
	*Part 3b/3: Percentage of academically resilient students
foreach domn in $scales {
	repest PISA, estimate (means resilient@`domn', pct) by(cnt) outfile(I_B1_4_3_`domn'_part3b_int) $options
}

** Table B1_I_4_4: Percentage of students by international quintile of socio-economic status
foreach quint in low20 low40 mid60 top60 top80 {
    repest PISA, estimate (means intl_escs_`quint', pct)  by(cnt)  outfile(I_B1_4_4_`quint') $options
}

** Table B1_I_4_5_math, _read, _scie: performance by international quintile of ESCS 
foreach quint in low20 low40 mid60 top60 top80 {
	foreach domn in $scales {
		repest PISA, estimate(means pv@`domn') over(intl_escs_`quint') by(cnt) outfile(I_B1_4_5_`domn'_`quint') $options
	}
}

** Table B1_I_4_4b: Percentage of students by international decile of socio-economic status
foreach decile in d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 {
    repest PISA, estimate (means intl_escs_`decile', pct)  by(cnt)  outfile(I_B1_4_4_`decile') $options
}

** Table B1_I_4_5b_math, _read, _scie: performance by international decile of ESCS 
foreach decile in d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 {
	foreach domn in $scales {
		repest PISA, estimate(means pv@`domn') over(intl_escs_`decile') by(cnt) outfile(I_B1_4_5_`domn'_`decile') $options
	}
}

** Table B1_I_4_6_math, _read, _scie:  low and top performance overall, by quarter of ESCS and likelihood of bottom quarter to be low/top performer comp. to top 3 and top quarter of ESCS
	*Part 1/4: low and top performance, overall 
foreach side in tp lp {
    foreach domn in $scales {
		repest PISA, estimate (means `side'_pv@`domn'_l, pct) by(cnt) outfile(I_B1_4_6_`side'_`domn'_part1, replace) $options
	}
}	
	*Part 2/4: percentage of low and top performers, by ESCS quarter
foreach side in tp lp {
    foreach domn in $scales {
		repest PISA, estimate (quantiletable escs `side'_pv@`domn'_l,nq(4) noindexq test)  by(cnt) outfile(I_B1_4_6_`side'_`domn'_part2, replace) $options
	preserve
    	use I_B1_4_6_`side'_`domn'_part2, clear
   		foreach x of varlist *_b *_se {
		replace `x' =`x' *100
		}
		
		qui save I_B1_4_6_`side'_`domn'_part2, replace 
	restore
	}
}

	*Part 3/4: Likelihood of disadvantaged students scoring below baseline, compared to 3 other quarters, and to top quarter of ESCS	
foreach domn in $scales {
	repest PISA, estimate (stata: logit lp_pv@`domn'_l low_escs,or) by(cnt) outfile(I_B1_4_6_`domn'_low_escs_part3) $options
	repest PISA, estimate (stata: logit lp_pv@`domn'_l low_escs med_escs,or) by(cnt) outfile(I_B1_4_6_`domn'_lowmed_escs_part3) $options
}
	*Part 4/4: Likelihood of disadvantaged students scoring at or above Level 5, compared to 3 other quarters and to top quarter of ESCS
foreach domn in math read scie {
	repest PISA, estimate (stata: logit tp_pv@`domn' low_escs,or) by(cnt) outfile(I_B1_4_6_`domn'_low_escs_part4) $options
	repest PISA, estimate (stata: logit tp_pv@`domn' low_escs med_escs,or) by(cnt) outfile(I_B1_4_6_`domn'_lowmed_escs_part4) $options
}



** Table B1_I_4_7_math, _read, _scie: Mean performance, variation and median, top and bottom percentiles, by gender
foreach domn in $scales {
	repest PISA, estimate (summarize pv@`domn', stats(mean sd p10 p50 p90)) over(boy, test) by(cnt) betalog(log_gender_stats_`domn'_2022) outfile(I_B1_4_7_`domn',replace) $options
}

foreach domn in $mscales {
	repest PISA, estimate (summarize pv@`domn', stats(mean sd p10 p50 p90)) over(boy, test) by(cnt) outfile(I_B1_4_7_`domn',replace) $options
}


** Table B1_I_4_8_math, _read, _scie: percentage of students by proficiency levels, over gender
foreach domn in $scales { 
	repest PISA, estimate(freq pv@`domn'_l) over(boy, test) by(cnt) outfile(I_B1_4_8_`domn') $options
}


** Table B1_I_4_9_math, _read, _scie: percentage of low and top performers in math, by gender
foreach side in tp lp {
	foreach domn in $scales { 
		repest PISA, estimate(means `side'_pv@`domn'_l, pct) over(boy, test) by(cnt) outfile(I_B1_4_9_`side'_`domn') $options
	}
}

	
** Table B1_I_4_10_math, _read, _scie: Mean performance by gender and ESCS
foreach domn in $scales {
    repest PISA, estimate (quantiletable escs pv@`domn', nq(4) noindexq) over(boy, test) by(cnt) outfile(I_B1_4_10_`domn') $options
}


** Table B1_I_4_11_math, _read, _scie: percentage of low and top performers by gender and quarter of ESCS
foreach domn in $scales {
	repest PISA, estimate (quantiletable escs lp_pv@`domn'_l,nq(4) noindexq) over(boy, test) by(cnt) outfile(I_B1_4_11_lp_`domn',replace) $options
	repest PISA, estimate (quantiletable escs tp_pv@`domn'_l,nq(4) noindexq) over(boy, test) by(cnt) outfile(I_B1_4_11_tp_`domn',replace) $options
}

** Table B1_I_4_12_1: Total variation in mathematics performance, and variation between and within schools
	*Part 1: Sample size and Coverage
	//Sample size (number of schools)
cap drop *sample
gen sample = (xmodalisced * !missing(escs,w_fstuwt))
egen schsample = tag(cnt cntschid) if sample
	//Coverage
replace sample = sample*100
preserve 
	collapse (rawsum) schsample (mean) sample [aw=w_fstuwt], by(cnt)
	rename (schsample sample) (nsch_escsbetwith coverage_escsbetwith)
	save I_B1_4_12_1_part1, replace // sample size and coverage
restore
	*Part 2: Mean, Total variation + Part 3: Variation between and withing schools, index of social inclusion
preserve
	keep if xmodalisced==1
	repest PISA, estimate (summarize escs,stats(mean Var))  by(cnt) outfile(I_B1_4_12_1_part2, replace) $options // mean ESCS and total variation
	pisamixed, femodel(escs) remodel(cntschid:) wgt(w_fstuwt) bweight(t_fstuwt) options(var) by(cnt) variance icc qui outfile(I_B1_4_12_1_part3) nbpv(10)
restore

** Table B1_I_4_12_2: Total variation in mathematics performance, and variation between and within schools (without modal grade restriction)
	*Part 1: Mean, Total variation
	*Part 2: Variation between and withing schools, index of social inclusion
preserve
	repest PISA, estimate (summarize escs,stats(mean Var))  by(cnt) outfile(I_B1_4_12_2_part1, replace) $options
	pisamixed, femodel(escs) remodel(cntschid:) wgt(w_fstuwt) bweight(t_fstuwt) options(var) by(cnt) variance icc qui outfile(I_B1_4_12_2_part2) nbpv(10)
restore






* Parity index
	foreach var of varlist lp_* {
		qui replace `var' = 1-`var' if !missing(`var') // performance above baseline dummy
		}
	ren lp_* bp_*
	
	
	foreach var of varlist bp_* {
	
		qui gen sexm_`var' = `var' if girl == 0
		qui gen sexf_`var' = `var' if girl == 1
		qui gen sesh_`var' = `var' if escs_q == 4
		qui gen sesl_`var' = `var' if escs_q == 1
		
		}
	
	foreach domn in math read {
		repest PISA , estimate(means sexm_bp_pv@`domn'_l sexf_bp_pv@`domn'_l, pct) results(combine(sexparity1: _b[sexf_bp_pv@`domn'_l_m]/_b[sexm_bp_pv@`domn'_l_m]; sexparity2 : _b[sexm_bp_pv@`domn'_l_m]/_b[sexf_bp_pv@`domn'_l_m])) by(cnt)  outfile(sexparity1_`domn') $repestoptions
		repest PISA , estimate(means sesh_bp_pv@`domn'_l sesl_bp_pv@`domn'_l, pct) results(combine(sesparity: _b[sesl_bp_pv@`domn'_l_m]/_b[sesh_bp_pv@`domn'_l_m])) by(cnt)  outfile(sesparity1`domn') $repestoptions
		}

		
foreach domn in math read {
	use sexparity1_`domn', clear
		gen sexparity_`domn'_b = sexparity1_b if sexparity1_b < 1
		gen sexparity_`domn'_se =  sexparity1_se if sexparity1_b < 1
		replace sexparity_`domn'_b = 2 - sexparity2_b if sexparity1_b >= 1
		replace sexparity_`domn'_se = sexparity2_se if sexparity1_b >= 1
		keep cnt sexparity_`domn'_*
	save sexparity_`domn', replace

	}

use sexparity_math, clear
	merge 1:1 cnt using sexparity_read, nogen
	merge 1:1 cnt using sesparity1math, nogen
		ren sesparity_* sesparitymath_* 

	merge 1:1 cnt using sesparity1read, nogen
		ren sesparity_* sesparityread_* 
	keep cnt sexparity_* sesparity????_*
save sdgtable_3, replace












*******************************************************
** END OF DO-FILE
*******************************************************
