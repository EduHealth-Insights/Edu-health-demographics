*** sampling checks to detect possible anomalies for trends
*** PISA 2022/2018 comparisons

clear all
set more off, perm

** Define Workspace
cd "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"

local day = "$S_DATE"
local day = subinstr("`day'"," ","",.)

cap log close
log using "sampling_checks_`day'", text replace

 ** Printing arguments inside the log file
display "$S_TIME  $S_DATE"

** outfile directory for results 
cd "V:\PISA_INITIALREPORT_2022\results\Trends\outfile"

** core of the program: load datasets and run repest lines

foreach year in 2015 2018 2022 { 
	use *cnt *cntschid *cntstuid bookid st001d01t st003d02t age w_*  using "V:\PISA_INITIALREPORT_2022\sources/`year'\pisa`year'student" , clear
	cap ren fcnt* cnt*
	forval i = 1/12 {
		gen mob`i' = 100*(st003d02t == `i') if !mi(st003d02t)
		}
	gen uh = 100*(bookid == 99)
	collapse (mean) mob*  uh [pw = w_fstuwt], by(cnt)
	tempfile mob`year'
	save `mob`year'', replace 
}


*** Proportion of students with UH booklets - student dataset -- 2018 and 2022
** (nld anomaly in 2018)

use `mob2018', clear
append using `mob2022', gen(year)
recode year (0 = 2018) (1 = 2022)
* use real country name in output
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)

	gr bar uh if uh>0, over(year,label(angle(90))) over(cnt) asyvars name(uh, replace) ytitle("Proportion of students using UH booklets")
	gr export uh.png, name(uh) replace


*** Distribution of students by month of birth - student dataset -- 2015, 2018 and 2022
** (uk anomaly in 2018)

use `mob2018', clear
append using `mob2022' `mob2015', gen(year)
recode year (0 = 2018) (1 = 2022)  (2 = 2015)
* use real country name in output
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)

drop uh
reshape long mob@, i(cnt year) j(m)
reshape wide mob@, i(cnt m) j(year)
gen mobdiff = mob2022 - mob2018

levelsof cnt, l(countries)
levelsof cnt if mob2022 > 10 | mob2022 < 6, l(outliers) clean
local charts ""
foreach cnt in `countries' {
	if regexm("`outliers'","`cnt'") local chart `"(line mob2022 m if cnt == "`cnt'")"'
	else local chart `"(line mob2022 m if cnt == "`cnt'" , lcolor(gs15))"'
	di `"`chart'"'
	if "`charts'" == "" local charts `"`chart'"'
	else local charts  `"`charts' || `chart'"'
}
tw `charts', legend(off) name(all2022, replace)

levelsof cnt if mobdiff > 2 & !mi(mobdiff), l(different) clean
local charts ""
foreach cnt in `different' {
	tw (line mob2022 m if cnt == "`cnt'" , lw(thick)) || (line mob2018 m if cnt == "`cnt'" ) || (line mob2015 m if cnt == "`cnt'" ), title(`cnt') name(`cnt', replace)
	gr export `cnt'.png, name(`cnt') replace
}
