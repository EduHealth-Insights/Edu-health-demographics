cd "V:\PISA_INITIALREPORT_2022\sandbox\Volume I"
use engagement2018, clear
	merge 1:1 cnt cntschid cntstuid adminmode bookid using  pplus2018, nogen keep(3) 
	merge 1:1 cnt cntschid cntstuid adminmode bookid using  "V:\EDUCATION_DATALAKE\sources\PISA\PISA 2018\Stata\STU/pisa2018_student_puf", nogen keep(3) keepusing(cnt cntschid cntstuid adminmode bookid pv*scie w_*)
	keep if regexm(hour1,"s") | regexm(hour2,"s")
replace hour1 = "s__m" if inlist(bookid,32,34,36)  & adminmode == 2
replace hour2 = "s__m" if inlist(bookid,25,27,29)  & adminmode == 2
replace hour1 = "s_gc" if inlist(bookid,55,57,59)  & adminmode == 2
replace hour2 = "s_gc" if inlist(bookid,50,52,54)  & adminmode == 2
gen type = ""
replace type = hour1 if regexm(hour1,"s")
replace type = hour2 if regexm(hour2,"s")
encode type, gen(type_n)

** outfile directory for results 
cd "V:\PISA_INITIALREPORT_2022\results\Trends\outfile"


*** science performance and engagement by form type
		repest PISA, estimate(means scierrprop scieskprop scienrprop scie2018pplus pv@scie, pct) pisacoverage by(cnt) over(type_n) outfile(scie_by_type) fast

use scie_by_type, clear
	foreach var of varlist *pv*scie*b {
		replace `var' = `var' / 100
		}
	foreach var in scierrprop scieskprop scienrprop scie2018pplus pv_scie {
		gen `var'_d1 = _5_`var'_m_b - _2_`var'_m_b // scie - m__s
		gen `var'_d2 = _3_`var'_m_b - _2_`var'_m_b // s__m - m__s
		gr bar `var'_d1 , over(cnt, sort(1) label(angle(90))) name(`var'_d1, replace) xsize(12) ytitle("Difference in `var'" "scie - m__s booklets" ) nofill
		gr bar `var'_d2 , over(cnt, sort(1) label(angle(90))) name(`var'_d2, replace) xsize(12) ytitle("Difference in `var'" "s__m - m__s booklets" ) nofill
gr export `var'_scie2018.png, name(`var'_d1) replace
	} 
