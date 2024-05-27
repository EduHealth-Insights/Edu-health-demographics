********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Tables for  Ch2
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

** Table II.B1.2.1

*Percentage of missing values
tab cnt d_covid , m matcell(missing)

forvalues i = 1/81 {
		matrix temp[`i',1] = missing[`i',3] + missing[`i',1]+ missing[`i',2]
		local ++i
		*matrix missing= missing,temp
		*matrix missing[`i',5]= missing[`i',3]/missing[`i',4]
	}
	foreach depvar of local indicators{
    foreach invar of local invars{
            matrix result_`invar'_`depvar'=J(1, 3, .)            
            svy: regress `depvar' dummy if Year==2010 & invars==`invar'
             matrix temp1_`invar'_`depvar'=r(table)
            matselrc temp1_`invar'_`depvar' temp2_`invar'_`depvar', c(1) r(1 2 4)
            matrix temp2_`invar' = temp2_`invar'_`depvar''
            matrix result_`invar'= result_`invar'_`depvar'\temp2_`invar'_`depvar'
            }
}
gen miss = missing[1:_N,3]/(missing[1:_N,1] + missing[1:_N,2])
missings report d_covid
save pisa22vol2_type1_missing_st347q01ja, replace

local variables "st347*"
foreach vr of varlist `variables' {	
		repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type1_freq_`vr', replace) pisacoverage flag 
}

** Table II.B1.2.2

global over "d_covresp d_covresp0 d_covresp12"
local variables "boy immback iscedlev3 d_grade"
foreach vr in `variables' {
	foreach ov in $over {			 
		repest PISA, estimate(means `vr', pct) over(`ov', test)  by(cnt) outfile(pisa22vol2_type14st_`vr'_`ov', replace) pisacoverage flag
	}
}


** Table II.B1.2.3

// Frequency repest (see Table 1 chapter 2) variable: st226q01ja

** Table II.B1.2.4

// See Trends do-file for Chapter 2 

** Table II.B1.2.5

// Mean, sd and frequency repest (see Table 1 Chapter 1) variables: sdleff and st355

** Table II.B1.2.6

// See Table II.B1.1.2 variable sdleff

** Table II.B1.2.7

// See Table Table II.B1.1.3 variable sdleff

** Table II.B1.2.8

// See Table II.B1.1.8 variable sdleff

** Table II.B1.2.9

// See Table II.B1.1.8 variable sdleff

** Table II.B1.2.10

// See Table II.B1.1.8 variable sdleff

** Table II.B1.2.11

repest PISA, estimate (stata: reg sdleff escs if !missing(pv@math)) results(add(r2)) by(cnt) outfile(pisa22vol2_type15st_gap_sdleff_escs_BEF, replace) pisacoverage flag
repest PISA, estimate (stata: reg sdleff pv@math escs) 				results(add(r2)) by(cnt) outfile(pisa22vol2_type15st_gap_sdleff_escs_AFT, replace) pisacoverage flag

** Tables II.B1.2.12 to 18

// See Table II.B1.1.1 variable persevagr st307 curioagr st301 coopagr st343 empatagr st311 asseragr st305 stresagr st345 emocoagr st313

** Table II.B1.2.19

// See Table II.B1.1.8 variable persevagr curioagr coopagr empatagr asseragr stresagr emocoagr

** Table II.B1.2.20 and 21

// See Table II.B1.1.3 variable persevagr st351 curioagr

** Table II.B1.2.22 to 24

// Mean, sd and frequency repest (see Table 1 Chapter 1) variable scprepbp scprepap sc223 sc224 r_sc223 feellah st3354

** Table II.B1.2.25

// See Table II.B1.1.3 variable d_st354q03

** Table II.B1.2.26 to 28 

// See Table II.B1.1.8 variable feellah d_st354

** Table II.B1.2.29

global variables "d_st354q01ja d_st354q02ja d_st354q03ja d_st354q04ja d_st354q05ja d_st354q06ja d_st354q07ja d_st354q08ja d_st354q09ja d_st354q10ja" //d_st348 schsust items st351 material items st267q quality of relationship items st273 disclim items st270q teacher support item
global outcome "sdleff"
foreach vr in $variables {
	foreach out in $outcome {
		repest PISA, estimate (stata: reg `out' `vr' if !missing(escs) & !missing(xescs) & !missing(pv@math)) results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_BEF, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' escs xescs if !missing(pv@math)) 						  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT1, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' escs xescs pv@math) 						  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT2, replace) pisacoverage flag
		}
}

** Table II.B1.2.30

// See Table II.B1.1.1 variable probself st352

** Table II.B1.2.31

// See Table II.B1.1.3 variable probself

** Table II.B1.2.32 to 34

// See Table II.B1.1.8 variable probself d_st352

** Table II.B1.2.35

// See Table II.B1.2.29  variable probself d_st352

** Table II.B1.2.36

// See Table II.B1.1.1 variable schsust st348

** Table II.B1.2.37

// See Table II.B1.1.3 variable schsust

** Table II.B1.2.38 to 40

// See Table II.B1.1.8 variable schsust d_st348

** Table II.B1.2.41

global variables "schsust"
global outcome "r_lifesat belong sdleff anxmat grosagr bsmj"

foreach vr in $variables {
	foreach out in $outcome {
		repest PISA, estimate (stata: reg `out' `vr' if !missing(escs) & !missing(xescs) & !missing(pv@math)) results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_BEF, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' escs xescs if !missing(pv@math)) 						  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT1, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' pv@math escs xescs)  									  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT2, replace) pisacoverage flag
	}
}

** Table II.B1.2.42 to 43

global variables "d_st348q01ja d_st348q02ja d_st348q03ja d_st348q04ja d_st348q05ja d_st348q06ja d_st348q07ja d_st348q08ja  " //d_st348 schsust items st351 material items st267q quality of relationship items st273 disclim items st270q teacher support item
global outcome "anxmat" //belong sdleff r_lifesat"
foreach vr in $variables {
	foreach out in $outcome {
		repest PISA, estimate (stata: reg `out' `vr' if !missing(escs) & !missing(xescs) & !missing(pv@math)) results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_BEF, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' escs xescs if !missing(pv@math)) 						  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT1, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' pv@math escs xescs)  									  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT2, replace) pisacoverage flag
	}
}

** Table II.B1.2.44

global variables " schsust" //
global group 	"lowhighescs iscedlev3 immback boy"
global outcome 	"anxmat"

foreach vr in $variables {
	foreach out in $outcome {	
		foreach gr in $group {
			repest PISA, estimate (stata: reg `out' `vr' if !missing(escs) & !missing(xescs)) over(`gr', test)  results(add(r2)) by(cnt) outfile(pisa22vol2_type9st_reg_`out'_`vr'_`gr'_BEF, replace) pisacoverage flag
			repest PISA, estimate (stata: reg `out' `vr' escs xescs) 						  over(`gr', test)  results(add(r2)) by(cnt) outfile(pisa22vol2_type9st_reg_`out'_`vr'_`gr'_AFT, replace) pisacoverage flag
		}
	}
}
