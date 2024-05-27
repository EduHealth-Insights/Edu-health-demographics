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
