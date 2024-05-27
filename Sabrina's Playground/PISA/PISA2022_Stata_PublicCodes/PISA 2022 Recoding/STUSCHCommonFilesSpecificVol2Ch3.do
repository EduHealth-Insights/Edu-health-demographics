********************************************************************************
**																			  **
** STU_CommonFiles: Program to create common variables for STU Dataset		  **
**					Specific Vol 2											  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

********************************************************************************
**																			 
**		Volume II Chapter 3
**
********************************************************************************

** ST062 recoded and school level variables
********************************************************************************
local variables "st062q01* st062q02* st062q03*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0 "Never") (2/4=1 "At least once"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


local variables "d_st062* skipping"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st062* skipping"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST260 recoded and school level variables
********************************************************************************
cap drop st260all
gen st260all = . 

replace st260all = 1 if (st260q01ja ==  1 & (st260q02ja == 1 | st260q02ja == .) & (st260q03ja == 1 | st260q03ja == .))
replace st260all = 1 if (st260q02ja ==  1 & (st260q01ja == 1 | st260q01ja == .) & (st260q03ja == 1 | st260q03ja == .))
replace st260all = 1 if (st260q03ja ==  1 & (st260q02ja == 1 | st260q02ja == .) & (st260q01ja == 1 | st260q01ja == .))
replace st260all = 2 if (st260q01ja ==  2 & (st260q02ja == 1 | st260q02ja == .) & (st260q03ja == 1 | st260q03ja == .))
replace st260all = 2 if (st260q02ja ==  2 & (st260q01ja == 1 | st260q01ja == .) & (st260q03ja == 1 | st260q03ja == .))
replace st260all = 2 if (st260q03ja ==  2 & (st260q02ja == 1 | st260q02ja == .) & (st260q01ja == 1 | st260q01ja == .))
replace st260all = 3 if st260q01ja == 3 | st260q02ja == 3 | st260q03ja == 3
replace st260all = 3 if st260q01ja ==  2 & st260q02ja == 2 
replace st260all = 3 if st260q01ja ==  2 & st260q03ja == 2 
replace st260all = 3 if st260q02ja ==  2 & st260q03ja == 2 
label var st260all "Have you ever missed school for more than three months in a row at all ISCED"
label define st260all_label 1 "Never" 2 "Once" 3 "Twice or more" 
label values st260all st260all_label


cap drop d_st260q
gen d_st260q = . 

replace d_st260q = 0 if (st260q01ja == 1 & (st260q02ja == 1 | st260q02ja == .) & (st260q03ja == 1 | st260q03ja == .)) | (st260q02ja == 1 & (st260q01ja == 1 | st260q01ja ==  .) & (st260q03ja == 1 | st260q03ja == .)) | (st260q03ja == 1 & (st260q02ja == 1 | st260q02ja ==  .) & (st260q01ja == 1 | st260q01ja ==  .)) 
replace d_st260q = 1 if st260q01ja == 2 | st260q01ja == 3 | st260q02ja == 2 | st260q02ja == 3 | st260q03ja == 2 | st260q03ja == 3 
label var d_st260q "Have you ever missed school for more than three months in a row at all ISCED"
label define d_st260q_label 0 "Never" 1 "At least once"
label values d_st260q d_st260q_label

local variables "st260q01* st260q02* st260q03*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0 "Never") (2/3=1 "At least once"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


local variables "d_st260* misssc"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st260* misssc"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST034 recoded and school level variables
********************************************************************************

