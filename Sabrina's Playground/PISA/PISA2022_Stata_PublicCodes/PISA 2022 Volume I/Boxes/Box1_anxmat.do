********************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Do-file for all in-depth analyses in the report
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023											  
********************************************************

clear all
set more 		off, perm
adopath ++ "c:\temp\statamacros" // where stata macro for PISA are stored (repest etc..)

** Location of files
global			confidentialdata 	"c:\temp\sources"
global			infile 				"c:\temp\Infile"
global			outfile 			"c:\temp\Outfile"
global			dofiles 			"c:\temp\Do-file"
global			logs	 			"c:\temp\Logs"


** Current directory
cd "$outfile"

** Country lists
global 			CNT2022 "ALB ARE ARG AUS AUT BEL BGR BRA BRN CAN CHE  CHL  COL CRI CZE DEU DNK DOM ESP EST FIN FRA GBR GEO GRC GTM HKG HRV HUN IDN IRL ISL ISR ITA JAM JOR JPN KAZ KHM KOR KSV LTU LVA MAC MAR MDA MEX MKD MLT MNE MNG MYS NLD NOR NZL PAN PER PHL POL PRT PRY PSE  QAT QAZ QUR ROU SAU SGP SLV SRB SVK SVN  SWE TAP THA TUR URY USA UZB VNM"  //81 countries for PISA 2022
global 			AVG2022 "AUS AUT BEL CAN CHE CHL COL CRI CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ISL ISR ITA JPN KOR LTU LVA MEX NLD NOR NZL POL PRT SVK SVN  SWE TUR USA" //37 OECD countries




** List of scales 
global 			scales "math read scie" 
global 			mscales "mpfs mpem mpin mpre mccr mcqn mcss mcud"	//UPDATE***


clear 			all
set more 		off, perm

** Open PISA 2022 dataset using only variables needed for chapter 2 analysis
local 			keep2022box1 "cnt cntschid cntstuid pv*math  w_fst* oecd xmodalisced t_fstuwt escs xescs st292* st263* anxmat"
use 			`keep2022box1' using "${confidentialdata}\2022\pisa2022completedata.dta", clear


*rename fcntstuid cntstuid

**Save chapter-specific PISA 2022 dataset
qui compress
save "${infile}/Box1.dta", replace


clear 			all
set more 		off, perm


** Use chapter-specific PISA 2022 dataset
use 			"${infile}/Box1.dta", clear

**Specify options for repest
global 			options "flag pisacoverage"
global 			options2 "flag"


** Current directory
cd 				"$outfile"

*******************************************************





*Growth mindset - no math
foreach i in 02 /*06 08*/ {
	recode st263q`i'ja (1 2=1 "Disagree") (3 4=0 "Agree") (.i .m .n=.), gen(d_st263q`i'ja)
	}

	
* Math anxiety
foreach i in 01 02 03 04 05 06 {
	recode st292q`i'ja (1 2=1 "Agree") (3 4=0 "Disagree") (.i .m .n=.), gen(d_st292q`i'ja)
	}	


** Divide the index of math anxiety (Anxmat) in quarters
* low - med - high Anxiety about math (anxmat) *
capture drop country
encode cnt, gen(country) 
tab country, m		
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace anxmat=. if anxmat==.m | anxmat==.i | anxmat==.v | anxmat==.n
capture drop anxmat_cont
gen double anxmat_cont = anxmat + e10
sum anxmat_cont
capture drop anxmat_p25
capture drop anxmat_p75
gen double anxmat_p25=.
gen double anxmat_p75=.
levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile anxmat_cont if country==`k' [aw=w_fstuwt], p(25 75)
	qui replace anxmat_p25=r(r1) if country==`k'
	qui replace anxmat_p75=r(r2) if country==`k'
	}
capture drop low_anxmat
capture drop med_anxmat
capture drop high_anxmat
capture drop lowhighanxmat
gen 		low_anxmat =.
replace 	low_anxmat=0 if anxmat_cont>anxmat_p25 & anxmat_cont!=.
replace 	low_anxmat=1 if anxmat_cont<=anxmat_p25 & anxmat_cont!=.
label var low_anxmat "Bottom quarter anxmat"
gen 		med_anxmat =.
replace 	med_anxmat=0 if (anxmat_cont<=anxmat_p25 | anxmat_cont>anxmat_p75) & anxmat_cont!=.
replace 	med_anxmat=1 if anxmat_cont>anxmat_p25 & anxmat_cont<=anxmat_p75 & anxmat_cont!=.
label var med_anxmat "Medium anxmat"
gen 		high_anxmat =. 
replace 	high_anxmat=0 if anxmat_cont<=anxmat_p75 & anxmat_cont!=.
replace 	high_anxmat=1 if anxmat_cont>anxmat_p75 & anxmat_cont!=.
label var high_anxmat "Top quarter anxmat"
gen lowhighanxmat=. 
replace lowhighanxmat=0 if low_anxmat==1 & low_anxmat!=. 
replace lowhighanxmat=1	if high_anxmat==1 & high_anxmat!=. 
label var lowhighanxmat "Top/bottom quarter anxmat"



**** TABLE 1 ****

* Table 1_1. Math anxiety means
local variables "anxmat"
foreach vr of varlist `variables' {	
		repest PISA, estimate(means `vr') by(cnt, levels($CNT2022)) outfile(Box1_mean_`vr', replace) $options	
}

