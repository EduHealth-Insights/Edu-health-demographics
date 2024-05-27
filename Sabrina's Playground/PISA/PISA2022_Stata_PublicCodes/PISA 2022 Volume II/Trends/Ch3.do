********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch3
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

** 2012 **
use fcnt schoolid stidstd w_fstuwt w_fst* st81q* st77q* using $confidentialdata\2012\pisa2012student.dta, clear
ren fcnt cnt
ren schoolid cntschid
ren stidstd cntstuid
ren w_fstr* w_fsturwt*
recode st77q01 (1/2=1) (3/4=0), gen(st270q01ja)
recode st77q02 (1/2=1) (3/4=0), gen(st270q02ja)
recode st77q04 (1/2=1) (3/4=0), gen(st270q03ja)
recode st77q05 (1/2=1) (3/4=0), gen(st270q04ja)

recode st81q01 (1/3=0) (4=1), gen(st273q01ja)
recode st81q02 (1/3=0) (4=1), gen(st273q02ja)
recode st81q03 (1/3=0) (4=1), gen(st273q03ja)
recode st81q04 (1/3=0) (4=1), gen(st273q04ja)
recode st81q05 (1/3=0) (4=1), gen(st273q05ja)

save "$infile\stu_2012_ch3.dta", replace

** 2015 **
use fcnt cntschid cntstuid w_fstuwt w_fsturwt*  st038q*  belong using $confidentialdata\2015\pisa2015student.dta, clear
ren fcnt* cnt*
recode st038q* (3/4=1) (1/2=0)

save "$infile\stu_2015_ch3.dta", replace

** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st034q* sc064q* st038q* st062q* belong using $confidentialdata\2018\pisa2018completedata.dta, clear
ren fcnt* cnt*
recode st034q02ta st034q03ta st034q05ta (1/2=1) (3/4=0)
recode st034q01ta st034q04ta st034q06ta (1/2=0) (3/4=1)
recode sc064q* (0/49=0) (50/100=1)
recode st038q* (3/4=1) (1/2=0)
recode st062q* (2/4=1) (1=0)
drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch3_part1.dta", replace

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* st068q* st078q* belong using $confidentialdata\2018\pisa_dev18_stu.dta, clear
ren fcnt* cnt*
recode st068q01ta (1/2=0) (3/4=1), gen(st034q01ta)
recode st068q02ta (1/2=1) (3/4=0), gen(st034q02ta)
recode st068q03ta (1/2=1) (3/4=0), gen(st034q03ta)
recode st068q04ta (1/2=0) (3/4=1), gen(st034q04ta)
recode st068q05ta (1/2=1) (3/4=0), gen(st034q05ta)
recode st068q06ta (1/2=0) (3/4=1), gen(st034q06ta)
drop st068q*

recode st078q01ta (2/4=1) (1=0), gen(st062q01ta)
recode st078q02ta (2/4=1) (1=0), gen(st062q02ta)
recode st078q03ta (2/4=1) (1=0), gen(st062q03ta)
drop st078q*
append using "V:\PISA_INITIALREPORT_2022\sandbox\ParallelRun\input\volume2\trend\stu_2018_ch3_part1.dta"
save "$infile\stu_2018_ch3.dta", replace
erase "$infile\stu_2018_ch3_part1.dta"

** 2022 **
use cnt cntschid fcntstuid w_fstuwt w_fsturwt* st034q* sc064q* st038q* st062q* belong st270q* st273q*  using $confidentialdata\2022\pisa2022completedata.dta, clear
ren fcnt* cnt*
recode st034q02ta st034q03ta st034q05ta (1/2=1) (3/4=0)
recode st034q01ta st034q04ta st034q06ta (1/2=0) (3/4=1)
recode sc064q* (0/49=0) (50/100=1)
recode st038q* (3/4=1) (1/2=0)
recode st062q* (2/4=1) (1=0)
recode st270q* (1/2=1) (3/4=0)
recode st273q* (1/3=0) (4=1)
drop st273q06* st273q07*

save "$infile\stu_2022_ch3.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "st034q01ta st034q02ta st034q03ta st034q04ta st034q05ta st034q06ta sc064q01ta sc064q02ta sc064q03ta sc064q04na st062q01ta st062q02ta st062q03ta"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch3.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "st038q03na st038q04na st038q05na st038q06na st038q07na st038q08na"
local precyc "2015 2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch3.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "belong "
local precyc "2015 2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch3.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "st270q01ja st270q02ja st270q03ja st270q04ja st273q01ja st273q02ja st273q03ja st273q04ja st273q05ja"
local precyc "2012 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch3.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}


******************************************************
* Calculate differences
******************************************************

** Current directory
cd "$outfile"

global variables "st034q01ta st034q02ta st034q03ta st034q04ta st034q05ta st034q06ta sc064q01ta sc064q02ta sc064q03ta sc064q04na st062q01ta st062q02ta st062q03ta"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }
  

global variables "st038q03na st038q04na st038q05na st038q06na st038q07na st038q08na"
local precyc "2015 2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  } 
  
global variables "belong"
local precyc "2015 2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_mean_`vr') first(`pr') last(2022)
	}
  }
  pisatrend, table(pisa22vol2_type3_mean_belong) first(2015) last(2018)
  
global variables "st270q01ja st270q02ja st270q03ja st270q04ja st273q01ja st273q02ja st273q03ja st273q04ja st273q05ja"
local precyc "2012" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }   
