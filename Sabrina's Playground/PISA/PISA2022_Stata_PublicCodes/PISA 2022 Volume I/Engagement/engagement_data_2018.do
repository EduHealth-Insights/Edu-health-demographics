
** Define Workspace
cd "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"

**********************************************************
** timing data (total time: c*tt) and missing responses **
**********************************************************

local keep "cnt cntschid cntstuid adminmode bookid c*tt " 
use `keep' using "V:\EDUCATION_DATALAKE\sources\PISA\PISA 2018\Stata\TTM/pisa2018_cog_timevisits_puf", clear 
	merge 1:1 cnt cntschid cntstuid adminmode bookid using  "V:\EDUCATION_DATALAKE\sources\PISA\PISA 2018\Stata\COG/pisa2018_cog_puf", nogen keep(3) keepusing(cnt cntschid cntstuid adminmode bookid cr590*t dr590*r cm*s dm*c cr*s dr*c cs*s ds*c )
// note: in 2018 rflu total time as in the original timing data (COG)

keep if bookid != 99 // drop UH students
keep if adminmode == 2 // cba only
cap drop hour*
gen hour1 = "" 
gen hour2 = "" 


// design, based on CY7_GEN_Main Survey Integrated Design[Final]_1.docx

replace hour1 = "read" if (inlist(bookid,1,2,3,4,5,6) | inlist(bookid,13,14,15,16,17,18) | inlist(bookid,25,26,27,28,29,30) | inlist(bookid,37,38,39,40,41,42) | inlist(bookid,49,50,51,52,53,54) | inlist(bookid,61,62,63,64,65,66))  & adminmode == 2 // booklets 1-6, 13-18, etc. 
replace hour2 = "read" if bookid<=72 & hour1 != "read"  & adminmode == 2  // booklets  7-12, 19-24, etc. 
replace hour1 = "math" if inlist(bookid,7,8,9,10,11,12)  	& adminmode == 2
replace hour2 = "math" if inlist(bookid,1,2,3,4,5,6)  		& adminmode == 2
replace hour1 = "scie" if inlist(bookid,19,20,21,22,23,24)  & adminmode == 2
replace hour2 = "scie" if inlist(bookid,13,14,15,16,17,18)  & adminmode == 2
replace hour1 = "m__s" if inlist(bookid,31,32,33,34,35,36)  & adminmode == 2
replace hour2 = "m__s" if inlist(bookid,25,26,27,28,29,30)  & adminmode == 2
replace hour1 = "gcom" if inlist(bookid,43,44,45,46,47,48)  & adminmode == 2
replace hour2 = "gcom" if inlist(bookid,37,38,39,40,41,42)  & adminmode == 2
replace hour1 = "gc_s" if inlist(bookid,55,56,57,58,59,60)  & adminmode == 2
replace hour2 = "gc_s" if inlist(bookid,49,50,51,52,53,54)  & adminmode == 2
replace hour1 = "gc_m" if inlist(bookid,67,68,69,70,71,72)  & adminmode == 2
replace hour2 = "gc_m" if inlist(bookid,61,62,63,64,65,66)  & adminmode == 2

*** define lists of reading, math and science timings

foreach domn in math read scie  {
global `domn'times ""
local d = substr("`domn'",1,1)
	foreach var of varlist c`d'*tt {
		local label : variable label `var'
		if regexm("`label'","Total Time") global `domn'times "${`domn'times} `var'"
		}
	di "${`domn'times}"
}


global rflutimes "" 
	foreach var of varlist cr590*t {
		local label : variable label `var'
		if regexm("`label'","Timing") global rflutimes "${rflutimes} `var'"
		}
	di "${rflutimes}"



*** define lists of reading, math and science items (CBA only)

foreach domn in read math scie {
global `domn'items ""
local d = substr("`domn'",1,1)
	foreach var of varlist c`d'* d`d'* {
		local label : variable label `var'
		if regexm("`label'","Scored Response") | regexm("`label'","Coded Response") global `domn'items "${`domn'items} `var'"
		}
	di "${`domn'items}"
}

global rfluitems "" 
	foreach var of varlist cr590* {
		local label : variable label `var'
		if regexm("`label'","Scored Response") global rfluitems "${rfluitems} `var'"
		}
	di "${rfluitems}"
	

	//  totaltime per subject (science)

foreach domn in math read scie rflu { //
	cap drop `domn'totaltime
	egen `domn'totaltime = rowtotal(${`domn'times}), missing
	replace `domn'totaltime = `domn'totaltime/60000 // total time in minutes
	replace `domn'totaltime = min(`domn'totaltime,65) if !missing(`domn'totaltime) // topcode at 65min
	}
