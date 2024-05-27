********************************************************************************
**																			  **
** SCH_CommonFiles: Program to create common variables for SCH Dataset		  **
**																			  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************



** School location 
********************************************************************************

cap drop schlocation rural urban city
recode sc001q01ta (1=0 "rural area") (2/3=1 "town") (4/6=2 "city"),gen(schlocation)
label var schlocation "School location"
recode schlocation (0=1 "rural area") (1 2=0 "town/city"), gen(rural)
label var rural "Rural school"
recode schlocation (0 2=0 "rural/city") (1=1 "town"), gen(urban)
label var urban "Urban school"
recode schlocation (0 =0 "rural") (2=1 "city") (1=.), gen(city)
label var city "City school"

* School type (public 0, private 1) - based on sc013 (school management), not schltype (ownership)
********************************************************************************

cap drop *private
recode sc013q01ta (1=0 "public school") (2=1 "private school") , gen(private)
replace private=1 if missing(sc013q01ta) & lower(privatesch)=="private"
replace private=0 if missing(sc013q01ta) & lower(privatesch)=="public"
replace private=. if missing(sc013q01ta) & (privatesch=="missing"|missing(privatesch))
label var private "Private school (using sc013q01ta and privatesch)"

replace private = . if region==82611 | region==82612 | region==82613
replace private = 0 if sc013c01ta_gb == 1 & (region==82611 | region==82612 | region==82613)
replace private = 1 if (sc013c01ta_gb == 2 | sc013c01ta_gb == 3) & (region==82611 | region==82612 | region==82613)

replace schltype = . if region==82611 | region==82612 | region==82613
replace schltype = 1 if sc013c01ta_gb == 3 & (region==82611 | region==82612 | region==82613)
replace schltype = 2 if sc013c01ta_gb == 2 & (region==82611 | region==82612 | region==82613)
replace schltype = 3 if sc013c01ta_gb == 1 & (region==82611 | region==82612 | region==82613)

	


** School socio-economic profile
********************************************************************************

preserve
	collapse (mean) xescs=escs [pw=w_fstuwt],by(cnt cntschid)
	save xescs, replace
restore
merge m:1  cnt cntschid using xescs, nogen
label var xescs "School ESCS"

* Schools enrolling with students in modal grade  (ISCED L with more than 1/3 of 15-y-olds)
***********************************************************************************
//contains variable modalisced, to select only students in schools with modal ISCED levels  ***

//contains variables isced2 and isced3, to select only students in schools with these levels***
preserve
	tempfile iscedl
	xi i.iscedl, noomit
	collapse (mean) _Iiscedl*  [pw = w_fstuwt], by(cnt)
	reshape long _Iiscedl_, i(cnt) j(iscedl)
	gen cnt_modalisced = (_Iiscedl_ > 1/3)
	drop _Iiscedl_
	save iscedl, replace
restore

preserve 
	tempfile iscedsch
	keep cnt cntschid iscedl
	gen isced2 = (iscedl == 2) if !missing(iscedl)
	gen isced3 = (iscedl == 3) if !missing(iscedl)
	bys cnt cntschid iscedl: keep if _n == 1
	merge m:1 cnt iscedl using iscedl
	keep if _merge !=2
	drop _merge
	collapse (max) xmodalisced=cnt_modalisced xisced2=isced2 xisced3=isced3, by(cnt cntschid)
	
	label var xmodalisced "School with country modal grade"	
	label var xisced2 "School with isced 2 "	
	label var xisced3 "School with isced 3"	
	save iscedsch, replace
restore
merge m:1 cnt cntschid using iscedsch, nogen


* School socio-economic profile
********************************************************************************

** Advantaged/disadvantaged school
* first step: is to make xescs 'continuous' and calculate quartiles
capture drop country
encode cnt, gen(country) 
tab country, m		
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace xescs=. if xescs==.m | xescs==.i | xescs==.v | xescs==.n
capture drop xescs_cont
gen double xescs_cont = xescs + e10
sum xescs_cont
capture drop xescs_p25
capture drop xescs_p75
gen double xescs_p25=.
gen double xescs_p75=.

levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile xescs_cont if country==`k' [aw=w_fstuwt], p(25 75)
	qui replace xescs_p25=r(r1) if country==`k'
	qui replace xescs_p75=r(r2) if country==`k'
	}
*
	
* second step: generate the new variables exploiting the quartiles
capture drop low_xescs
capture drop med_xescs
capture drop high_xescs
capture drop lowhighxescs

* Genereate schools with low escs
gen 		low_xescs =.
replace 	low_xescs=0 if xescs_cont>xescs_p25 & xescs_cont!=.
replace 	low_xescs=1 if xescs_cont<=xescs_p25 & xescs_cont!=.
label var low_xescs "Bottom quarter school ESCS"
label define xesxs_low 0 "Not disadvantaged" 1 "Disadvantaged"
label value low_xescs xescs_low

* Generate schools with medium escs
gen 		med_xescs =.
replace 	med_xescs=0 if (xescs_cont<=xescs_p25 | xescs_cont>xescs_p75) & xescs_cont!=.
replace 	med_xescs=1 if xescs_cont>xescs_p25 & xescs_cont<=xescs_p75 & xescs_cont!=.
label var med_xescs "Medium school ESCS"
label define xescs_med 0 "Not medium ESCS" 1 "Medium ESCS"
label value med_xescs xescs_med 

* Generate schools with high escs	
gen 		high_xescs =. 
replace 	high_xescs=0 if xescs_cont<=xescs_p75 & xescs_cont!=.
replace 	high_xescs=1 if xescs_cont>xescs_p75 & xescs_cont!=.
label var high_xescs "Top quarter school ESCS"
label define xescs_high 0 "Not advantaged" 1 "Advantaged"
label value high_xescs xescs_high

* Generate a variable: schools with low and high escs 	
gen lowhighxescs=. 
replace lowhighxescs=0 	if  low_xescs==1 & low_xescs!=. 
replace lowhighxescs=1	if  high_xescs==1 & high_xescs!=. 
label var lowhighxescs "Top/bottom quarter school ESCS"
label define lhxescs 0 "Disadvantaged" 1 "Advantaged"
label value lowhighxescs lhxescs

tab lowhighxescs, m
tab high_xescs, m
tab low_xescs, m

** Proportion of immigrant students in schools
********************************************************************************

preserve
collapse (mean) ximmback=immback [pw=w_fstuwt],by(cnt cntschid)
save ximmback, replace
restore
merge m:1 cnt cntschid using ximmback, nogen
label var ximmback "School proportion of immigrant students"

** Immigrant concentration at the school level (reocoded: ximmback based on immig; we need to create a new variable)
********************************************************************************
capture drop lowhighximmback
gen lowhighximmback=.
replace lowhighximmback=0 if ximmback<0.10 & (ximmback!=. | ximmback!=.v | ximmback!=.r | ximmback!=.n | ximmback!=.i | ximmback!=.m)  
replace lowhighximmback=1 if ximmback>=0.10 & (ximmback!=. | ximmback!=.v | ximmback!=.r | ximmback!=.n | ximmback!=.i | ximmback!=.m)  
replace lowhighximmback=. if ximmback==. | ximmback==.v | ximmback==.r | ximmback==.n | ximmback==.i | ximmback==.m 
label var  lowhighximmback "Concentration of immigrant students" //Add variable label
label def lowhighximmback 0 "Low < 10% of students" 1 "High >= 10% of students", modify //Define value label
label val lowhighximmback lowhighximmback //Define value label
tab lowhighximmback, m //No missing value

