*** indicators of non-effortful responding 
*** PISA 2022/2018 comparisons

clear all
set more off, perm

** Define Workspace
global sandbox "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"

cd "$sandbox"
local day = "$S_DATE"
local day = subinstr("`day'"," ","",.)

cap log close
log using "engagement_`day'", text replace

** Printing arguments inside the log file
display "$S_TIME  $S_DATE"

*** data preparation 
*do "G:\Code\PISA2022\volume1\Engagement\engagement_data_2018"
*do "G:\Code\PISA2022\volume1\Engagement\engagement_data_2022"
*do "G:\Code\PISA2022\volume1\Engagement\pplus_data"

global pisa2018student "V:\EDUCATION_DATALAKE\sources\PISA\PISA 2018\Stata\STU/pisa2018_student_puf"  
global pisa2022student "V:\PISA_INITIALREPORT_2022\sources/2022\pisa2022student"
** outfile directory for results 
cd "V:\PISA_INITIALREPORT_2022\results\Trends\outfile"

** core of the program: load datasets and run repest lines

*********************************************************
*** self-report effort / loweffort /relative effort  ****
*********************************************************

use *cnt* w_* st331q01ja st331q02ja effort1 effort2 using "$pisa2022student", clear
	mdesc st331q01ja st331q02ja effort1 effort2
	pwcorr st331q01ja st331q02ja effort1 effort2

