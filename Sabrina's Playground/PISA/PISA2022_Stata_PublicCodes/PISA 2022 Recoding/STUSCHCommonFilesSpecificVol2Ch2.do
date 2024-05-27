********************************************************************************
**																			  **
** STU_CommonFiles: Program to create common variables for STU Dataset		  **
**					Specific Vol 2	Ch 1									  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

********************************************************************************
**																			 
**		Volume II Chapter 2
**
********************************************************************************

** ST347
********************************************************************************

**d_covid based on st347q01ja
recode st347q01ja  (1/3=0 "less than 3 months") (4/6=1 "more than 3 months"), gen(d_covid)
label val d_covid d_covid
_crcslbl d_covid st347q01ja
recode st347q01ja  (1 3/6=0 "No or other duration") (2=1 "up to 1 month"), gen(d_covid1)
label val d_covid1 d_covid1
_crcslbl d_covid1 st347q01ja
recode st347q01ja  (1/2 4/6=0 "No or other duration") (3=1 "more than 1 month and up to 3 months"), gen(d_covid3)
label val d_covid3 d_covid3
_crcslbl d_covid3 st347q01ja
recode st347q01ja  (1/3 5/6=0 "No or other duration") (4=1 "more than 3 months and up to 6 months"), gen(d_covid6)
label val d_covid6 d_covid6
_crcslbl d_covid6 st347q01ja
recode st347q01ja  (1/4 6=0 "No or other duration") (5=1 "more than 6 months and up to 12 months"), gen(d_covid12)
label val d_covid12 d_covid12
_crcslbl d_covid12 st347q01ja
recode st347q01ja  (1/5=0 "No or other duration") (6=1 "more than 12 months"), gen(d_covid13)
label val d_covid13 d_covid13
_crcslbl d_covid13 st347q01ja

**d_other based on st347q02ja
recode st347q02ja  (1/3=0 "less than 3 months") (4/6=1 "more than 3 months"), gen(d_other)
label val d_other d_other
_crcslbl d_other st347q02ja
recode st347q02ja  (1 3/6=0 "No or other duration") (2=1 "up to 1 month"), gen(d_other1)
label val d_other1 d_other1
_crcslbl d_other1 st347q02ja
recode st347q02ja  (1/2 4/6=0 "No or other duration") (3=1 "more than 1 month and up to 3 months"), gen(d_other3)
label val d_other3 d_other3
_crcslbl d_other3 st347q02ja
recode st347q02ja  (1/3 5/6=0 "No or other duration") (4=1 "more than 3 months and up to 6 months"), gen(d_other6)
label val d_other6 d_other6
_crcslbl d_other6 st347q02ja
recode st347q02ja  (1/4 6=0 "No or other duration") (5=1 "more than 6 months and up to 12 months"), gen(d_other12)
label val d_other12 d_other12
_crcslbl d_other12 st347q02ja
recode st347q02ja  (1/5=0 "No or other duration") (6=1 "more than 12 months"), gen(d_other13)
label val d_other13 d_other13
_crcslbl d_other13 st347q02ja

**school level
local variables "d_covid* d_other*"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_covid* d_other*"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST350
********************************************************************************
recode st350q01ja  (2/3=0 "learnt about as much or more") (1=1 "learnt less"), gen(d_less)
label val d_less d_less
_crcslbl d_less st350q01ja
recode st350q01ja  (1/2=0 " learnt about as much or less") (3=1 "learnt more"), gen(d_more)
label val d_more d_more
_crcslbl d_more st350q01ja

