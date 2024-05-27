********************************************************************************
**																			  **
** STU_CommonFiles: Program to create common variables for STU Dataset		  **
**																			  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

** Gender
********************************************************************************
cap drop gender
recode st004d01t (2=1 "boy") (1=0 "girl"), gen(gender)
label var gender "Gender"
** Gender boy - dummy
************************************************
capture drop boy
recode st004d01t (2=1 "boy") (1=0 "girl"), gen(boy)
** Gender girl - dummy
************************************************
cap drop girl
recode st004d01t (2=0 "boy") (1=1 "girl"), gen(girl)

** Immigrant background
********************************************************************************
cap drop immback native  firstgen secondgen r_immig
recode immig (1=0 "native") (2 3 =1 "immigrant background"),gen(immback)
label var immback "Immigrant background"
recode immig (2 3 =0 "immigrant background") (1=1 "native"),gen(native)
label var native "Native student"
recode immig (1 2 =0 "native and secondgen") (3=1 "first generation"),gen(firstgen)
label var firstgen "First-generation immigrant students"
recode immig (1 3 =0 "native and firstgen") (2=1 "second generation"),gen(secondgen)
label var secondgen "Second-generation immigrant students"		 			
recode immig(1=0 "Non immigrant") (3=1 "First-generation immigrant") (2=2 "Second-generation immigrant"), gen (r_immig)
label var r_immig "Recoded immig"

** Language spoken at home
********************************************************************************
cap drop samelang difflang
recode st022q01 (2=0 "other language") (1=1 "language of the test"),gen(samelang)
label var samelang "Speak the language of the test"
recode st022q01 (1=0 "language of the test") (2=1 "other language"),gen(difflang)
label var difflang "Does not speak the language of the test"


** Same_immback
********************************************************************************
cap drop same_immback
gen same_immback=.
replace same_immback=1 if immback==1 & difflang==0
replace same_immback=0 if immback==1 & difflang==1
label variable same_immback "Immigrant student does speak language of assessment at home"
label define same_imm 0 "Different language immigrant" 1 "Same language immigrant"
label value same_immback same_imm




** Iscedl: ISCED level 3 vs ISCED level 2 (Case 454 recoded as missing)
********************************************************************************
cap drop iscedl
recode iscedp (453 454=.) (244 254 =2 "isced level 2") (341 343 344 354 =3 "isced level 3"), gen(iscedl)
label var iscedl"ISCED Level"

** Educational level: ISCED level 3 vs ISCED level 2 (Case 454 recoded as missing)
********************************************************************************
cap drop iscedlev3
recode iscedp (453 454=.) (244 254 =0 "isced level 2") (341 343 344 354 =1 "isced level 3"), gen(iscedlev3)
label var iscedlev3 "Educational level: ISCED level 3"

** Enrolled in a general program
*************************************
cap drop general
recode iscedp (453 454 =.) (244 341 343 344=1 "General or modular") (254 354 =0 "Vocational"),gen(general) 
label var general "Enrolled in a general program"

** Enrolled in a vocational program
*************************************
cap drop vocational
gen vocational = .
replace vocational=0 if general==1 
replace vocational=1 if general==0


** Life satisfaction
********************************************************************************
cap drop r_lifesat 
cap drop lifesat_4cat
gen r_lifesat=st016q01na
label var r_lifesat "Life satisfaction (scale)"
recode r_lifesat (0/4=1 "not satisfied") (5/6=2 "moderately satisfied") (7/8=3 "satisfied") (9/10=4 "very satisfied"), gen(lifesat_4cat)
label var lifesat_4cat "Life satisfaction (4 categories)"

cap drop notsatisfied modsatisfied satisfied verysatisfied overallsatisfied

recode lifesat_4cat (1=1 "Not satisfied with life (<5)") (2/4=0 "Life satisfaction >=5"), gen(notsatisfied)
label var notsatisfied "Not satisfied with life (<5)"
recode lifesat_4cat (2=1 "Moderately satisfied with life (5-6)") (1 3/4=0 "Not moderately satisfied"), gen(modsatisfied)
label var modsatisfied "Moderately satisfied with life (5-6)"
recode lifesat_4cat (3=1 "Life satisfaction 7-8") (1/2  4=0 "Life satisfaction <7 or >8"), gen(satisfied)
label var satisfied "Satisfied with life (7-8)" 
recode lifesat_4cat (4=1 "Very satisfied with life (9-10)") (1/3=0 "Not very satisfied with life (<9)"), gen(verysatisfied)
label var verysatisfied "Very satisfied with life (9-10)" 
recode lifesat_4cat (3/4=1 "Overall satisfied with life (7-10)") (1/2=0 "Not  satisfied with life (<7)"), gen(overallsatisfied)
label var overallsatisfied "Satisfied with life (7-10)" 

