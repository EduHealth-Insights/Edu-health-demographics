clear all
set more off, perm

********************************************************************************
**																			  **
**  Transfer all files from SPSS to Stata									  **
**																			  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD													  **
** Last Modification: 31/12/2023										  	  **
**																			  **
********************************************************************************


********************************************************************************
** Define location of folder												  **
********************************************************************************


** SPSS Datasets
global pisa2022SPSS "C:\temp\PISAsource\2022\"
** Stata Datasets
global pisa2022Stata "C:\temp\PISAsource\2022\"


********************************************************************************
** Transfer STU Dataset SPSS into Stata									  **
********************************************************************************

cd "$pisa2022SPSS"


import spss using "$pisa2022SPSS\CY08_MS_STU_QQQ_sample.sav", clear
qui compress // SPSS to STATA is too heavy
rename *, lower // stata case sensitive
* Rename value labels in lower cases
foreach v of varlist * { 
	local u : value label `v' 
	 local l = lower("`u'") 
	capture labvalclone `u' `l' 
	if _rc == 0 { 
		label val `v' `l' 
		label drop `u' 
	}
}
// Capture label directory output
*label dir
*foreach vr in `r(names)'{
*	labelrename `vr' stu`vr'
*}

* Save Into appropriate folder
save "$pisa2022Stata\cy08_ms_stu_qqq.dta", replace

