*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 7: Data Preparation
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023											  
********************************************************

clear 			all
set more 		off, perm

** Run environment do-file
run 			"c:\temp\pisa2022vol1_environment.do"
 
** Open PISA 2022 dataset using only variables needed for chapter 7 analysis
local 			keep2022ch7 "cnt cntschid fcntstuid immig immback escs low_escs high_escs xescs boy difflang arrival diff_immback same_immback pv*math pv*read pv*scie pv*math_l pv*read_l pv*scie_l lp_pv*math_l lp_pv*read_l lp_pv*scie_l tp_pv*math_l tp_pv*read_l tp_pv*scie_l w_fst* t_fstuwt"
use 			`keep2022ch7' using "${confidentialdata}\2022\pisa2022completedata.dta" , clear

rename fcntstuid cntstuid


**Save chapter-specific PISA 2022 dataset
qui compress
save "${infile}\I_B1_CH7_cnt.dta", replace  

*******************************************************
** END OF DO-FILE
*******************************************************
