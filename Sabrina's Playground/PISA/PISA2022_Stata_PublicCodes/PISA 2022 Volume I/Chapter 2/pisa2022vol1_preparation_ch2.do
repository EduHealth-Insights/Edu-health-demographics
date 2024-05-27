*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 2: Data Preparation
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
*******************************************************

clear 			all
set more 		off, perm

** Run environment do-file
run 			"c:\temp\pisa2022vol1_environment.do"

** Open PISA 2022 dataset using only variables needed for chapter 2 analysis
local 			keep2022ch2 "fregion cnt cntschid cntstuid pv*read pv*math pv*m* pv*scie w_fst* oecd xmodalisced t_fstuwt senwt"
use 			`keep2022ch2' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

rename fcntstuid cntstuid


qui compress
save "${infile}/I_B1_CH2_cnt.dta", replace


*******************************************************
** END OF DO-FILE
*******************************************************