replace rflutotaltime = min(rflutotaltime,3) if !missing(rflutotaltime) // topcode at 3min (maximum allowed)

// totaltime per hour (math and science only)
foreach h in 1 2 {
	cap drop h`h'_time 
	gen h`h'_time = . // totaltime per "hour" of testing; excluding booklets with GC
	foreach domn in read math scie  { 
		replace h`h'_time  = `domn'totaltime if hour`h' == "`domn'"
		replace h`h'_time = `domn'totaltime if hour`h' == "`domn'"
		}
	replace h`h'_time = min(mathtotaltime+scietotaltime,60) if hour`h' == "m__s" & mathtotaltime+scietotaltime != .
	}	

// totaltime ; excluding booklets with GC
gen totaltime = h1_time + h2_time
	



// missing responses and rapid responses 

* skipped (sk) and not-reached (nr) dummies 
foreach it of varlist c*s d*c {
	local sk = substr(regexr("`it'","^d","c"),1,length("`it'")-1) + "sk"
	local nr = substr(regexr("`it'","^d","c"),1,length("`it'")-1) + "nr"
	cap drop `sk'
	cap drop `nr'
	qui recode `it' (.m = 1) (.i .n  = .) (.r = 0) (nonmissing = 0) , gen(`sk')
	qui recode `it' (.r = 1) (.i .n  = .) (.m = 0) (nonmissing = 0) , gen(`nr')
}

foreach domn in read math scie {
local d = substr("`domn'",1,1)
	unab `domn'sk : c`d'*sk
	unab `domn'nr : c`d'*nr
}

// define dummies (and list of dummies) identifying rapid guess responses 
foreach domn in read math scie {
local `domn'rr "" 
foreach tt of varlist $`domn'times {
	local rr = substr("`tt'",1,length("`tt'")-2) + "rr"
	cap drop `rr'
	gen `rr' = `tt' < 5000 if !missing(`tt')	// less than 5000 milliseconds
		local stub = substr("`tt'",2,length("`tt'")-3) 
		foreach fvar in d`stub'c c`stub's {
			cap confirm numeric variable `fvar' 
			if !_rc {
				replace `rr' = 0 if `fvar' == .r  |  `fvar' == .m 	// non-reached/skipped items are not rapid responses, regardless of timing 
				replace `rr' = . if `fvar' == .i  |  `fvar' == .n 	// other missings are ignored 
				}
		}
	local `domn'rr = "``domn'rr' " + "`rr'"
	}
// list of dummy variables for items exhibiting rapid response (guessing) behaviour
di "``domn'rr'"
}
	
// rapid responses, skipped, nonreached: compute proportion, total, and coun -- per domain
foreach type in rr sk nr { 
foreach domn in read math scie { //
	cap drop `domn'`type'total 
	egen `domn'`type'total = rowtotal(``domn'`type'')
	cap drop `domn'`type'count 
	egen `domn'`type'count = rownonmiss(``domn'`type'')
	cap drop `domn'`type'prop 
	gen `domn'`type'prop  = `domn'`type'total/`domn'`type'count if `domn'`type'count > 0 
	}
}

// rapid responses, skipped, nonreached: compute proportion, total, and count -- per hour
foreach type in rr sk nr { 
foreach h in 1 2 {
	cap drop h`h'`type'prop 
	gen h`h'`type'prop = . 
	foreach domn in read math scie  { 
		replace h`h'`type'prop = `domn'`type'prop if hour`h' == "`domn'"
		replace h`h'`type'prop = `domn'`type'prop if hour`h' == "`domn'"
		}
	replace h`h'`type'prop = ((math`type'count + scie`type'count)-(math`type'total+scie`type'total))/(math`type'count + scie`type'count) if hour`h' == "m__s"
	}
}

// reading fluency : straightlining patterns	

**** Reading Fluency - patterned responses

global rfluresp "" 
	foreach var of varlist dr590*r {
		local label : variable label `var'
		if regexm("`label'","Raw Response") global rfluresp "${rfluresp} `var'"
		}
	di "${rfluresp}"

**all "yes"
**all "no"

tempvar totalresp count 
	egen `totalresp' = rowtotal(${rfluresp}), missing
	egen `count' = rownonmiss(${rfluresp})
codebook `totalresp' `count'
cap drop rfluallsame
	gen rfluallsame = (`totalresp'/`count' == 1) + (`totalresp'/`count' == 2) if `count' > 0


keep cnt cntschid cntstuid adminmode bookid hour* *count *total *prop *time rfluallsame 
save engagement2018, replace

 