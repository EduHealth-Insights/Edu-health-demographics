*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 3: Data Preparation
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
*******************************************************

clear 			all
set more 		off, perm

** Run environment do-file
run 			"c:\temp\pisa2022vol1_environment.do"

** Open PISA 2022 dataset using only variables needed for chapter 3 analysis
local 			keep2022ch3 "cnt cntschid fcntstuid *pv* w_fst* oecd"
use 			`keep2022ch3' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

rename fcntstuid cntstuid


**Save chapter-specific PISA 2022 dataset
qui compress
save "${infile}/I_B1_CH3_cnt.dta", replace

*******************************************************
** END OF DO-FILE
*******************************************************
