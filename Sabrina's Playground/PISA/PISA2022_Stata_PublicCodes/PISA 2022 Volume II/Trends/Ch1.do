********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch1
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

use fcnt cntschid cntstuid w_fstuwt w_fsturwt* st016q01na using $confidentialdata\2015\pisa2015student.dta, clear
ren fcnt cnt
gen r_lifesat=st016q01na
recode r_lifesat (0/4=1 "not satisfied") (5/10=2 "satisfied") , gen(lifesat_2cat)
recode lifesat_2cat (1=0 "Not satisfied with life (<5)") (2=1 "Life satisfaction >=5"), gen(satis)
recode lifesat_2cat (1=1 "Not satisfied with life (<5)") (2=0 "Life satisfaction >=5"), gen(notsatis)
save "$infile\stu_2015_ch1.dta", replace

** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st016q01na using $confidentialdata\2018\pisa2018student.dta, clear
ren fcnt* cnt*
gen r_lifesat=st016q01na
recode r_lifesat (0/4=1 "not satisfied") (5/10=2 "satisfied") , gen(lifesat_2cat)
recode lifesat_2cat (1=0 "Not satisfied with life (<5)") (2=1 "Life satisfaction >=5"), gen(satis)
recode lifesat_2cat (1=1 "Not satisfied with life (<5)") (2=0 "Life satisfaction >=5"), gen(notsatis)
drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch1_part1.dta", replace


use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st016q01na using $confidentialdata\2018\pisa_dev18_stu.dta, clear
order fcnt
ren fcnt* cnt*
gen r_lifesat=st016q01na
recode r_lifesat (0/4=1 "not satisfied") (5/10=2 "satisfied") , gen(lifesat_2cat)
recode lifesat_2cat (1=0 "Not satisfied with life (<5)") (2=1 "Life satisfaction >=5"), gen(satis)
recode lifesat_2cat (1=1 "Not satisfied with life (<5)") (2=0 "Life satisfaction >=5"), gen(notsatis)
append using "V:\PISA_INITIALREPORT_2022\sandbox\ParallelRun\input\volume2\trend\stu_2018_ch1_part1.dta"
save "$infile\stu_2018_ch1.dta", replace
erase "$infile\stu_2018_ch1_part1.dta"


** 2022 **
use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st016q01na using $confidentialdata\2022\pisa2022student.dta, clear
ren fcnt* cnt*
gen r_lifesat=st016q01na
recode r_lifesat (0/4=1 "not satisfied") (5/10=2 "satisfied") , gen(lifesat_2cat)
recode lifesat_2cat (1=0 "Not satisfied with life (<5)") (2=1 "Life satisfaction >=5"), gen(satis)
recode lifesat_2cat (1=1 "Not satisfied with life (<5)") (2=0 "Life satisfaction >=5"), gen(notsatis)
save "$infile\stu_2022_ch1.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "r_lifesat"
local precyc "2015 2018 2022" 


foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch1.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}
		
local variables "satis notsatis"
local precyc "2018 2022" // Define the trend year 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch1.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}
