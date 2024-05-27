********************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 3: Analysis
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		)
********************************************************

clear 			all
set more 		off, perm

** Run environment & data preparation do-files
run 			"c:\temp\pisa2022vol1_environment.do"
run 			"c:\temp\Chapter 3\pisa2022vol1_preparation_ch3.do"

** Use chapter-specific PISA 2022 dataset
use 			"${infile}/I_B1_CH3_cnt.dta", clear

** Specify options for repest
global 			options "flag pisacoverage"
global 			options2 "flag"

** Current directory
cd 				"$outfile"


cap log close
	log using "${logs}/ch3", text replace


*******************************************************

** Tables I_B1_CH3_1_M to _MU (% proficiency level in math, reading, science and 8 math subscales)

foreach domn in $scales { 
	repest PISA, estimate(freq pv@`domn'_l) by(cnt, levels($CNT2022)) outfile(I_B1_3_1_`domn') $options2
	}
	
foreach domn in $mscales { 
	repest PISA, estimate(freq pv@`domn'_l) by(cnt, levels($CNT2022)) outfile(I_B1_3_1_`domn') $options2
	}


** Tables I_B1_CH3_2_TP, _LP (overlap of top Performers and low Performers across three main domains) (RMS = Reading_Math_Science)

foreach side in tp lp {
	repest PISA, estimate(freq `side'_pv@RMS) results(combine(mathplus:  100*_b[`side'_pv@RMS_8]/( _b[`side'_pv@RMS_3]+ _b[`side'_pv@RMS_5]+ _b[`side'_pv@RMS_7]+ _b[`side'_pv@RMS_8]))) by(cnt, levels($CNT2022)) outfile(I_B1_3_2_`side') $options2 
	}


	
** Table trends: percentage of low and top performers in each domain
foreach side in tp lp {
	foreach domn in $scales { 
		repest PISA, estimate(means `side'_pv@`domn'_l, pct)  by(cnt, levels($CNT2022)) outfile(I_B1_3_3_`side'_`domn') $options2
	}
}

*******************************************************
** END OF DO-FILE
*******************************************************

cap log close

