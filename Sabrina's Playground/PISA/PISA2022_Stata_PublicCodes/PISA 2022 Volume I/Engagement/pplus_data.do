*** PPLUS DATA, 2018 and 2022

** Define Workspace
cd "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"

*** location of source files
local pisa2018cog "V:\EDUCATION_DATALAKE\sources\PISA\PISA 2018\Stata\COG/pisa2018_cog_puf"
local pisa2022cog "V:\PISA_INITIALREPORT_2022\sources\2022\pisa2022cog.dta"


*** define lists of reading, math and science items (CBA only)

local keep "*cnt *cntschid *cntstuid adminmode bookid  cm*s dm*c cr*s dr*c cs*s ds*c " 
foreach year in 2018 2022 { 
	use `keep' using "`pisa`year'cog'" if _n<1, clear // load only variable names and labels !!!

foreach domn in read math scie {
global `domn'`year'items ""
local d = substr("`domn'",1,1)
	foreach var of varlist c`d'* d`d'* {
		local label : variable label `var'
		if regexm("`label'","Scored Response") | regexm("`label'","Coded Response") global `domn'`year'items "${`domn'`year'items} `var'"
		}
	di "${`domn'`year'items}"
}

global rflu`year'items "" 
	foreach var of varlist cr590* {
		local label : variable label `var'
		if regexm("`label'","Scored Response") global rflu`year'items "${rflu`year'items} `var'"
		}
	di "${rflu`year'items}"
	
global read`year'items : list global(read`year'items) - global(rflu`year'items) // excluding reading fluency from reading pplus
}

global mathtrenditems : list global(math2022items) & global(math2018items)

*** load data, compute pplus
local keep "*cnt *cntschid *cntstuid adminmode bookid cm*s dm*c cr*s dr*c cs*s ds*c " 
foreach year in 2018 2022 { 
	use `keep' using "`pisa`year'cog'" , clear // load all data !!!
	keep if bookid != 99 // drop UH students
	keep if adminmode == 2 // cba only

***PPLUS***	
** recode single and double digit items **

	foreach var of varlist ${math`year'items} ${read`year'items} ${rflu`year'items} ${scie`year'items}  {
		qui su `var'
		if r(max) == 1 {
			recode `var' (1 = 1) (.m = 0)
			}
		else if r(max) == 2 {
			recode `var' (1 = .5) (2 = 1) (.m = 0)
			}
		else if r(max) > 10 & r(max) < 20 {
			recode `var' (1/9 = 0) (10/19 = 1)  (.m = 0)
			}
		else if r(max) >= 20 {
			recode `var' (1/9 = 0) (10/19 = .5)  (20/29 = 1)   (.m = 0)
			}
		}

// compute pplus, total, and count
foreach domn in rflu`year' mathtrend read`year' math`year' scie`year' { //
	cap drop `domn'total 
	egen `domn'total = rowtotal(${`domn'items}), missing
	cap drop `domn'count 
	egen `domn'count = rownonmiss(${`domn'items})
	cap drop `domn'pplus 
	gen `domn'pplus = (`domn'total/`domn'count) if `domn'count > 0
	}


***PPLUS BY STAGE (MATH 2022)***	

if `year' == 2022 { 
	*** define math item sets
	preserve
	do "G:\Code\PISA2022\volume1\Engagement\mathdesign.do"
	restore
	
	// compute pplus, total, and count
	foreach set in setA setB setC  { //
		cap drop `set'total 
		egen `set'total = rowtotal(${item`set'}), missing
		cap drop `domn'count 
		egen `set'count = rownonmiss(${item`set'})
		cap drop `set'pplus 
		gen `set'pplus = (`set'total/`set'count) if `set'count > 0
		}	
}
	
foreach var of varlist *pplus {
	su `var', d
}

keep *cnt *cntschid *cntstuid adminmode bookid  *pplus
save pplus`year', replace
}

use *cnt* m* using V:\PISA_INITIALREPORT_2022\sources\2022\pisa2022cog.dta, clear
 merge 1:1 *cnt *cntschid *cntstuid using pplus2022, nogen
 gen pplusstage0 = .
 gen pplusstage1 = .
 gen pplusstage2 = .
 
	replace pplusstage0 = setApplus if mcore_itemset == 1
	replace pplusstage1 = setApplus if ms1_itemset == 1
	replace pplusstage2 = setApplus if ms2_itemset == 1

	replace pplusstage0 = setBpplus if mcore_itemset == 2
	replace pplusstage1 = setBpplus if ms1_itemset == 2
	replace pplusstage2 = setBpplus if ms2_itemset == 2

	replace pplusstage0 = setCpplus if mcore_itemset == 3
	replace pplusstage1 = setCpplus if ms1_itemset == 3
	replace pplusstage2 = setCpplus if ms2_itemset == 3
	
 reshape long pplusstage@, i(fcnt fcntschid fcntstuid) j(stage)
 save pplus2022bystage, replace
