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
**		Volume II Chapter 1
**
********************************************************************************

** WB155
********************************************************************************
local variables "wb155q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not at all satisfied/Not satisfied") (3/4=1 "Satisfied/Totally satisfied"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST226
********************************************************************************
local variables "st226q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2/5=0 "less than three years at this school") (1=1 "Three or more school years at this school"), gen(d_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

foreach vr of varlist `variables' {
	capture drop r_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=5) (2=4) (4=2) (5=1), gen(r_`vr' ) // For the sake of getting proper results, recode all the missing values to .

}
