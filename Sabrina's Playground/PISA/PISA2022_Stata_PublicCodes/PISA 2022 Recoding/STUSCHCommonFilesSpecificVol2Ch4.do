********************************************************************************
**																			  **
** STU_CommonFiles: Program to create common variables for STU Dataset		  **
**					Specific Vol 2	Ch 4									  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

********************************************************************************
**																			 
**		Volume II Chapter 4
**
********************************************************************************

** SC012
********************************************************************************

local variables "sc012q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0 "Never") (2/3=1 "Sometimes/Always"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC042
********************************************************************************

local variables "sc042q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3=0 "Not for any subjects") (1/2=1 "For all subjects/for some subjects"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC185
********************************************************************************

local variables "sc185q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0 "Not likely") (2/3=1 "Likely/Very likely"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** Preprim (based on ST125 and durecec)
********************************************************************************
capture drop preprim
label define 		preprim 0 "Did not attend or attended less than a year" 1 "At least 1 year but less than 2" 2 "At least 2 years but less than 3" /*
					*/ 3 "3 years or more"
gen 				preprim = durecec
replace 			preprim = 0 if st125q01na==7
*replace 			preprim = . if fcnt=="" // check after if countries would like to make this to missing (like Macedonia in 2018)
recode 				preprim (4 5 6 7 8 9 =3) // Check when variable will be sent by ETS (in 2018 recoding of 0 and 1 to 0, but 2022 it seems it is not needed?)
label values 		preprim preprim
lab var				preprim "Duration in pre-primary"

*d_preprim
capture drop d_preprim
local variables "preprim"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (0=0 "Did not attend or attended less than a year") (1 2 3 =1 "Attended 1 year or more"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

*xd_preprim
local variables "d_preprim  durecec"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_preprim durecec"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}


** Grade_modal
********************************************************************************
capture drop grade_modal
label define grade_modal 0 "Below modal grade" 1 "At modal grade" 2 "Above modal grade"
gen grade_modal=.
replace grade_modal=0 if grade<0 
replace grade_modal=1 if grade==0 
replace grade_modal=2 if grade>0 & grade<10

*da_grade (grade above)
capture drop da_grade
recode grade_modal (2=1 "Above modal grade") (0 1=0 "Not at above modal grade"), gen(da_grade)
	label val da_grade da_grade // Add value labels

*db_grade (grade below)
capture drop db_grade
recode grade_modal (0=1 "Below modal grade") (1 2=0 "Not at below modal grade"), gen(db_grade)
	label val db_grade db_grade // Add value labels

** Repeat
********************************************************************************
cap drop repeat
gen repeat=1 if st127q01ta==3 | st127q02ta==3 | st127q03ta==3  | st127q01ta==2 | st127q02ta==2 | st127q03ta==2
replace repeat=0 if repeat!=1 & (st127q01ta==1 | st127q02ta==1 | st127q03ta==1)
replace repeat=. if missing(st127q01ta) & missing(st127q02ta) & missing(st127q03ta)
*replace st126q01ta = 4 if st126q01ta == 5 & st001 == 9 & repeat == 0 & cnt == "D087" //To check also with IDB1
*/

*d_st127
capture drop d_st127*
local variables "st127*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0 "Never repeated") (2 3 =1 "Repeated at least once"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

**school level for repeat and d_st127
local variables "repeat d_st127*"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "repeat d_st127*"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** r_st001
********************************************************************************
capture drop r_st001
gen r_st001=st001d01t
replace r_st001=0 if st001d01t==96
replace r_st001=. if st001d01t==99