** ST352
********************************************************************************
local variables "st352q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 "At least once a week ") (1/2=1 "Never/A few times"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST354
********************************************************************************
local variables "st354q02* st354q03* st354q05* st354q07* st354q08* st354q09*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Strongly disagree/Disagree") (3/4=1 "Agree/Strongly agree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}
local variables "st354q01* st354q04* st354q06* st354q10*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 "Agree/Strongly agree") (1/2=1 "Strongly disagree/Disagree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST349
********************************************************************************
recode st349q01ja  (1/4=0 "Digital device for schoolwork") (5=1 "No digital device for schoolwork"), gen(d_nodevice)
label val d_nodevice d_nodevice
_crcslbl d_nodevice st349q01ja
recode st349q01ja  (2/5=0 "No device or other device") (1=1 "my own laptop, desktop computer, or tablet"), gen(d_laptop)
label val d_laptop d_laptop
_crcslbl d_laptop st349q01ja
recode st349q01ja  (1 3/5=0 "No device or other device") (2=1 "My own smartphone"), gen(d_phone)
label val d_phone d_phone
_crcslbl d_phone st349q01ja
recode st349q01ja  (1/2 4/5=0 "No device or other device") (3=1 "family device"), gen(d_famdev)
label val d_famdev d_famdev
_crcslbl d_famdev st349q01ja
recode st349q01ja  (1/3 5=0 "No device or other device") (4=1 "school device"), gen(d_schdev)
label val d_schdev d_schdev
_crcslbl d_schdev st349q01ja

** ST351
********************************************************************************
local variables "st351q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 "About once or twice a week or less") (4=1 "Every day or almost every day"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC219
********************************************************************************
local variables "sc219q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/8=0 "Less than 70%") (9/11=1 "Over 70%"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC220
********************************************************************************
recode sc220q01ja  (1=11 "0%") (2=10 "1% to 10%") (3=9 "11% to 20%") (4=8 "21% to 30%") (5=7 "31% to 40%") /*
*/(6=6 "41% to 50%") (7=5 "51% to 60%") (8=4 "61% to 70%") (9=3 "71% to 80%") (10=2 "81% to 90%") (11=1 "91% to 100%"), gen(r_sc220q01ja)
label val r_sc220q01ja r_sc220q01ja
_crcslbl r_sc220q01ja sc220q01ja

recode sc220q01ja  (5/11=0 "Over 30%") (1/4=1 "30% or less"), gen(d_sc220q01ja)
label val d_sc220q01ja d_sc220q01ja
_crcslbl d_sc220q01ja sc220q01ja

** ST355
********************************************************************************
local variables "st355q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 " Not at all confident/Not very confident") (3/4=1 "Confident/Very confident"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

**school level
local variables "d_st355q* sdleff"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st355q* sdleff"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST356
********************************************************************************
local variables "st356q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not prepared at all/Not very prepared ") (3/4=1 "Well prepared/Very well prepared"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}
**school level
local variables "d_st356q*"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st356q*"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** SC223
********************************************************************************

local variables "sc223q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2/3=0 "No or not before COVID-19") (1=1 "As a standard practice before COVID-19"), gen(d_before_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_before_`vr' d_before_`vr' // Add value labels
	_crcslbl d_before_`vr' `vr' // Add the full variable label
}
local variables "sc223q**"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 3 =0 "No or as a standard practice before COVID-19") (2=1 "In response to COVID-19"), gen(d_repsonse_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_repsonse_`vr' d_repsonse_`vr' // Add value labels
	_crcslbl d_repsonse_`vr' `vr' // Add the full variable label
}

** SC224
********************************************************************************

local variables "sc224q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not prepared at all/Not very prepared") (3/4=1 "Well prepared/Very well prepared"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST348
********************************************************************************

local variables "st348q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 "About once or twice a week or less") (4=1 "Every day or almost every day"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC214
********************************************************************************

local variables "sc214q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 "Less than half of the classes") (4/5=1 "more than half of the classes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC215
********************************************************************************

local variables "sc215q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC216
********************************************************************************

local variables "sc216q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not at all/Very little") (3/4=1 "To some extent/A lot"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SC218
********************************************************************************

local variables "sc218q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST353
********************************************************************************

local variables "st353q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Never/A few times") (3/4=1 "  About once or twice a week/Every day or almost every day"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST221
********************************************************************************
local variables "sc221q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST349
********************************************************************************
recode st349q01ja  (5=1 "No digital device for school work") (1=2 "My own laptop") (2=3 "My own smartphone")/*
*/(3=4 "Family device") (4=5 "School device"), gen(d_devicesvsno)
label val d_devicesvsno d_devicesvsno
_crcslbl d_devicesvsno st349q01ja

** ST222
********************************************************************************
local variables "sc222q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not at all or Very little") (3/4=1 "To some extent or A lot"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST217
********************************************************************************
local variables "sc217q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** st263q04 recoded (growth mindset in mathematics)
********************************************************************************
local variables "d_st263q04ja"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Strongly disagree/disagree") (3/4=1 "Agree/Strongly agree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
	}

	
	

