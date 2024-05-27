********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch4
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


** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st125* sc042q* repeat durecec general using $confidentialdata\2018\pisa2018completedata_2.dta, clear
ren fcnt* cnt*
capture drop preprim
label define 		preprim 0 "Did not attend or attended less than a year" 1 "At least 1 year but less than 2" 2 "At least 2 years but less than 3" /*
					*/ 3 "3 years or more"
gen 				preprim = durecec
replace 			preprim = 0 if st125q01na==7
recode 				preprim (4 5 6 7 8 9 =3) 
label values 		preprim preprim
lab var				preprim "Duration in pre-primary"
recode general (1=0) (0=1)
drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch4_part1.dta", replace

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* repeat using $confidentialdata\2018\pisa_dev18_complete.dta, clear
ren fcnt* cnt*

append using "V:\PISA_INITIALREPORT_2022\sandbox\ParallelRun\input\volume2\trend\stu_2018_ch4_part1.dta"
save "$infile\stu_2018_ch4.dta", replace
erase "$infile\stu_2018_ch4_part1.dta"

** 2022 **
use cnt cntschid fcntstuid w_fstuwt w_fsturwt* sc042q* general preprim repeat using $confidentialdata\2022\pisa2022completedata.dta, clear
ren fcnt* cnt*
recode general (1=0) (0=1)


save "$infile\stu_2022_ch4.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "general repeat preprim sc042q01ta sc042q02ta"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch4.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}

use pisa22vol2_type3_freq_preprim_2018, clear
drop if cnt == "C260"
save pisa22vol2_type3_freq_preprim_2018, replace


******************************************************
* Calculate differences
******************************************************

** Current directory
cd "$outfile"


  
global variables "general repeat preprim sc042q01ta sc042q02ta"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }

  