*School levels
local variables "lifesat r_lifesat notsatisfied modsatisfied satisfied verysatisfied overallsatisfied"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "lifesat r_lifesat notsatisfied modsatisfied satisfied verysatisfied overallsatisfied"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** Proficiency levels (recode Math when we know the new levels)
********************************************************************************
 forval i = 1/10 { 
	capture drop pv`i'math_l pv`i'scie_l pv`i'read_l
		cap recode pv`i'read (min/189.329999 = -99) (189.33/262.039999 = -13) (262.04/334.749999 = -12) (334.75/407.469999 = -11) (407.47/480.179999 = 2) (480.18/552.889999 = 3) (552.89/625.609999 = 4) (625.61/698.319999 = 5) (698.32/max = 6)  , gen(pv`i'read_l)
		cap recode pv`i'math (min/233.169999  = -99)(233.17/295.469999= -13) (295.47/357.769999 = -12) (357.77/420.069999 = -11) (420.07/482.379999 = 2) (482.38/544.679999 = 3) (544.68/606.989999 = 4) (606.99/669.299999 = 5) (669.30/max = 6)  , gen(pv`i'math_l)
		cap recode pv`i'scie (min/260.539999 = -99) (260.54/334.939999 = -12) (334.94/409.539999 = -11) (409.54/484.139999 = 2) (484.14/558.729999 = 3) (558.73/633.329999 = 4) (633.33/707.929999 = 5) (707.93/max = 6)  , gen(pv`i'scie_l)
		
		cap replace pv`i'scie_l = . if pv`i'scie == .
		cap replace pv`i'math_l = . if pv`i'math == .
		cap replace pv`i'read_l = . if pv`i'read == .
foreach subscale1 in mpfs /*mpem mpin*/ mpre mccr /*mcqn*/ mcss /*mcud*/ {
	   capture drop pv`i'`subscale1'_l 
	   recode pv`i'`subscale1' (min/357.769999  = -99)(357.77/420.069999 = -11) (420.07/482.379999 = 2) (482.38/544.679999 = 3) (544.68/606.989999 = 4) (606.99/669.299999 = 5) (669.30/max = 6)  , gen(pv`i'`subscale1'_l)
	 } // end of loop over subscales (first set)
                             
 foreach subscale2 in mpem mcqn mcud {
			   capture drop pv`i'`subscale2'_l 
			   recode pv`i'`subscale2' (min/295.469999 = -99) (295.47/357.769999 = -12) (357.77/420.069999 = -11) (420.07/482.379999 = 2) (482.38/544.679999 = 3) (544.68/606.989999 = 4) (606.99/669.299999 = 5) (669.30/max = 6) , gen(pv`i'`subscale2'_l)
 } // end of loop over subscales (second set)         

capture drop pv`i'mpin_l 
recode pv`i'mpin (min/233.169999 = -99) (233.17/295.469999= -13) (295.47/357.769999 = -12) (357.77/420.069999 = -11) (420.07/482.379999 = 2) (482.38/544.679999 = 3) (544.68/606.989999 = 4) (606.99/669.299999 = 5) (669.30/max = 6) , gen(pv`i'mpin_l)

} // end of loop over pvs

** Define top-performing and low-performing students by score
********************************************************************************	
forval i = 1/10 { 
	foreach domn in scie math read  {
		capture drop lp_pv`i'`domn'_l mp_pv`i'`domn'_l tp_pv`i'`domn'_l
		cap 	recode pv`i'`domn'_l (min/1=1 "Below Level 2") (2/6=0 "Level 2 or above"), generate(lp_pv`i'`domn'_l) 
		cap 	recode pv`i'`domn'_l (min/2=0) (2/4=1) (5/6=0), generate(mp_pv`i'`domn'_l) 
		cap 	recode pv`i'`domn'_l (min/4=0 "Level 4 or below") (5/6=1 "Level 5 or above"), generate(tp_pv`i'`domn'_l) 
		}
	}


** Advantaged/disadvantaged (based on the escs quartile variable -> escsq)
********************************************************************************
*first step is to make escs 'continuous' and calculate national quartiles 
capture drop country
//encode fcnt, gen(country)
encode cnt, gen(country) 
tab country, m		
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace escs=. if escs==.m | escs==.i | escs==.v | escs==.n
capture drop escs_cont
gen double escs_cont = escs + e10
sum escs_cont
capture drop escs_p25
capture drop escs_p50
capture drop escs_p75
gen double escs_p25=.
gen double escs_p50=.
gen double escs_p75=.

levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile escs_cont if country==`k' [aw=w_fstuwt], p(25 50 75)
	qui replace escs_p25=r(r1) if country==`k'
	qui replace escs_p50=r(r2) if country==`k'
	qui replace escs_p75=r(r3) if country==`k'
	}

* Generate a categorical var for escs quartiles
capture drop escs_q
gen escs_q=1 if escs_cont<=escs_p25 & !missing(escs_cont)
replace escs_q=2 if escs_cont>escs_p25 & escs_cont<=escs_p50 & !missing(escs_cont)
replace escs_q=3 if escs_cont>escs_p50 & escs_cont<=escs_p75 & !missing(escs_cont)
replace escs_q=4 if escs_cont>escs_p75 & !missing(escs_cont)
label define qescs 1 "first quarter of escs" 2 "second quarter of escs" 3 "third quarter of escs" 4 "fourth quarter of escs"
label value escs_q qescs

* Generate the new variables exploiting the quartiles
capture drop low_escs
capture drop med_escs
capture drop high_escs
capture drop lowhighescs

* Generate low escs
gen low_escs =.
replace low_escs=0 if escs_cont>escs_p25 & escs_cont!=.
replace low_escs=1 if escs_cont<=escs_p25 & escs_cont!=.
label var low_escs "Bottom quarter student ESCS"
label define escs_low 0 "Not disadvantaged" 1 "Disadvantaged"
label value low_escs escs_low

* Generate medium escs
gen med_escs =.
replace med_escs=0 if (escs_cont<=escs_p25 | escs_cont>escs_p75) & escs_cont!=.
replace med_escs=1 if escs_cont>escs_p25 & escs_cont<=escs_p75 & escs_cont!=.
label var med_escs "Medium student ESCS"
label define escs_med 0 "Not medium ESCS" 1 "Medium ESCS"
label value med_escs escs_med

* Generate high escs	
gen high_escs =. 
replace high_escs=0 if escs_cont<=escs_p75 & escs_cont!=.
replace high_escs=1 if escs_cont>escs_p75 & escs_cont!=.
label var high_escs "Top quarter student ESCS"
label define escs_high 0 "Not advantaged" 1 "Advantaged"
label value high_escs escs_high

* Generate a variable low and high escs
gen lowhighescs=. 
replace lowhighescs=0 if low_escs==1 
replace lowhighescs=1 if high_escs==1 
label var lowhighescs "Top/bottom quarter student ESCS"
label define lhescs 0 "Disadvantaged" 1 "Advantaged"
label value lowhighescs lhescs

** ST263q04ja
********************************************************************************

recode st263q04ja  (1/2=1 "Disagree or strongly disagree") (3/4=0 "Agree or strongly agree"), gen(d_st263q04ja)
label val d_st263q04ja d_st263q04ja
_crcslbl d_st263q04ja st263q04ja

** tru_any
********************************************************************************
gen tru_any = .
replace tru_any = 0 if st062q01ta == 1 & st062q02ta == 1 & st062q03ta == 1
replace tru_any = 1 if (st062q01ta == 2 & st062q02ta == 1 & st062q03ta == 1) | (st062q01ta == 1 & st062q02ta == 2 & st062q03ta == 1) | (st062q01ta == 1 & st062q02ta == 1 & st062q03ta == 2)
replace tru_any = 2 if st062q01ta == 3 | st062q02ta == 3 | st062q03ta == 3 | (st062q01ta == 2 & st062q02ta == 2 & st062q03ta == 1) | (st062q01ta == 2 & st062q02ta == 1 & st062q03ta == 2) | (st062q01ta == 1 & st062q02ta == 2 & st062q03ta == 2) | (st062q01ta == 2 & st062q02ta == 2 & st062q03ta == 2)
label var tru_any "The student was a truant never, once or more" 
label define tru_an 0 "Never" 1 "Once" 2 "More than once"
label value tru_any tru_an

** tru_once
********************************************************************************
gen tru_once = .
replace tru_once = 0 if st062q01ta == 1 & st062q02ta == 1 & st062q03ta == 1
replace tru_once = 1 if tru_any == 1 | tru_any == 2
label var tru_once "The student was a truant never, at least once" 
label define tru_on 0 "Never" 1 "At least once"
label value tru_once tru_on

** tertiary
********************************************************************************
gen tertiary = .
replace tertiary = 1 if st327q05ja == 1 | st327q06ja == 1 | st327q07ja == 1 | st327q08ja == 1
replace tertiary = 0 if (st327q05ja ==2 | st327q05ja ==3) & (st327q06ja ==2 | st327q06ja ==3) & (st327q07ja ==2 | st327q07ja ==3) & (st327q08ja ==2 | st327q08ja ==3)
label var tertiary  "student expects to complete tertiary" 
label define tertiar 0 "No" 1 "Yes"
label value tertiary tertiar

** percentgirls
********************************************************************************
cap drop propgirls
gen propgirls = sc002q02ta / (sc002q01ta + sc002q02ta)
cap drop percentgirls*
gen percentgirls = .
replace percentgirls = 1 if propgirls <= 0.4 & (propgirls != .)
replace percentgirls = 2 if propgirls > 0.4 & propgirls <= 0.6 & (propgirls != .)
replace percentgirls = 3 if propgirls > 0.6 & (propgirls != .)
gen percentgirls2 = percentgirls
recode percentgirls2 3 = .

** singlesex
********************************************************************************
cap drop singlesex*
gen singlesex = . 
replace singlesex = 0 if propgirls == 0 & (propgirls != .)
replace singlesex = 1 if propgirls == 1 & (propgirls != .)
gen singlesex2 = . 
replace singlesex2 = 0 if propgirls == 0 & (propgirls != .)
replace singlesex2 = 1 if propgirls > 0.4 & propgirls <= 0.6 & (propgirls != .)

** Age of arrival of first-generation immigrant students
********************************************************************************
cap drop agearrival
cap drop arrival
gen  agearrival= st021q01ta-1
replace agearrival=. if agearrival==.n | agearrival==.v | agearrival==.m | agearrival==.i | immig != 3
recode agearrival (0/5=1 "0-5 years old") (6/11=2 "6-11 years old") (12/16=3 "12-16 years old"), gen(arrival)
label var arrival "Age of arrival of first-generation immigrant students"


** Overlap (intersection) of top and low performers
********************************************************************************
foreach side in tp lp {
	* First, identify in which domains students are low/top performers
	* Use binary numbers to simplify assignments
	* Columns from L to R in table are: none, R, M, S, RM, RS, MS, all
	* This gives 0, 4, 2, 1, 6, 5, 3, 7 -- recode to 1, 2, 3, 4, 5, 6, 7, 8
	forvalues i = 1/10 {
		generate `side'_pv`i'RMS = (4 * `side'_pv`i'read_l) + (2 * `side'_pv`i'math_l) + (1 * `side'_pv`i'scie_l)
		recode `side'_pv`i'RMS (0 = 1) (4 = 2) (2 = 3) (1 = 4) (6 = 5) (5 = 6) (3 = 7) (7 = 8)
		recode `side'_pv`i'RMS (0/7 = 0) (8 = 1), generate(`side'_pv`i'ALL)
	}
}

** International quintiles of ESCS 
********************************************************************************

* Part 1/4: create new empty columns/vars
set seed 2023
cap drop iescs_cont
cap drop intl_escs*
gen iescs_cont=escs+(runiform()/1000000000)
gen intl_escs_p10=.
gen intl_escs_p20=.
gen intl_escs_p30=.
gen intl_escs_p40=.
gen intl_escs_p50=.
gen intl_escs_p60=.
gen intl_escs_p70=.
gen intl_escs_p80=.
gen intl_escs_p90=.
* Part 2/4: create pctile
_pctile iescs_cont if regexm("${CNT2022}",cnt) [aw=w_fstuwt],p(10 20 30 40 50 60 70 80 90) //global "CNT2022" includes all countries and economies in PISA 2022
qui replace intl_escs_p10=r(r1)
qui replace intl_escs_p20=r(r2)
qui replace intl_escs_p30=r(r3)
qui replace intl_escs_p40=r(r4)
qui replace intl_escs_p50=r(r5)
qui replace intl_escs_p60=r(r6)
qui replace intl_escs_p70=r(r7)
qui replace intl_escs_p80=r(r8)
qui replace intl_escs_p90=r(r9)
* Part 3/4: generate international quintiles
gen intl_escs_qui=.
replace intl_escs_qui=0 if iescs_cont       <= intl_escs_p20
replace intl_escs_qui=1 if iescs_cont       <= intl_escs_p40             & iescs_cont > intl_escs_p20
replace intl_escs_qui=2 if iescs_cont       <= intl_escs_p60             & iescs_cont > intl_escs_p40
replace intl_escs_qui=3 if iescs_cont       <= intl_escs_p80             & iescs_cont > intl_escs_p60
replace intl_escs_qui=4 if iescs_cont       > intl_escs_p80 & iescs_cont!=.
gen intl_escs_low20=. //Range: p0-p20 (bottom quintile)
replace intl_escs_low20=1 if intl_escs_qui==0
replace intl_escs_low20=0 if intl_escs_qui!=0 & escs!=.  
gen intl_escs_low40=. //Range: p20-p40 (second quintile)
replace intl_escs_low40=1 if intl_escs_qui==1
replace intl_escs_low40=0 if intl_escs_qui!=1 & escs!=.
gen intl_escs_mid60=. //Range: p40-p60 (middle quintile)
replace intl_escs_mid60=1 if intl_escs_qui==2
replace intl_escs_mid60=0 if intl_escs_qui!=2 & escs!=.
gen intl_escs_top60=. //Range: p60-p80 (fourth quintile)
replace intl_escs_top60=1 if intl_escs_qui==3
replace intl_escs_top60=0 if intl_escs_qui!=3 & escs!=.
gen intl_escs_top80=. //Range: p80-p100 (top quintile)
replace intl_escs_top80=1 if intl_escs_qui==4
replace intl_escs_top80=0 if intl_escs_qui!=4 & escs!=.
*drop intl_escs_p*
drop intl_escs_qui
* Part 4/4: generate international deciles
gen intl_escs_qui=.
replace intl_escs_qui=0 if iescs_cont       <= intl_escs_p10
replace intl_escs_qui=1 if iescs_cont       <= intl_escs_p20             & iescs_cont > intl_escs_p10
replace intl_escs_qui=2 if iescs_cont       <= intl_escs_p30             & iescs_cont > intl_escs_p20
replace intl_escs_qui=3 if iescs_cont       <= intl_escs_p40             & iescs_cont > intl_escs_p30
replace intl_escs_qui=4 if iescs_cont       <= intl_escs_p50             & iescs_cont > intl_escs_p40
replace intl_escs_qui=5 if iescs_cont       <= intl_escs_p60             & iescs_cont > intl_escs_p50
replace intl_escs_qui=6 if iescs_cont       <= intl_escs_p70             & iescs_cont > intl_escs_p60
replace intl_escs_qui=7 if iescs_cont       <= intl_escs_p80             & iescs_cont > intl_escs_p70
replace intl_escs_qui=8 if iescs_cont       <= intl_escs_p90             & iescs_cont > intl_escs_p80
replace intl_escs_qui=9 if iescs_cont       > intl_escs_p90 & iescs_cont!=.
gen intl_escs_d1=. //Range: p0-p10 (bottom decile)
replace intl_escs_d1=1 if intl_escs_qui==0
replace intl_escs_d1=0 if intl_escs_qui!=0 & escs!=.  
gen intl_escs_d2=. //Range: p10-p20 (second decile)
replace intl_escs_d2=1 if intl_escs_qui==1
replace intl_escs_d2=0 if intl_escs_qui!=1 & escs!=.
gen intl_escs_d3=. //Range: p20-p30 (third decile)
replace intl_escs_d3=1 if intl_escs_qui==2
replace intl_escs_d3=0 if intl_escs_qui!=2 & escs!=.
gen intl_escs_d4=. //Range: p30-p40 (fourth decile)
replace intl_escs_d4=1 if intl_escs_qui==3
replace intl_escs_d4=0 if intl_escs_qui!=3 & escs!=.
gen intl_escs_d5=. //Range: p40-p50 (fifth decile)
replace intl_escs_d5=1 if intl_escs_qui==4
replace intl_escs_d5=0 if intl_escs_qui!=4 & escs!=.
gen intl_escs_d6=. //Range: p50-p60 (sixth decile)
replace intl_escs_d6=1 if intl_escs_qui==5
replace intl_escs_d6=0 if intl_escs_qui!=5 & escs!=.
gen intl_escs_d7=. //Range: p60-p70 (seventh decile)
replace intl_escs_d7=1 if intl_escs_qui==6
replace intl_escs_d7=0 if intl_escs_qui!=6 & escs!=.
gen intl_escs_d8=. //Range: p70-p80 (eighth decile)
replace intl_escs_d8=1 if intl_escs_qui==7
replace intl_escs_d8=0 if intl_escs_qui!=7 & escs!=.
gen intl_escs_d9=. //Range: p80-p90 (ninth decile)
replace intl_escs_d9=1 if intl_escs_qui==8
replace intl_escs_d9=0 if intl_escs_qui!=8 & escs!=.
gen intl_escs_d10=. //Range: p90-p100 (top decile)
replace intl_escs_d10=1 if intl_escs_qui==9
replace intl_escs_d10=0 if intl_escs_qui!=9 & escs!=.
drop intl_escs_p*
drop intl_escs_qui


** National resilience
********************************************************************************
* Top quarter of reading performance (used for national resilience)
set seed 1992
global domain "read math scie"

foreach domn in $domain {

              forval p=1/10 {
                             cap drop pv`p'`domn'_c pv`p'`domn'_p75 pv`p'`domn'_q4
                             gen pv`p'`domn'_c=pv`p'`domn'+(runiform()/1000000)
                             gen pv`p'`domn'_p75=.
                             levelsof cnt, local(countries)
                             foreach k of local countries {
                                           di "`k' PV`p'"
                                           _pctile pv`p'`domn'_c if cnt=="`k'" [aw=w_fstuwt], p(75)
                                           qui replace pv`p'`domn'_p75=r(r1) if cnt=="`k'" 
                                           }
                             g pv`p'`domn'_q4=(pv`p'`domn'_c>=pv`p'`domn'_p75) if !missing(pv`p'`domn')
                             }

                             

              * National resilience **
              forval ip = 1/10 {
                            cap drop nresilient`ip'`domn'
                             gen nresilient`ip'`domn'=0 if low_escs==1 
                             replace nresilient`ip'`domn'=1 if low_escs==1 & pv`ip'`domn'_q4==1 
                             }
}

              * Core-skills resilience **
              forval ip = 1/10 {
                             cap drop cresilient`ip'
                             gen cresilient`ip'=0 if low_escs==1
                             replace cresilient`ip'=1 if low_escs==1 & pv`ip'math_l>=3 & pv`ip'read_l>=3 & pv`ip'scie_l>=3
                             }

              * International resilience **
foreach domn in math read scie {

              forval ip = 1/10 {
              cap drop resilient`ip'`domn'
              gen resilient`ip'`domn'=0 if intl_escs_low20==1 //resilient are computed among students in the bottom international quintile of escs
                             replace resilient`ip'`domn'=1 if intl_escs_low20==1 & tp_pv`ip'`domn'_l==1 // and who are top performer
              }

}


** Diff_immback
********************************************************************************
gen diff_immback=.
replace diff_immback=1 if immback==1 & difflang==1
replace diff_immback=0 if immback==1 & difflang==0
label variable diff_immback "Immigrant student does not speak language of assessment at home"
label define diff_immback 0 "Same language immigrant" 1 "Different language immigrant"




** Define high- and low achievers in mathematics, science, reading  and GC
********************************************************************************
cap drop country
egen country=group(cnt)
foreach perf in scie math read {
forval ip = 1/10{ 

	capture drop dpv`ip'`perf'_p25=.
	capture drop dpv`ip'`perf'_p75=.
	gen double dpv`ip'`perf'_p25=.
	gen double dpv`ip'`perf'_p75=.

	levelsof country, local(countries) 
	foreach k of local countries {
					di `k'
					_pctile pv`ip'`perf' if country==`k' [aw=w_fstuwt], p(25 75)
					qui replace dpv`ip'`perf'_p25=r(r1) if country==`k'
					qui replace dpv`ip'`perf'_p75=r(r2) if country==`k'					
					}
	capture drop low_pv`ip'`perf'
	gen low_pv`ip'`perf' =0 
	replace low_pv`ip'`perf'=1 if pv`ip'`perf'<dpv`ip'`perf'_p25 & pv`ip'`perf'!=.
	
	capture drop high_pv`ip'`perf'
	gen high_pv`ip'`perf' =0 
	replace high_pv`ip'`perf'=1 if pv`ip'`perf'>=dpv`ip'`perf'_p75 & pv`ip'`perf'!=.
	}
}



