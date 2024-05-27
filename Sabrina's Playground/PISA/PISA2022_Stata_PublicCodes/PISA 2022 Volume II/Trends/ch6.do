********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Trends for Ch6
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
use fcnt cntschid cntstuid w_fstuwt w_fsturwt* sc034q* sc032q*  proatce using $confidentialdata\2015\pisa2015completedata.dta, clear
ren fcnt* cnt*

recode sc034q0*na (2/5=1) (1=0)
recode sc034q0*ta (4/5=1) (1/3=0)
recode sc032q* (1=1) (2=0)

save "$infile\stu_2015_ch6.dta", replace


** 2018 **

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* sc012q* sc037q* sc036q* sc011q* schltype using $confidentialdata\2018\pisa2018completedata_2.dta, clear
ren fcnt* cnt*
recode sc012q* (1=0) (2/3=1)
recode sc037q* (1/2=1) (3=0)
gen sc037q11ja = sc037q10na
recode sc036q01ta (1=1) (2=0), gen(sc198q01ja)
recode sc036q02ta (1=1) (2=0), gen(sc198q02ja)
recode sc036q03na (1=1) (2=0), gen(sc198q03ja)
drop if cnt == "QUR" //no trend for Ukraine
save "$infile\stu_2018_ch6_part1.dta", replace

use fcnt fcntschid fcntstuid w_fstuwt w_fsturwt* schltype using $confidentialdata\2018\pisa_dev18_complete.dta, clear
ren fcnt* cnt*

append using "V:\PISA_INITIALREPORT_2022\sandbox\ParallelRun\input\volume2\trend\stu_2018_ch6_part1.dta"
save "$infile\stu_2018_ch6.dta", replace
erase "$infile\stu_2018_ch6_part1.dta"

** 2022 **
use cnt cntschid fcntstuid w_fstuwt w_fsturwt* sc034q* sc032q* sc198q* sc037q* schltype sc012q* sc011q* using $confidentialdata\2022\pisa2022completedata.dta, clear
ren fcnt* cnt*
recode sc034q0*na (2/5=1) (1=0)
recode sc034q0*ta (4/5=1) (1/3=0)
recode sc032q* (1=1) (2=0)
recode sc012q* (1=0) (2/3=1)
recode sc198q* (1=1) (2=0)
recode sc037q* (1/2=1) (3=0)

save "$infile\stu_2022_ch6.dta", replace

******************************************************
* Running Repest
******************************************************

** Current directory
cd "$outfile"

local variables "sc034q01na sc034q02na sc034q03ta sc034q04ta sc032q01ta sc032q02ta sc032q03ta sc032q04ta"
local precyc "2015 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch6.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}



local variables "schltype sc198q01ja sc198q02ja sc198q03ja sc012q01ta sc012q02ta sc012q03ta sc012q04ta sc012q05ta sc012q06ta sc037q01ta sc037q02ta sc037q03ta sc037q04ta sc037q05na sc037q06na sc037q07ta sc037q08ta sc037q09ta sc037q11ja sc011q01ta"
local precyc "2018 2022" 

foreach pr in `precyc' {
	use "$infile/stu_`pr'_ch6.dta", clear
		foreach vr in `variables' {
			repest PISA, estimate(freq `vr')  by(cnt) outfile(pisa22vol2_type3_freq_`vr'_`pr', replace) $repestoptions 
		}
}


******************************************************
* Calculate differences
******************************************************

** Current directory
cd "$outfile"


  
global variables "sc034q01na sc034q02na sc034q03ta sc034q04ta sc032q01ta sc032q02ta sc032q03ta sc032q04ta"
local precyc "2015" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }

  
  
global variables "schltype sc198q01ja sc198q02ja sc198q03ja sc012q01ta sc012q02ta sc012q03ta sc012q04ta sc012q05ta sc012q06ta sc037q01ta sc037q02ta sc037q03ta sc037q04ta sc037q05na sc037q06na sc037q07ta sc037q08ta sc037q09ta sc037q11ja sc011q01ta"
local precyc "2018" // Define the trend year
* Run the loop
  foreach pr in `precyc' {
	foreach vr in $variables {
	pisatrend, table(pisa22vol2_type3_freq_`vr') first(`pr') last(2022)
	}
  }

  


 
 
******************************************************
* Export Tables
******************************************************

