********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch2
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023
********************************************************

clear all
set more 		off, perm
adopath ++ "c:\temp\statamacros"

** Location of files
global			confidentialdata 	"c:\temp\sources"
global			infile 				"c:\temp\Infile"
global			outfile 			"c:\temp\Outfile"
global			dofiles 			"c:\temp\Do-file"
global			logs	 			"c:\temp\Logs"
global 			repestoptions 		"pisacoverage flag" 	


** Country lists
global 			CNT2022 "ALB ARE ARG AUS AUT BEL BGR BRA BRN CAN CHE  CHL  COL CRI CZE DEU DNK DOM ESP EST FIN FRA GBR GEO GRC GTM HKG HRV HUN IDN IRL ISL ISR ITA JAM JOR JPN KAZ KHM KOR KSV LTU LVA MAC MAR MDA MEX MKD MLT MNE MNG MYS NLD NOR NZL PAN PER PHL POL PRT PRY PSE  QAT QAZ QUR ROU SAU SGP SLV SRB SVK SVN  SWE TAP THA TUR URY USA UZB VNM"  //81 countries for PISA 2022
global 			AVG2022 "AUS AUT BEL CAN CHE CHL COL CRI CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ISL ISR ITA JPN KOR LTU LVA MEX NLD NOR NZL POL PRT SVK SVN  SWE TUR USA" //37 OECD countries



******************************************************
* Creation of input dataset
******************************************************

** 2015 **


** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* ocod3 bookid using $confidentialdata\2018\pisa2018student.dta, clear
ren fcnt* cnt*

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

drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch2.dta", replace



** 2022 **
use cnt cntschid fcntstuid w_fstuwt w_fsturwt* d_scieengprof d_healthprof d_ICTprof d_scitechprof using $confidentialdata\2022\pisa2022completedata.dta, clear

save "$infile\stu_2022_ch2.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "d_scieengprof d_healthprof d_ICTprof d_scitechprof"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch2.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}