** recoded ocod3
********************************************************************************

* Generate general careers (Expectations of working in 10 areas - ISCO):
cap drop career
cap gen career = 0

* missing codes:
replace career = .i if ocod3 == "9998" // (invalid: smiley face, etc.)
replace career = .m if ocod3 == "9999" | ocod3 == "" // no response 
replace career = .k if ocod3 == "9704" | ocod3 == "9705" | ocod3 == "9997" // vague/don't know/undecided
replace career = .n if bookid == 99 // not administered (uh students)
replace career = 10 if substr(ocod3,1,1) == "0"


replace career = 1 if substr(ocod3,1,1) == "1"
replace career = 2 if substr(ocod3,1,1) == "2"
replace career = 3 if substr(ocod3,1,1) == "3"
replace career = 4 if substr(ocod3,1,1) == "4"
replace career = 5 if substr(ocod3,1,1) == "5"
replace career = 6 if substr(ocod3,1,1) == "6"
replace career = 7 if substr(ocod3,1,1) == "7"
replace career = 8 if substr(ocod3,1,1) == "8"
replace career = 9 if substr(ocod3,1,1) == "9"
replace career = 10 if substr(ocod3,1,1) == "0"

* relabel categories
label define career 0 "no" 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed force" .n "not administered" .i "invalid" .m "missing" .k "vague"
label values career career  

* Check recoding
tab career, m