* Table 1_2 Math anxiety frequencies by item
local variables "d_st292q01ja d_st292q02ja d_st292q03ja d_st292q04ja d_st292q05ja d_st292q06ja"
foreach vr of varlist `variables' {	
		repest PISA, estimate(freq `vr') by(cnt, levels($CNT2022)) outfile(Box1_freq_`vr', replace) $options		
	}

* Table 1_3. Growth mindset frequencies *
local variables "d_st263q02ja"
foreach vr of varlist `variables' {	
		repest PISA, estimate(freq `vr') by(cnt, levels($CNT2022)) outfile(Box1_freq_`vr', replace) $options	
	}

* Table 1_4. Means for math anxiety (anxmat) over growth mindset *
local variables "anxmat"
local over "d_st263q02ja"
foreach vr of varlist `variables' {
	foreach o of varlist  `over' {
		repest PISA, estimate(means `vr') over(`o', test) by(cnt, levels($CNT2022)) outfile(Box1_`vr'_`o', replace) $options
							}
			}

* Table 1_5. Frequencies for growth mindset over top/bottom of anxmat *
		repest PISA, estimate(freq d_st263q02ja) over(lowhighanxmat/*, test*/) by(cnt, levels($CNT2022)) outfile(Box1_freq_ggm_lhanxmat, replace) $options  


	

**** TABLE 2 ****

* Table 2_1. Mean score in math
		** see table I_B1_2_1_math_AVG

* Table 2_2 & 2_3. Regress math performance on math anxiety and growth mindset (before and after) *
local score "math"
local variables "anxmat d_st263q02ja"
   foreach sc in `score' {    
   foreach vr of varlist `variables' {
repest PISA, estimate (stata: reg pv@`sc' `vr' if !missing(escs) & !missing(xescs)) results(add(r2)) by(cnt, levels($CNT2022)) outfile(Box1_reg_math_`vr'_bef, replace) $options		  
repest PISA, estimate (stata: reg pv@`sc' `vr' escs xescs) results(add(r2)) by(cnt, levels($CNT2022)) outfile(Box1_reg_math_`vr'_aft, replace) $options
                             }
              }

			  
* Table 2_4.
repest PISA, estimate(stata: reg pv@math low_anxmat high_anxmat d_st263q02ja if !missing(escs)) by(cnt, levels($CNT2022)) outfile(Box1_reg_anxmat_ggm_escs_bef, replace) $options
repest PISA, estimate(stata: reg pv@math low_anxmat high_anxmat d_st263q02j escs) by(cnt, levels($CNT2022)) outfile(Box1_reg_anxmat_ggm_escs_aft, replace) $options  
			  
	  
* Table 2_5. Math score over Growth Mindset according to low/high anxmat
local score "math"
local over "d_st263q02ja"
foreach sc in `score' { 
	foreach o of varlist `over' {
	repest PISA if lowhighanxmat == 0, estimate(means pv@`sc') over(`o', test) by(cnt, levels($CNT2022)) outfile(Box1_mean_`sc'_`o'_0, replace) $options
	repest PISA if lowhighanxmat == 1, estimate(means pv@`sc') over(`o', test) by(cnt, levels($CNT2022)) outfile(Box1_mean_`sc'_`o'_1, replace) $options
		}
	}

	repest PISA if lowhighanxmat == 0, estimate(stata: reg pv@math d_st263q02j) by(cnt, levels($CNT2022)) outfile(Box1_regaddinbef_low, replace) $options
	repest PISA if lowhighanxmat == 0, estimate(stata: reg pv@math d_st263q02j escs) by(cnt, levels($CNT2022)) outfile(Box1_regaddinaft_low, replace) $options
	repest PISA if lowhighanxmat == 1, estimate(stata: reg pv@math d_st263q02j) by(cnt, levels($CNT2022)) outfile(Box1_regaddinbef_high, replace) $options
	repest PISA if lowhighanxmat == 1, estimate(stata: reg pv@math d_st263q02j escs) by(cnt, levels($CNT2022)) outfile(Box1_regaddinaft_high, replace) $options

	
	