clear all
set more off, perm

********************************************************************************
**																			  **
** Data_preparation_main: Program to merge tudent and school datasets, then	  **
**          calculate new variables, dummies etc...							  **
** Creation Date: 01/01/2023												  **
** Author: PISA TEAM, OECD													  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

** CommonFiles location where are stored the commonfiles to calculate new variables/dummies etc...

global commonfiles "C:\temp\commonfiles"

global 			CNT2022 "ALB ARE ARG AUS AUT BEL BGR BRA BRN CAN CHE  CHL  COL CRI CZE DEU DNK DOM ESP EST FIN FRA GBR GEO GRC GTM HKG HRV HUN IDN IRL ISL ISR ITA JAM JOR JPN KAZ KHM KOR KSV LTU LVA MAC MAR MDA MEX MKD MLT MNE MNG MYS NLD NOR NZL PAN PER PHL POL PRT PRY PSE  QAT QAZ QUR ROU SAU SGP SLV SRB SVK SVN  SWE TAP THA TUR URY USA UZB VNM"  //81 countries for PISA 2022
global 			AVG2022 "AUS AUT BEL CAN CHE CHL COL CRI CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ISL ISR ITA JPN KOR LTU LVA MEX NLD NOR NZL POL PRT SVK SVN  SWE TUR USA" //37 OECD countries

********************************************************************************
** Create the Merge dataset sch/student										  **
********************************************************************************

** Datasets Location - where aw PSIA dataset are stored
global pisa2022 "C:\temp\PISAsources\2022\"
cd "$pisa2022"
** Merging student and schools
use "$pisa2022\pisa2022student.dta"

merge m:1 cnt cntschid using "$pisa2022\pisa2022school.dta"
keep if _merge == 3
drop _merge
** We need to retrieve special information for scotland school from national questionnaire to recalculate private schools (see SCH_CommonFiles file)
merge m:1 cnt cntschid using "$pisa2022\pisa2022C341SCH_f.dta"
drop _merge

********************************************************************************
** Running CommonFiles to create variables									  **
********************************************************************************

** Renaming fcnt and fcntschit
** rename fcnt* cnt*

** Running CommonFiles


** TO RUN FIRST
** Sample
do "$commonfiles\sampling.do" //to create samplinngs conditions

** Student variables
do "$commonfiles\STU_CommonFiles.do" // Student recoding used for many different analysis (gender, escs, immigrant etc..)


** School variables
do "$commonfiles\SCH_CommonFiles.do" //School recoding used for many different anaylis (public, private, xescs)

** School and Student variables per chapter for Volume II
** Many of the recodings are not used in the volume but were used during the analysis

do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch1.do" // for the variable needed for Volume II Ch 1
do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch2.do" // for the variable needed for Volume II Ch 2
do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch3.do" // for the variable needed for Volume II Ch 3
do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch4.do" // for the variable needed for Volume II Ch 3
do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch5.do" // for the variable needed for Volume II Ch 5
do "$commonfiles\STUSCH_CommonFiles_SpecificVol2Ch6.do" // for the variable needed for Volume II Ch 6

** Saving complete dataset

save "$pisa2022\pisa2022completedata.dta"