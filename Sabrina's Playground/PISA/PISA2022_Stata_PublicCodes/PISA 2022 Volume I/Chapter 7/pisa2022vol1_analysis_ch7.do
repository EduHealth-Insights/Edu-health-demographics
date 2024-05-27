*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 4: Data Analysis
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023											  
********************************************************

clear 			all
set more 		off, perm

** Run environment & data preparation do-files
run 			"c:\temp\pisa2022vol1_environment.do"
run 			"c:\temp\Chapter 7\pisa2022vol1_preparation_ch7.do"

** Use chapter-specific PISA 2022 dataset
use 			"${infile}\I_B1_CH7_cnt.dta", clear

** Specify options for repest
global 			options "flag pisacoverage" 
global 			options2 "flag" 

** Current directory
cd 				"$outfile"

*******************************************************

//ONLY TABLES WITH PISA 2022 DATA ONLY (TO BE SHARED WITH COUNTRIES IN DRAFT 1) ARE INCLUDED IN THIS DO-FILE 
//TREND TABLES (TO BE SHARED WITH COUNTRIES IN DRAFT 2) ARE COMPUTED IN A SEPARATE DO-FILE

** Table I_B1_7_1_1: Percentage of students with an immigrant background in PISA 2022
foreach x in immig immback {
	repest PISA, estimate(freq `x') by(cnt) outfile(I_B1_7_1_`x') $options
	}

repest PISA, estimate(freq immig) by(cnt) results(combine(generadif: _b[immig_3] - _b[immig_2])) outfile(I_B1_7_1_im2) $options	
	
** Table I_B1_7_2: Socio-economic status, by immigrant background
	*Part 1/2: ESCS index by immigrant status
foreach x in immback immig {
	repest PISA, estimate(means escs) over(`x', test) by(cnt) outfile(I_B1_7_2_`x') $options 
	}
foreach x in immback immig {
	repest PISA, estimate(summarize escs, stats(mean sd p10 p25 p50 p75 p90 idr)) over(`x', test) by(cnt) outfile(I_B1_7_2b_`x') $options2 
	}
	*Part 2/2: percentage of disadvantaged and advantaged students by immback and test
foreach x in low_escs high_escs {
	foreach i in immback immig {
		repest PISA, estimate(means `x',pct) over(`i', test) by(cnt) outfile(I_B1_7_2_`x'_`i') $options
		}
	}

** Table I_B1_7_3_1 Language spoken at home by immigrant background	*Part 1/2: pct of students who speak another language at home among all students
repest PISA, estimate(means difflang, pct) by(cnt) outfile(I_B1_7_3_difflang) $options
	*Part 2/2: pct of students who speak another language at home among immigrant and non-immigrant students
foreach x in immback immig {
	repest PISA, estimate(means difflang, pct) over(`x', test) by(cnt) outfile(I_B1_7_3_difflang_`x') $options
}

** Table I_B1_7_4_1 Age of arrival of immigrant students in 2022
	gen _sample_7_4 = 1 if immig == 3
repest PISA if _sample_7_4==1, estimate(freq arrival) by(cnt) outfile(I_B1_7_4_1) $options

** Table I_B1_7_5_math1, _read1, _scie1: Mathematics, reading and science performance of students with an immigrant background in 2022
	*Part 1/2: mean performance in each domain -- already computed for Chapter 2: I_B1_2_1_`domn'
	*Part 2/2: mean performance in each domain by immigrant background
** Compute also 7.8
foreach domn in $scales {
	foreach x in immback immig {
		repest PISA, estimate(summarize pv@`domn', stats(mean p10 p90 idr)) over(`x', test) by(cnt) betalog(log_`x'_stats_`domn'_2022) outfile(I_B1_7_5_`domn'_`x') $options
		}
	}

preserve
keep if !missing(escs) & !missing(immback) & !missing(difflang)
foreach domn in math read {
		repest PISA, estimate(means pv@`domn') over(immback, test) by(cnt) outfile(I_B1_7_5_`domn'_immback_fig) $options
}
foreach domn in math read {
    repest PISA, estimate(stata: reg pv@`domn' immback) by(cnt) outfile(I_B1_7_5`domn'_immback_bef, replace) $options	
}
foreach domn in math read {
    repest PISA, estimate(stata: reg pv@`domn' immback escs) by(cnt) outfile(I_B1_7_5`domn'_immback_afterescs, replace) $options	
}
foreach domn in math read {
    repest PISA, estimate(stata: reg pv@`domn' immback difflang) by(cnt) outfile(I_B1_7_5`domn'_immback_afterlang, replace) $options	
}
foreach domn in math read {
    repest PISA, estimate(stata: reg pv@`domn' immback escs difflang) by(cnt) outfile(I_B1_7_5`domn'_immback_afterf, replace) $options	
}
restore


	
** Table I_B1_7_6_math1, _read1, _scie1: Mathematics, science and reading performance of students with an immigrant background by language spoken at home in PISA 2022
foreach domn in $scales {
	repest PISA, estimate(means pv@`domn') over(same_immback, test) by(cnt) outfile(I_B1_7_6_`domn'1) $options
	}

** Table I_B1_7_7_math1, _read1, _scie1: Low performance in mathematics, reading, and science by immigrant background in 2022
	*Part 1/3: % low performers in each domain among all students: -- already computed for Chapter 4: I_B1_4_6_lp_`domn'_part1
	*Part 2/3: % low performers in each domain by immigration background
foreach domn in $scales {
	foreach x in immig immback {
	repest PISA, estimate(means lp_pv@`domn'_l, pct) over(`x', test) by(cnt) outfile(I_B1_7_7_`domn'1_`x') $options
	}
}
	*Part 3/3: logistic regression: odd ratio of scoring below level 2 in each domain for student with immigrant background, before and after accounting for other variables
foreach domn in $scales {
	capture drop _sample
	gen _sample = 1 if !missing(lp_pv1`domn'_l - lp_pv10`domn'_l, immback, boy, escs, xescs)
	repest PISA if _sample==1, estimate (stata: logit lp_pv@`domn'_l immback,or) by(cnt) outfile(I_B1_7_7_`domn'1_before) $options
	repest PISA if _sample==1, estimate (stata: logit lp_pv@`domn'_l immback boy escs xescs,or) by(cnt) outfile(I_B1_7_7_`domn'1_after) $options
	}


	
	

****************
** END OF DO-FILE
****************



