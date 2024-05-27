*******************************************************
*** PISA 2022 RESULTS: VOLUME I
*** Chapter 4: Data Preparation
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023		
*******************************************************

clear 			all
set more 		off, perm

** Run environment do-file
run 			"c:\temp\pisa2022vol1_environment.do"
 
** Open PISA 2022 dataset using only variables needed for chapter 4 analysis
local 			keep2022ch4 "cnt cntschid cntstuid oecd escs escs_q low_escs med_escs high_escs intl_escs_* pv*read pv*read_l pv*math pv*math_l pv*scie pv*scie_l lp_pv*math_l lp_pv*read_l lp_pv*scie_l tp_pv*math_l tp_pv*read_l tp_pv*scie_l nresilient*math nresilient*read nresilient*scie resilient*math resilient*read resilient*scie boy girl xmodalisced w_fst* t_fstuwt"
use 			`keep2022ch4' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

rename fcntstuid cntstuid


**Save chapter-specific PISA 2022 dataset
qui compress
save "${infile}\I_B1_CH4_cnt.dta", replace  



*******************************************************
** END OF DO-FILE
*******************************************************