foreach year in 2018 2022 {
		use *cnt *cntschid *cntstuid effort1 effort2 st004d01t w_* using "${pisa`year'student}" , clear
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		recode effort1 effort2 (0 = .m)	// NOTE/ in 2018 value 0 was assigned to students who did not answer this question (but saw it)!
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		cap ren (fcnt fcntschid) (cnt cntschid)
		gen lesseffort = 100*(effort1 < effort2) if !missing(effort1,effort2)
		repest PISA, estimate(means effort1 effort2 lesseffort) pisacoverage by(cnt) outfile(effort_selfreport_`year') 
		repest PISA, estimate(means effort1 effort2 lesseffort) pisacoverage over(male, test) by(cnt)  outfile(effort_selfreport_gender_`year') 
}

pisatrend, table(effort_selfreport) first(2018) last(2022)
pisatrend, table(effort_selfreport_gender) first(2018) last(2022)

** graphic inspection
use effort_selfreport_2018, clear
append using effort_selfreport_2022, gen(year)
recode year (0 = 2018) (1 = 2022)

	gr bar effort1_m_b, over(cnt) over(year) name(effort1, replace) sort(effort1_m_b)

use  effort_selfreport_1822, clear
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	gr bar effort1_m_diff_b, over(cnt, sort(1) label(angle(90))) name(pisaeffort, replace) xsize(12) ytitle("Difference in effort spent on the PISA test" "(2022 - 2018)") nofill
	gr bar lesseffort_m_diff_b, over(cnt, sort(1) label(angle(90))) name(lesseffort, replace) xsize(12) ytitle("Difference in the share of students" "spending less effort than if the test counted"  "(2022 - 2018)") nofill
	gr export lesseffort_trend.png, name(lesseffort) replace
	gr export pisaeffort_trend.png, name(pisaeffort) replace

************************************************************************************************
*** missing and invalid responses: rapid guessing, non-reached, skipped (only science, cba) ****
************************************************************************************************

foreach year in 2022 2018  {
		use *cnt* w_* st004d01t using "${pisa`year'student}" , clear
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		merge 1:1 *cnt *cntschid *cntstuid using "${sandbox}/engagement`year'", nogen
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		repest PISA if hour1 == "scie" | hour2 == "scie", estimate(means scierrprop scieskprop scienrprop, pct) pisacoverage by(cnt) outfile(scieresponse_`year') 
		repest PISA if hour1 == "scie" | hour2 == "scie", estimate(means scierrprop scieskprop scienrprop, pct) pisacoverage over(male, test) by(cnt)  outfile(scieresponse_gender_`year') 
}
	
pisatrend, table(scieresponse) first(2018) last(2022)
pisatrend, table(scieresponse_gender) first(2018) last(2022)

** graphic inspection
use  scieresponse_1822, clear
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	foreach type in rr sk nr {
		gr bar scie`type'prop_m_diff_b, over(cnt, sort(1) label(angle(90))) name(`type', replace) xsize(12) ytitle("Difference in missing/invalid responses (type: `type')" "Science (2022 - 2018)") nofill
	gr export `type'trend.png, name(`type') replace
	}

	
******************************************************************************
*** Percent-correct: science, maths (linear test, trend items only), rflu ****
******************************************************************************


foreach year in 2022 2018  {
		use *cnt* w_* st004d01t pv*scie pv*math pv*read using "${pisa`year'student}" , clear
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		merge 1:1 *cnt *cntschid *cntstuid using "${sandbox}/pplus`year'", nogen
		merge 1:1 *cnt *cntschid *cntstuid using "${sandbox}/engagement`year'", nogen
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		ren scie`year'pplus sciepplus
		ren rflu`year'pplus rflupplus
		if "`year'" == "2022" {
			replace mathtrendpplus = . if mpath != 1 // consider only linear test 
			replace math2022pplus = . if mpath != 1 // consider only linear test 
			}
		else gen mpath = 1
*** performance (pplus)
		repest PISA, estimate(means sciepplus mathtrendpplus rflupplus, pct) pisacoverage by(cnt) outfile(pplus_`year') 
***  performance decline H2/H1 (2018 and 2022)
		foreach domn in math scie read {
			gen `domn'hour = .
			replace `domn'hour = 1 if hour1 == "`domn'"
			replace `domn'hour = 2 if hour2 == "`domn'"
			}
		repest PISA if hour1 == "scie" | hour2 == "scie", estimate(means sciepplus , pct) pisacoverage by(cnt) over(sciehour, test) outfile(scieendurance_`year') 
		repest PISA if (hour1 == "math" | hour2 == "math") & mpath == 1, estimate(means mathtrendpplus , pct) pisacoverage by(cnt) over(mathhour, test) outfile(mathtrendendurance_`year') 
		if "`year'" == "2022" repest PISA if mpath == 1, estimate(means math2022pplus , pct) pisacoverage by(cnt) over(mathhour, test) outfile(math2022endurance_`year') 
		repest PISA, estimate(means pv@scie) pisacoverage by(cnt) over(sciehour, test) outfile(pvscieendurance_`year') 
		repest PISA, estimate(means pv@math) pisacoverage by(cnt) over(mathhour, test) outfile(pvmathendurance_`year') 
		repest PISA, estimate(means pv@read) pisacoverage by(cnt) over(readhour, test) outfile(pvreadendurance_`year') 
		}
	
pisatrend, table(pplus) first(2018) last(2022)
pisatrend, table(scieendurance) first(2018) last(2022)
pisatrend, table(mathtrendendurance) first(2018) last(2022)
pisatrend, table(pvscieendurance) first(2018) last(2022)
pisatrend, table(pvmathendurance) first(2018) last(2022)
pisatrend, table(pvreadendurance) first(2018) last(2022)

** graphic inspection
use  pplus_1822, clear
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	foreach domn in scie mathtrend rflu {
		gr bar `domn'pplus_m_diff_b, over(cnt, sort(1) label(angle(90))) name(`domn'pplus, replace) xsize(12) ytitle("Difference in percent correct " "`domn' (2022 - 2018)") nofill
	gr export `domn'pplustrend.png, name(`domn'pplus) replace
	}

foreach domn in math scie {
	use  `domn'endurance_2022, clear
	* use real country name in graphs
		ren cnt fcnt
		merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
		gr bar _d_`domn'*pplus_m_b, over(cnt, sort(1) label(angle(90))) name(`domn'decline, replace) xsize(12) ytitle("Difference in percent correct " "`domn' 2022 (H2 - H1)") nofill
	gr export `domn'decline.png, name(`domn'decline) replace
		}
	
use mathendurance_2022, clear
merge 1:1 cnt using scieendurance_2022, nogen
	* use real country name in graphs
		ren cnt fcnt
		merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
tw scatter _d_mathtrendpplus_m_b _d_sciepplus_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("science decline (H2 - H1)") ytitle("math decline (H2 - H1)") title("Academic endurance (2022)") name(endurance)
	gr export decline2022.png, name(endurance) replace

** math position effects (core/stage 2, non adaptive, 2022 only)

use *cnt* w_* st004d01t using "${pisa2022student}" , clear
recode st004d01t (1 = 0) (2 = 1), gen(male)
merge 1:m *cnt *cntschid *cntstuid using "${sandbox}/pplus2022bystage", nogen
cap ren fcnt* cnt*
*** performance (pplus) (core/stage 1/stage 2, non adaptive, 2022 only)
repest PISA if mpath == 1, estimate(means pplusstage, pct) over(stage, test) pisacoverage by(cnt) outfile(pplusbystage) 
repest PISA if mpath == 1 & !mi(setApplus) & !mi(setBpplus) & !mi(setCpplus) , estimate(means pplusstage, pct) over(stage, test) pisacoverage by(cnt) outfile(pplusbystage_nm) // same, but only among those who reached stage 2 


** graphic inspection
foreach graph in pplusbystage pplusbystage_nm {
use  `graph', clear
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	keep cnt *_b
	reshape long _@_pplusstage_m_b, i(cnt) j(stage) string
	gr bar __pplusstage_m_b, over(stage) over(cnt, sort(1) label(angle(90)))  name(`graph', replace) xsize(12) ytitle("Percent correct by position " "(Mathematics, linear sample)") nofill
	gr export `graph'.png, name(`graph') replace
}

*** overall response time per hour

*** breakoffs (Percentage of students with non-reached items within the first 45 minutes of testing )

*************************************
*** total time spent on the test ****
*************************************

foreach year in 2022 2018 {
		use *cnt* w_* st004d01t using "${pisa`year'student}" , clear
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		merge 1:1 *cnt *cntschid *cntstuid using "${sandbox}/engagement`year'", nogen
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		cap drop minutes
		gen minutes = _n if _n < 65
		foreach domn in math read scie {
			cap drop temp
			cap drop `domn'density
			kdensity `domn'totaltime [aw = w_fstuwt], at(minutes) nograph gen(temp `domn'density)
			}
			tw (line mathdensity min, lw(thick)) || (line sciedensity min) || (line readdensity min, lp(dash)), title("Total time spent on each test (`year')") name(time`year', replace)
	gr export time`year'.png, name(time`year') replace

	** two-domain tests in 2018
	if "`year'" == "2018" {
			foreach domn in math scie {
				cap drop temp
				cap drop `domn'density*
				kdensity `domn'totaltime [aw = w_fstuwt] if hour1 == "`domn'" | hour2 == "`domn'", at(minutes) nograph gen(temp `domn'density_hour)
				cap drop temp
				kdensity `domn'totaltime [aw = w_fstuwt] if hour1 == "m__s" | hour2 == "m__s", at(minutes) nograph gen(temp `domn'density_half)
			}
			tw (line mathdensity_hour min, lw(thick)) || (line sciedensity_hour min) || (line mathdensity_half min, lw(thick)) || (line sciedensity_half min), title("Total time spent on m/s tests (2018)" "by type of booklet") name(time_ms , replace) legend(label(1 "Math, 1h") label(2 "Scie, 1h") label(3 "math, mixed") label(4 "scie, mixed"))
	gr export timemathscie2018.png, name(time_ms) replace
		}
			
	}

*********************************************
*** reading fluency: fast and patterned *****
*********************************************

foreach year in  2018  { //2022
		use *cnt* w_* st004d01t using "${pisa`year'student}" , clear
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		merge 1:1 *cnt *cntschid *cntstuid using "${sandbox}/engagement`year'", nogen
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		replace rfluallsame = rfluallsame*100 // in percentage points
		replace rflutotaltime = rflutotaltime*60 // in seconds
		repest PISA if hour1 == "read" | hour2 == "read", estimate(means rfluallsame rflutotaltime) pisacoverage by(cnt) outfile(rflu_`year') 
		repest PISA if hour1 == "read" | hour2 == "read", estimate(means rfluallsame rflutotaltime) pisacoverage by(cnt) over(male, test) outfile(rflu_gender_`year') 
		}
	
pisatrend, table(rflu) first(2018) last(2022)
pisatrend, table(rflu_gender) first(2018) last(2022)

** graphic inspection
use  rflu_1822, clear
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	foreach var in rfluallsame rflutotaltime {
		gr bar `var'_m_diff_b, over(cnt, sort(1) label(angle(90))) name(`var', replace) xsize(12) ytitle("Difference in reading fluency" "`var' (2022 - 2018)") nofill
	gr export `var'_trend.png, name(`var') replace
	}

** principals' support for PISA administration

*******************************************************
** questionnaire straightlining (Sense of belonging) **
*******************************************************

foreach year in 2022 2018 {
		use *cnt* w_* st004d01t st034* using "${pisa`year'student}" , clear
		recode st004d01t (1 = 0) (2 = 1), gen(male)
		cap ren fcnt* cnt*
			if "`year'" == "2018" {
				merge m:1 cnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(3)
				drop cnt 
				}
		cap ren fcnt* cnt*
		recode st* (0 = .m)
		gen esl = 1 if mi(st034q01ta)+mi(st034q02ta)+mi(st034q03ta)+mi(st034q04ta)+mi(st034q05ta)+mi(st034q06ta) <= 1
		gen sl = 1 if mi(st034q01ta)+mi(st034q02ta)+mi(st034q03ta)+mi(st034q04ta)+mi(st034q05ta)+mi(st034q06ta) <= 1
		egen belongneg = rowmean(st034q01ta st034q04ta st034q06ta)
		egen belongpos = rowmean(st034q02ta st034q03ta st034q05ta)
		replace sl = 0 if !mi(sl) & belongneg != belongpos 
		replace esl = 0 if !mi(esl) & belongneg != belongpos
		foreach var of varlist st034* {
			replace sl = 0 if !mi(sl) & (`var' != belongneg | `var' != belongpos) & !mi(`var') 
			replace esl = 0 if !mi(esl) & (sl==0 | `var' == 2 | `var' == 3)
		}
		
		
		
		label var esl "Extreme Straightlining"
		label var sl "Straightlining"
		repest PISA, estimate(means esl sl, pct) pisacoverage by(cnt) outfile(esl_`year') 
		repest PISA, estimate(means esl sl, pct) pisacoverage by(cnt) over(male, test) outfile(esl_gender_`year') 
		}
	
pisatrend, table(esl) first(2018) last(2022)
pisatrend, table(esl_gender) first(2018) last(2022)



** graphic inspection
use  esl_1822, clear
	merge 1:1 cnt using esl_2018, nogen
	ren *sl_m_b *sl_m_2018_b
	merge 1:1 cnt  using esl_2022, nogen
	ren *sl_m_b *sl_m_2022_b
	keep cnt *_b
	reshape long esl_m_@_b sl_m_@_b, i(cnt) j(year) string
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
		gr bar esl_m__b if year != "diff", over(year) over(cnt, sort(1) label(angle(90))) name(esl_lev, replace) xsize(12) ytitle("extreme straightlining" "sense of belonging (2022 - 2018)") nofill
		gr bar esl_m__b if year == "diff", over(cnt, sort(1) label(angle(90))) name(esl_trend, replace) xsize(12) ytitle("Difference in extreme straightlining" "sense of belonging (2022 - 2018)") nofill
	gr export esl_trend.png, name(esl_trend) replace
		gr bar sl_m__b if year != "diff", over(year) over(cnt, sort(1) label(angle(90))) name(sl_lev, replace) xsize(12) ytitle("straightlining" "sense of belonging (2022 - 2018)") nofill
		gr bar sl_m__b if year == "diff", over(cnt, sort(1) label(angle(90))) name(sl_trend, replace) xsize(12) ytitle("Difference in straightlining" "sense of belonging (2022 - 2018)") nofill
		gr export sl_trend.png, name(sl_trend) replace

do "G:\Code\PISA2022\volume1\Engagement\engagement_export"

** graphic inspection
use  esl_1822, clear
	merge 1:1 cnt using esl_2018, nogen
	ren *sl_m_b *sl_m_2018_b
	merge 1:1 cnt  using esl_2022, nogen
	ren *sl_m_b *sl_m_2022_b
	keep cnt *_b
	reshape long esl_m_@_b sl_m_@_b, i(cnt) j(year) string
* use real country name in graphs
	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
		gr bar esl_m__b if year != "diff", over(year) over(cnt, sort(1) label(angle(90))) name(esl_lev, replace) xsize(12) ytitle("extreme straightlining" "sense of belonging (2022 - 2018)") nofill
		gr bar esl_m__b if year == "diff", over(cnt, sort(1) label(angle(90))) name(esl_trend, replace) xsize(12) ytitle("Difference in extreme straightlining" "sense of belonging (2022 - 2018)") nofill
	gr export esl_trend.png, name(esl_trend) replace
		gr bar sl_m__b if year != "diff", over(year) over(cnt, sort(1) label(angle(90))) name(sl_lev, replace) xsize(12) ytitle("straightlining" "sense of belonging (2022 - 2018)") nofill
		gr bar sl_m__b if year == "diff", over(cnt, sort(1) label(angle(90))) name(sl_trend, replace) xsize(12) ytitle("Difference in straightlining" "sense of belonging (2022 - 2018)") nofill
		gr export sl_trend.png, name(sl_trend) replace

do "G:\Code\PISA2022\volume1\Engagement\engagement_export"

log close
clear all