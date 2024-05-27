********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch5
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
use fcnt schoolid stidstd w_fstuwt w_fst* sc16q* ratcmp1 propcert using $confidentialdata\2012\pisa2012completedata.dta, clear
ren fcnt cnt
ren schoolid cntschid
ren stidstd cntstuid
ren w_fstr* w_fsturwt*
recode sc16q01 (2=0) (1=1), gen(sc053q01ta)
recode sc16q02 (2=0) (1=1), gen(sc053q02ta)
recode sc16q03 (2=0) (1=1), gen(sc053q03ta)
recode sc16q04 (2=0) (1=1), gen(sc053q04ta)
recode sc16q05 (2=0) (1=1), gen(sc053q05na)
recode sc16q06 (2=0) (1=1), gen(sc053q06na)
recode sc16q07 (2=0) (1=1), gen(sc053q07ta)
recode sc16q08 (2=0) (1=1), gen(sc053q08ta)
recode sc16q09 (2=0) (1=1), gen(sc053q09ta)
recode sc16q10 (2=0) (1=1), gen(sc053q10ta)
ren ratcmp15 ratcmp1
gen proatce = propcert
save "$infile\stu_2012_ch5.dta", replace

** 2015 **
use fcnt cntschid cntstuid w_fstuwt w_fsturwt* ratcmp1 sc017q* proatce using $confidentialdata\2015\pisa2015completedata.dta, clear
ren fcnt* cnt*
recode sc017q* (1/2=0) (3/4=1)

save "$infile\stu_2015_ch5.dta", replace

** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* sc017q* clsize r_fulltime sc155q* ratcmp1 proatce r_parttime edushort stratio staffshort tmins sc052q* mmins using $confidentialdata\2018\pisa2018completedata_2.dta, clear
ren fcnt* cnt*
recode sc017q* (1/2=0) (3/4=1)
cap drop  mhours
gen mhours = mmins / 60
cap drop  thours
gen thours = tmins / 60
foreach x in  mhours thours  {
	cap drop `x'6
	gen `x'6 = `x'
	forvalues i = 1/6 {
		replace `x'6 = `i' if `x'>(`i'-1) & `x'<=`i'
		replace `x'6 = 1 if `x'==0
		replace `x'6 = 6 if `x'>6 & !missing(`x')
		}
}
cap drop thours6
gen thours6 = thours
replace thours6 = 1 if thours<=20
replace thours6 = 2 if thours>20 & thours<=24
replace thours6 = 3 if thours>24 & thours<=27
replace thours6 = 4 if thours>27 & thours<=32
replace thours6 = 5 if thours>32 & thours<=39
replace thours6 = 6 if thours>39 & !missing(thours)
recode sc052q01na (2=0) (1=1), gen(sc212q01ja)
recode sc052q02na (2=0) (1=1), gen(sc212q02ja)
recode sc052q03ha (2=0) (1=1), gen(sc212q03ja)

recode sc155q* (3/4=1) (1/2=0)
drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch5_part1.dta", replace

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* sc017q* stratio clsize using $confidentialdata\2018\pisa_dev18_complete.dta, clear
ren fcnt* cnt*
recode sc017q* (1/2=0) (3/4=1)


append using "V:\PISA_INITIALREPORT_2022\sandbox\ParallelRun\input\volume2\trend\stu_2018_ch5_part1.dta"
save "$infile\stu_2018_ch5.dta", replace
erase "$infile\stu_2018_ch5_part1.dta"

** 2022 **
use cnt cntschid fcntstuid w_fstuwt w_fsturwt* staffshort sc017q* mhours* thours* proatce sc155q* ratcmp1 edushort r_fulltime stratio clsize sc053q* sc212q* r_parttime using $confidentialdata\2022\pisa2022completedata.dta, clear
ren fcnt* cnt*
recode sc017q* (1/2=0) (3/4=1)
recode sc212q* (2=0) (1=1)
recode sc053q* (2=0) (1=1)
recode sc155q* (3/4=1) (1/2=0)
save "$infile\stu_2022_ch5.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "sc155q06ha sc155q07ha sc155q08ha sc155q09ha sc155q10ha sc155q11ha"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}


local variables "mhours6 thours6 sc212q01ja sc212q02ja sc212q03ja"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "sc053q01ta sc053q02ta sc053q03ta sc053q04ta sc053q05na sc053q06na sc053q07ta sc053q08ta sc053q09ta sc053q10ta"
local precyc "2012 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}



local variables "sc017q01na sc017q02na sc017q03na sc017q04na"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}


local variables "stratio staffshort r_parttime r_fulltime clsize"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "edushort"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "ratcmp1"
local precyc "2012 2015 2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "proatce"
local precyc "2012 2015 2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr of varlist `variables' {
			repest PISA, estimate(summarize `vr', stats(mean sd))  by(cnt) outfile(pisa22vol2_type3_mean_`vr'_`pr', replace) $repestoptions 
		}
}

local variables "sc017q05na sc017q06na sc017q07na sc017q08na"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch5.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}


******************************************************
* Calculate differences
******************************************************

** Current directory
cd "$outfile"

global variables "sc017q01na sc017q02na sc017q03na sc017q04na"
local precyc "2015 2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }

global variables "sc017q05na sc017q06na sc017q07na sc017q08na sc155q06ha sc155q07ha sc155q08ha sc155q09ha sc155q10ha sc155q11ha"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }
  
global variables "mhours6 thours6 sc212q01ja sc212q02ja sc212q03ja"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }

  
global variables "stratio staffshort r_parttime r_fulltime clsize edushort"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_mean_`vr') first(`pr') last(2022)
	}
  }

  
global variables "ratcmp1 proatce"
local precyc "2012 2015 2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_mean_`vr') first(`pr') last(2022)
	}
  }
  


global variables "sc053q01ta sc053q02ta sc053q03ta sc053q04ta sc053q05na sc053q06na sc053q07ta sc053q08ta sc053q09ta sc053q10ta"
local precyc "2012" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }
 
 