*** Table II_B1.6.SCHLTYPEc_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_schltype_2018, clear
ren schltype_* schltype_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_schltype_2022, nogen
merge 1:1 cnt using pisa22vol2_type3_freq_schltype_1822, nogen

save II_B1.6.SCHLTYPEc_3cat, replace
cntmean, table(II_B1.6.SCHLTYPEc_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SCHLTYPEc_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SCHLTYPEc_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SCHLTYPEc_3cat") select(cnt, $CNT2022 AVG)

**** Table II_B1.6.SCHSEL_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc012q01ta_2018, clear
drop *_0_*
ren sc012q01ta_1_* sc012q01ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q02ta_2018, nogen
drop *_0_*
ren sc012q02ta_1_* sc012q02ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q03ta_2018, nogen
drop *_0_*
ren sc012q03ta_1_* sc012q03ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q04ta_2018, nogen
drop *_0_*
ren sc012q04ta_1_* sc012q04ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q05ta_2018, nogen
drop *_0_*
ren sc012q05ta_1_* sc012q05ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q06ta_2018, nogen
drop *_0_*
ren sc012q06ta_1_* sc012q06ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q01ta_2022, nogen
drop *_0_*
ren sc012q01ta_1_* sc012q01ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q02ta_2022, nogen
drop *_0_*
ren sc012q02ta_1_* sc012q02ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q03ta_2022, nogen
drop *_0_*
ren sc012q03ta_1_* sc012q03ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q04ta_2022, nogen
drop *_0_*
ren sc012q04ta_1_* sc012q04ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q05ta_2022, nogen
drop *_0_*
ren sc012q05ta_1_* sc012q05ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q06ta_2022, nogen
drop *_0_*
ren sc012q06ta_1_* sc012q06ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q01ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q02ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q03ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q04ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q05ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc012q06ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
drop *_0_*

save II_B1.6.SCHSEL_3cat, replace
cntmean, table(II_B1.6.SCHSEL_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SCHSEL_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SCHSEL_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SCHSEL_3cat") select(cnt, $CNT2022 AVG)

*** Table II_B1.6.SC034_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc034q01na_2015, clear
drop *_0_*
ren sc034q01na_1_* sc034q01na_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q02na_2015, nogen
drop *_0_*
ren sc034q02na_1_* sc034q02na_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q01na_2022, nogen
drop *_0_*
ren sc034q01na_1_* sc034q01na_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q02na_2022, nogen
drop *_0_*
ren sc034q02na_1_* sc034q02na_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q01na_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q02na_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q03ta_2015, nogen
drop *_0_*
ren sc034q03ta_1_* sc034q03ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q04ta_2015, nogen
drop *_0_*
ren sc034q04ta_1_* sc034q04ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q03ta_2022, nogen
drop *_0_*
ren sc034q03ta_1_* sc034q03ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q04ta_2022, nogen
drop *_0_*
ren sc034q04ta_1_* sc034q04ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q03ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc034q04ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
drop *_0_*

save II_B1.6.SC034_3cat, replace
cntmean, table(II_B1.6.SC034_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SC034_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SC034_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SC034_3cat") select(cnt, $CNT2022 AVG)

*** Table II_B1.6.SC011_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc011q01ta_2018, clear
ren sc011q01ta_* sc011q01ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc011q01ta_2022, nogen
merge 1:1 cnt using pisa22vol2_type3_freq_sc011q01ta_1822, nogen

save II_B1.6.SC011_3cat, replace
cntmean, table(II_B1.6.SC011_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SC011_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SC011_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SC011_3cat") select(cnt, $CNT2022 AVG)

**** Table II_B1.6.SC198_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc198q01ja_2018, clear
drop *_0_*
ren sc198q01ja_1_* sc198q01ja_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q02ja_2018, nogen
drop *_0_*
ren sc198q02ja_1_* sc198q02ja_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q03ja_2018, nogen
drop *_0_*
ren sc198q03ja_1_* sc198q03ja_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q01ja_2022, nogen
drop *_0_*
ren sc198q01ja_1_* sc198q01ja_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q02ja_2022, nogen
drop *_0_*
ren sc198q02ja_1_* sc198q02ja_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q03ja_2022, nogen
drop *_0_*
ren sc198q03ja_1_* sc198q03ja_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q01ja_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q02ja_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc198q03ja_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
drop *_0_*

save II_B1.6.SC198_3cat, replace
cntmean, table(II_B1.6.SC198_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SC198_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SC198_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SC198_3cat") select(cnt, $CNT2022 AVG)

*** Table II_B1.6.SC032_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc032q01ta_2015, clear
drop *_0_*
ren sc032q01ta_1_* sc032q01ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q02ta_2015, nogen
drop *_0_*
ren sc032q02ta_1_* sc032q02ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q03ta_2015, nogen
drop *_0_*
ren sc032q03ta_1_* sc032q03ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q04ta_2015, nogen
drop *_0_*
ren sc032q04ta_1_* sc032q04ta_15_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q01ta_2022, nogen
drop *_0_*
ren sc032q01ta_1_* sc032q01ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q02ta_2022, nogen
drop *_0_*
ren sc032q02ta_1_* sc032q02ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q03ta_2022, nogen
drop *_0_*
ren sc032q03ta_1_* sc032q03ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q04ta_2022, nogen
drop *_0_*
ren sc032q04ta_1_* sc032q04ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q01ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q02ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q03ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc032q04ta_1522, nogen
ren *_1_diff_* *_1_1522_diff_*
drop *_0_*

save II_B1.6.SC032_3cat, replace
cntmean, table(II_B1.6.SC032_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SC032_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SC032_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SC032_3cat") select(cnt, $CNT2022 AVG)

**** Table II_B1.6.SC037_3cat
******************************************************  

** Current directory
cd "$outfile"  
** Create nable
use pisa22vol2_type3_freq_sc037q01ta_2018, clear
drop *_0_*
ren sc037q01ta_1_* sc037q01ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q02ta_2018, nogen
drop *_0_*
ren sc037q02ta_1_* sc037q02ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q03ta_2018, nogen
drop *_0_*
ren sc037q03ta_1_* sc037q03ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q04ta_2018, nogen
drop *_0_*
ren sc037q04ta_1_* sc037q04ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q05na_2018, nogen
drop *_0_*
ren sc037q05na_1_* sc037q05na_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q06na_2018, nogen
drop *_0_*
ren sc037q06na_1_* sc037q06na_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q07ta_2018, nogen
drop *_0_*
ren sc037q07ta_1_* sc037q07ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q08ta_2018, nogen
drop *_0_*
ren sc037q08ta_1_* sc037q08ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q09ta_2018, nogen
drop *_0_*
ren sc037q09ta_1_* sc037q09ta_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q11ja_2018, nogen
drop *_0_*
ren sc037q11ja_1_* sc037q11ja_18_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q01ta_2022, nogen
drop *_0_*
ren sc037q01ta_1_* sc037q01ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q02ta_2022, nogen
drop *_0_*
ren sc037q02ta_1_* sc037q02ta_1_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q03ta_2022, nogen
drop *_0_*
ren sc037q03ta_1_* sc037q03ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q04ta_2022, nogen
drop *_0_*
ren sc037q04ta_1_* sc037q04ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q05na_2022, nogen
drop *_0_*
ren sc037q05na_1_* sc037q05na_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q06na_2022, nogen
drop *_0_*
ren sc037q06na_1_* sc037q06na_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q07ta_2022, nogen
drop *_0_*
ren sc037q07ta_1_* sc037q07ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q08ta_2022, nogen
drop *_0_*
ren sc037q08ta_1_* sc037q08ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q09ta_2022, nogen
drop *_0_*
ren sc037q09ta_1_* sc037q09ta_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q11ja_2022, nogen
drop *_0_*
ren sc037q11ja_1_* sc037q11ja_22_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q01ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q02ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q03ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q04ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q05na_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q06na_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q07ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q08ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q09ta_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
merge 1:1 cnt using pisa22vol2_type3_freq_sc037q11ja_1822, nogen
ren *_1_diff_* *_1_1822_diff_*
drop *_0_*

save II_B1.6.SC037_3cat, replace
cntmean, table(II_B1.6.SC037_3cat) cntlist($AVG2022) cntvar(cnt) label(AVG)
** Always indicate the command use to add the average
use II_B1.6.SC037_3cat_AVG, replace 
pisaexport2, dir($output) directory2($excel) file(II_B1.6.SC037_3cat_AVG) outfile("PISA2022Vol2_Ch6_Tab_trend.xls") outsheet("II_B1.6.SC037_3cat") select(cnt, $CNT2022 AVG)