*Recode/split by each career category
forval x=1/12 {
	cap drop 		d_career_`x'
	gen 			d_career_`x'=career
	replace  		d_career_`x'=(career==`x')  if !missing(career)
	label values 	d_career_`x' d_career_`x'
	label define 	d_career_`x'  0 "No" 1 "Yes"
}

*rename variables
rename d_career_1 d_career_managers
rename d_career_2 d_career_profnals
rename d_career_3 d_career_technician
rename d_career_4 d_career_clerical
rename d_career_5 d_career_servicesal
rename d_career_6 d_career_skilledops
rename d_career_7 d_career_crafttrade
rename d_career_8 d_career_plantmachn
rename d_career_9 d_career_elementocc
rename d_career_10 d_career_armedforce

* Check recoding


* Generate sciecareer (Expectations of working in following 4 scientific areas, as defined in PISA 2018, Volume II):
gen sciecareer = 0
replace sciecareer = 1 if substr(ocod3,1,2) == "21" & ocod3 != "2163" & ocod3 != "2166"
replace sciecareer = 2 if substr(ocod3,1,2) == "22" & substr(ocod3,1,3) != "223"
replace sciecareer = 3 if substr(ocod3,1,2) == "25" 
replace sciecareer = 4 if substr(ocod3,1,3) == "311" | substr(ocod3,1,3) == "314" | (substr(ocod3,1,3) == "321" & ocod3 != "3214") | ocod3 == "3155" | ocod3 == "3522" 

* missing codes:
replace sciecareer = .i if ocod3 == "9998" // (invalid: smiley face, etc.)
replace sciecareer = .m if ocod3 == "9999" | ocod3 == "" // no response 
replace sciecareer = .k if ocod3 == "9704" | ocod3 == "9705" | ocod3 == "9997" // vague/don't know/undecided
replace sciecareer = .n if bookid == 99 // not administered (uh students)

*relabel categories:
label define sciecareer 0 "no" 1 "scientist/engineer" 2 "health professional" 3 "ICT professional" 4  "technician" .n "not administered" .i "invalid" .m "missing" .k "vague"
label values sciecareer sciecareer  

recode sciecareer (1 2 3 4 = 1) (.m .k .i = 0), gen(careerfour)

*Generate dummy for each career:
 
*science and engineering professionals 
cap drop d_scieengprof 
gen d_scieengprof =sciecareer
replace  d_scieengprof=(sciecareer==1)  if !missing(sciecareer)

*Health professionals 
cap drop d_healthprof 
gen d_healthprof = sciecareer 
replace  d_healthprof = (sciecareer==2) if !missing(sciecareer)

*ICT professionals 
cap drop d_ICTprof 
gen d_ICTprof  =sciecareer 
replace  d_ICTprof= (sciecareer== 3) if !missing(sciecareer)

*Science technicians and associate professionals 
cap drop d_scitechprof 
gen d_scitechprof  =sciecareer
replace  d_scitechprof = (sciecareer==4) if !missing(sciecareer)

*checks

	
* Generate 3 groups of skills (Expectations by skill level, as defined in PISA 2018, Volume II) 	
/**High skills level : 1,2,4; Medium skills: 4,5,6,7,8; Low skills: 9*/

*High-skilled job
cap drop d_skill_level_h
gen d_skill_level_h=(substr(ocod3,1,1)=="1" | substr(ocod3,1,1)=="2" | substr(ocod3,1,1)=="3")

*Medium-skilled job
cap drop d_skill_level_m
gen d_skill_level_m=(substr(ocod3,1,1)=="4" | substr(ocod3,1,1)=="5" | substr(ocod3,1,1)=="6" | substr(ocod3,1,1)=="7" | substr(ocod3,1,1)=="8")

*Low-skilled job
cap drop d_skill_level_l
gen d_skill_level_l=(substr(ocod3,1,1)=="9")  

* missing codes + labels:

foreach var in d_skill_level_h d_skill_level_m d_skill_level_l{

replace `var' = .i if ocod3 == "9998" // (invalid: smiley face, etc.)
replace `var' = .m if ocod3 == "9999" | ocod3 == "" // no response 
replace `var'  = .k if ocod3 == "9704" | ocod3 == "9705" | ocod3 == "9997" // vague/don't know/undecided
replace `var'  = .n if bookid == 99 // not administered (uh students)
label values 	`var' `var'
label define 	`var'  0 "No" 1 "Yes"

}


** ST349
********************************************************************************
cap drop d_owndev
recode st349q01ja (5 3=0 "no device or shared device") (1 2 4=1 "own device or lent by school"), gen(d_owndev) 
label val d_owndev d_owndev
_crcslbl d_owndev d_owndev

** Dummies st347q01ja
********************************************************************************
**dummy for extreme category no closure based on st347q01ja
cap drop d_covresp0
recode st347q01ja  (1=1 "no") (2/5=0 "less than 1 month to up to 12 month") (6=.) , gen(d_covresp0)
label val d_covresp0 d_covresp0
_crcslbl d_covresp0 st347q01ja
**dummy for extreme category over 12 month based on st347q01ja
cap drop d_covresp12
recode st347q01ja  (1=.) (2/5=0 "less than 1 month to up to 12 month") (6=1 "over 12 month") , gen(d_covresp12)
label val d_covresp12 d_covresp12
_crcslbl d_covresp12 st347q01ja
**dummy for non-response to closure question based on st347q01ja
mvencode st347q01ja, mv(99)
cap drop d_covresp
recode st347q01ja  (1/6=0 "response") (99=1 "no response"), gen(d_covresp)
label val d_covresp d_covresp
_crcslbl d_covresp st347q01ja
**dummy for not model grade based on grade_modal
cap drop d_grade
recode grade_modal  (1=0 "in modal grade") (0 2=1 "above/below modal grade"), gen(d_grade)
label val d_grade d_grade
_crcslbl d_grade grade_modal


