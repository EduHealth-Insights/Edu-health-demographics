********************************************************************************
**																			  **
** Sampling: to create samples				to run first!!!					  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

** Sample for all student
********************************************************************************

gen sample_all = 1

** Sample for list of variables
********************************************************************************


local variables "st301* st303* st305* st307* st313* st343* st345* st267* st034* st322* st330* st324* st300* st273* st285* st283* st275* st276* st290* st291* st289* st292* st293* st334* st335* st336* st340* st342* st348* st352* st353* st354* st355*"
foreach vr of varlist `variables' {
	capture drop sample_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr'  (0/10=1) (.=0), gen(sample_`vr' )
	recode `vr' (0=.) // to kill the value No response that is used for the sampling

}

** Sample for list of DVs
********************************************************************************

local variables "famsupsl probself sdleff schsust learres feellah"
foreach vr of varlist `variables' {
	capture drop sample_`vr'
	gen sample_`vr' = 1
	replace sample_`vr' = 0 if st347q01ja == 1
}