local variables "st034q02* st034q03* st034q05*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 "Strongly disagree/disagree") (1/2=1 "Agree/Strongly agree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}
*** Variables where disagree and strongly disasgree should be coded as 1.
local variables "st034q01* st034q04* st034q06*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Agree/Strongly agree") (3/4=1 "Disagree/Strongly disagree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


* xd_st034q*
local variables "d_st034* belong"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st034* belong"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}


** SC061 recoded 
********************************************************************************

local variables "sc061q06* sc061q07* sc061q08* sc061q09* sc061q10*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not at all/Very little") (3/4=1 "To some extent/A lot"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SC192 recoded 
********************************************************************************

local variables "sc192q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Never or almost never/A few times a year") (3/4=1 "A few times a month/Once a week or more"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** ST267 recoded and school level variables
********************************************************************************
local variables "st267q01* st267q02* st267q03* st267q05* st267q06* st267q07*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Strongly disagree/disagree") (3/4=1 "Agree/Strongly agree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}
*** Variables where disagree and strongly disasgree should be coded as 1.
local variables "st267q04* st267q08*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 "Agree/Strongly agree") (1/2=1 "Disagree/Strongly disagree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


* xd_st267q*
local variables "d_st267* relatst"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st267* relatst"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST300 recoded and school level variables
********************************************************************************

local variables "st300q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 "Never or almost never/About once or twice a year/About once or twice a month") (4/5=1 "About once or twice a week/Every day or almost every day"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


* xd_st300q*
local variables "d_st300* famsup"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st300* famsup"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST038 & bullied
********************************************************************************


**st038all
capture drop st038all
gen st038all=.
replace st038all=1 if (st038q03na==1 ) | (st038q04na==1 ) /*
*/ | (st038q05na==1 ) | (st038q06na==1) /*
*/ | (st038q07na==1 ) | (st038q08na==1 ) | (st038q11ja==1 )
replace st038all=2 if (st038q03na==2 ) | (st038q04na==2 ) /*
*/ | (st038q05na==2 ) | (st038q06na==2) /*
*/ | (st038q07na==2 ) | (st038q08na==2 ) | (st038q11ja==2 )
replace st038all=3 if (st038q03na==3 ) | (st038q04na==3 ) /*
*/ | (st038q05na==3 ) | (st038q06na==3) /*
*/ | (st038q07na==3 ) | (st038q08na==3 ) | (st038q11ja==3 )
replace st038all=4 if (st038q03na==4 ) | (st038q04na==4 ) /*
*/ | (st038q05na==4 ) | (st038q06na==4) /*
*/ | (st038q07na==4 ) | (st038q08na==4 ) | (st038q11ja==4 )
label define st038all 1 "Never or almost never" 2 "A few times a year" 3 "A few times a month" 4 "Once a week or more", modify // Add value labels
label val st038all st038all

**d_st038all
recode st038all (1/2=0 "Never or almost never/A few times a year") (3/4=1 "A few times a month/Once a week or more"), gen(d_st038all)
label val d_st038all d_st038all
_crcslbl d_st038all st038all

** Define a dummy for frequently bullied students: 1 if in the top 10% of international beingbullied
** beingbullied is not in the DB yet to check with ETS
_pctile bullied [aw=senwt], p(90)
gen nbullied_p90=r(r1)
capture drop nfreqbullied9
gen nfreqbullied9=0 if bullied<=nbullied_p90 & bullied!=. 
replace nfreqbullied9=1 if bullied>nbullied_p90 & bullied!=. 
replace nfreqbullied9=. if bullied==. 
label def nfreqbullied9  0 "Not frequently bullied students" 1 "Frequently bullied students", modify //Define value labels
label val nfreqbullied9 nfreqbully // Add value labels
label var nfreqbullied9 "Frequently bullied students" //Add variable label
tab nfreqbullied9, m

**d_st038q*
local variables "st038q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Never or almost never/A few times a year") (3/4=1 "A few times a month/Once a week or more"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}



* xd_st038 and x_bullied*
local variables "d_st038* bullied"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st038* bullied"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}


** ST270 recoded and school level variables
********************************************************************************

local variables "st270q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 " Never or almost never/Some lessons") (1/2=1 "Most lessons/Every lesson"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


* xd_st270q*
local variables "d_st270* teachsup"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st270* teachsup"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST273 recoded and school level variables
********************************************************************************

local variables "st273q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 " Some lessons/Most lessons/Every lesson") (4=1 "Never or almost never"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

* xd_st270q*
local variables "d_st273* disclim"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st273* disclim"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** SC064
********************************************************************************

local variables "sc064q*"
foreach vr of varlist `variables' {
	capture drop r_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr'(0/49=0 "Below 50%") (50/100=1 "Over 50%"), gen(r_`vr' ) //
	label val r_`vr' r_`vr' // Add value labels
	_crcslbl r_`vr' `vr' // Add the full variable label
}
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (0/49=0 "Below 50%") (50/100=1 "Over 50%"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST265 & feelsafe
********************************************************************************

local variables "st265q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3/4=0 "Disagree/Strongly disagree") (1/2=1 "Strongly Agree/Agree"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


* xd_st265q*
local variables "d_st265* feelsafe"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st265* feelsafe"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** ST266
********************************************************************************
local variables "st266q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

* x_st266q* xschrisk

local variables "d_st266q* schrisk"
foreach vr of varlist `variables' {
preserve
	drop if missing(`vr')
	collapse (mean) x`vr'=`vr' [pw=w_fstuwt],by(cnt cntschid)
	* Save the results to the chater specific folder
	save x`vr', replace
restore
}
local variables "d_st266q* schrisk"
foreach vr of varlist `variables' {
   merge m:1 cnt cntschid using x`vr', nogen
}

** SC172
********************************************************************************

local variables "sc172q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not at all/Small extent") (3/4=1 "Moderate extent/Large extent"), gen(d_`vr' ) //
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST261
********************************************************************************

local variables "st261q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

