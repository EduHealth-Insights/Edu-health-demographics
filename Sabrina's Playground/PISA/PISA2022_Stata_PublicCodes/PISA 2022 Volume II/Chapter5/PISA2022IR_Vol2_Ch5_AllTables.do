********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Tables for  Ch5
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023
********************************************************

** Load env

run 			"c:\temp\Do-files\EnvVol2.do"

** Load dataset

use 			"$infile/pisa2022completedata.dta", clear

** go to outfile folder

cd "$outfile"

** Table II.B1.5.1

See Table II.B1.1.1 variables: staffshort sc017

** Table II.B1.5.2

See Table II.B1.1.3 variables: staffshort

** Table II.B1.5.3

See Trend tables

** Table II.B1.5.4

See Trend tables

** Table II.B1.5.5

See Table II.B1.1.8 variables: staffshort d_sc017

** Table II.B1.5.6

See Table II.B1.1.8 variables: d_sc017

** Table II.B1.5.7

See Table II.B1.1.1 variables: proatce propat6 propat7 propat8

** Table II.B1.5.8

cap drop totat2 totcat
gen totat2 = . // total tch
gen totcat = .  // total cert tch
* Full Time and Part Time teachers
replace totat2 = sc018q01ta01+.5*sc018q01ta02 if !missing(sc018q01ta01,sc018q01ta02,sc018q02ta01,sc018q02ta02)
replace totcat = sc018q02ta01+.5*sc018q02ta02 if !missing(sc018q01ta01,sc018q01ta02,sc018q02ta01,sc018q02ta02)
replace totcat = 100*totcat // to get ratio in percentage
** Define numerator and denominator
* proatce: totcat / totat2
*local proatce_num "totcat"
*local proatce_den "totat2"
** Sample size and Coverage 
cap drop *sample
gen sample = (xmodalisced * !missing(proatce,totcat,totat2,w_fstuwt,w_schgrnrabwt)) // other exclusion criteria?
egen schsample = tag(cnt cntschid) if sample
replace sample = sample*100
preserve 
	gen tottemp = totat2
	collapse (rawsum) tottemp schsample (mean) sample [aw=w_fstuwt], by(cnt) // use original (student) weights for coverage
	rename (tottemp schsample sample) (nteach_proatce nsch_proatce coverage_proatce)
	save pisa22vol2_type1mod_FullCertTeach_Part1, replace
restore
* We are defining sub sample to make sure there are at least 5 schools in the category
* ESCS
gen indice_xescs1 = .
gen indice_xescs2 = .
gen indice_xescs3 = .
gen indice_xescs4 = .
replace indice_xescs1 = 1 if (xescsq == 1 & sample == 100)
replace indice_xescs2 = 1 if (xescsq == 2 & sample == 100)
replace indice_xescs3 = 1 if (xescsq == 3 & sample == 100)
replace indice_xescs4 = 1 if (xescsq == 4 & sample == 100)
by cnt, sort: replace indice_xescs1 = sum(indice_xescs1)
by cnt, sort: replace indice_xescs1 = indice_xescs1[_N]
by cnt, sort: replace indice_xescs2 = sum(indice_xescs2)
by cnt, sort: replace indice_xescs2 = indice_xescs2[_N]
by cnt, sort: replace indice_xescs3 = sum(indice_xescs3)
by cnt, sort: replace indice_xescs3 = indice_xescs3[_N]
by cnt, sort: replace indice_xescs4 = sum(indice_xescs4)
by cnt, sort: replace indice_xescs4 = indice_xescs4[_N]
gen sample_xescs = 0
replace sample_xescs = 100 if(indice_xescs1 >=5 & xescsq == 1 & sample == 100)
replace sample_xescs = 100 if(indice_xescs2 >=5 & xescsq == 2 & sample == 100)
replace sample_xescs = 100 if(indice_xescs3 >=5 & xescsq == 3 & sample == 100)
replace sample_xescs = 100 if(indice_xescs4 >=5 & xescsq == 4 & sample == 100)
drop indice_*
* School type
gen indice_schltype1=0
gen indice_schltype2=0
gen indice_schltype3=0
replace indice_schltype1 = 1 if (schltype == 1 & sample == 100)
replace indice_schltype2 = 1 if (schltype == 2 & sample == 100)
replace indice_schltype3 = 1 if (schltype == 3 & sample == 100)
by cnt, sort: replace indice_schltype1 = sum(indice_schltype1)
by cnt, sort: replace indice_schltype1 = indice_schltype1[_N]
by cnt, sort: replace indice_schltype2 = sum(indice_schltype2)
by cnt, sort: replace indice_schltype2 = indice_schltype2[_N]
by cnt, sort: replace indice_schltype3 = sum(indice_schltype3)
by cnt, sort: replace indice_schltype3 = indice_schltype3[_N]
gen sample_schltype = 0
replace sample_schltype = 100 if(indice_schltype1 >=5 & schltype == 1 & sample == 100)
replace sample_schltype = 100 if(indice_schltype2 >=5 & schltype == 2 & sample == 100)
replace sample_schltype = 100 if(indice_schltype3 >=5 & schltype == 3 & sample == 100)
drop indice_*
* Overall ratio
local proatce_num "totcat"
local proatce_den "totat2"
repest PISA if sample, est(summarize `proatce_den' `proatce_num', stats(sum)) by(cnt) results(combine(proatce:_b[`proatce_num'_sum] / _b[`proatce_den'_sum])) outfile(pisa22vol2_type1mod_FullCertTeach_Part2) svyparms(final_weight_name(w_fschwt) rep_weight_name(w_fschrwt)) flag
** Ratio by ESCS
local proatce_num "totcat"
local proatce_den "totat2"
repest PISA if sample_xescs, est(summarize `proatce_den' `proatce_num', stats(sum)) by(cnt) over(xescsq,test) results(combine(proatce:_b[`proatce_num'_sum] / _b[`proatce_den'_sum])) outfile(pisa22vol2_type1mod_FullCertTeach_Part3) svyparms(final_weight_name(w_fschwt) rep_weight_name(w_fschrwt)) flag
** Ratio by school type (public/private)
local proatce_num "totcat"
local proatce_den "totat2"
repest PISA if sample_schltype, est(summarize `proatce_den' `proatce_num', stats(sum)) over(schltype) by(cnt) results(combine(proatce:_b[`proatce_num'_sum] / _b[`proatce_den'_sum])) outfile(pisa22vol2_type1mod_FullCertTeach_part4) svyparms(final_weight_name(w_fschwt) rep_weight_name(w_fschrwt)) flag
recode schltype (1=0) (2 3 = 1)
repest PISA if sample_schltype, est(summarize `proatce_den' `proatce_num', stats(sum)) over(schltype, test) by(cnt) results(combine(proatce:_b[`proatce_num'_sum] / _b[`proatce_den'_sum])) outfile(pisa22vol2_type1mod_FullCertTeach_part5) svyparms(final_weight_name(w_fschwt) rep_weight_name(w_fschrwt)) flag
* Ratio by academic/vocational
preserve 
* Use Chapter Stratification specific dataset
use "$infile\infile_vol2_resources", clear
cd "$output"
*Frequencies
local variables "proatce"
local over "general"
foreach vr of varlist `variables' {
	foreach o of varlist  `over' {		// Run the estimation for all isced levels
		repest PISA if xmodalisced, estimate(means `vr') over(`o', test)  by(cnt) outfile(pisa22vol2_type1mod_FullCertTeach_part6, replace) pisacoverage flag /*fast*/
	}
}

** Table II.B1.5.9

See Trend Tables

** Table II.B1.5.10

See Table II.B1.1.8 variables protce

** Table II.B1.5.11

Similar logic than Table II.B1.5.8 with variable stratio

** Table II.B1.5.12

See Table II.B1.1.1 variable stratio

** Table II.B1.5.13

See Trend Tables

** Table II.B1.5.14

Similar logic than Table II.B1.5.8 with variable mclsize

** Table II.B1.5.15

Similar logic than Table II.B1.5.8 with variable clsize

** Table II.B1.5.16

See Trend Tables

** Table II.B1.5.17

See Table II.B1.1.1 Variables edushort sc017q05 to q10

** Table II.B1.5.18

See Table II.B1.1.3 variable edushort

** Table II.B1.5.19

See Table II.B1.1.3 variable d_sc017q09

** Table II.B1.5.20

See Table II.B1.1.3 variables d_sc017q10

** Table II.B1.5.21 - 22

See Trend tables

** Table II.B1.5.23

See Table II.B1.1.8 variables eduschort sc017q05 to q10

** Table II.B1.5.24

See Table II.B1.1.3 variable ratcmp1

** Table II.B1.5.25

See Trend Tables

** Table II.B1.5.26

See Table II.B1.1.8 variable ratcmp1

** Table II.B1.5.27

See Table II.B1.1.3 variable rattab

** Table II.B1.5.28

See Table II.B1.1.8 variable rattab

** Table II.B1.5.29

See Table II.B1.1.1 variable digprep

** Table II.B1.5.30

See Table II.B1.1.3 variable digprep

** Table II.B1.5.31

See Table II.B1.1.3 variable d_sc155q11

** Table II.B1.5.32

See Trend Tables

** Table II.B1.5.33

See Table II.B1.1.8 variables digprep d_sc155q06 to q11

** Table II.B1.5.34

See Table II.B1.1.8 variables digprep ratcmp1 d_sc190q05

** Table II.B1.5.35

See Table II.B1.1.1 variables digdvpol sc190

** Table II.B1.5.36

See Table II.B1.1.3 variables digdvpol

** Table II.B1.5.37

See Table II.B1.1.3 variables sc190q02

** Table II.B1.5.38

See Table II.B1.1.8 variables digdvpol d_sc190

** Table II.B1.5.39

See Table II.B1.1.1 variabes ic170q02 sc190q02

** Table II.B1.5.40

repest PISA, estimate (stata: logit  `arg2'  `arg3' escs xescs) results(add(r2)) by(cnt)  outfile( pisa22vol2_logit_`arg2'_`arg3'_AFT, replace )  pisacoverage flag

** Table II.B1.5.41 to 45

Same repest logic as Table II.B1.5.40

** Table II.B1.5.46

See Table II.B1.1.1 variable st322

** Table II.B1.5.47-48

See Table II.B1.1.2 variable b_st322q06 b_st322q07

** Table II.B1.5.49-50

See Table II.B1.1.3 variable b_st322q06 b_st322q07

** Table II.B1.5.51

See Table II.B1.1.8 variable b_st322q

** Table II.B1.5.52

See Table II.B1.1.1 variable thours st059q02 sc175q02 thours6

** Table II.B1.5.53

See Table II.B1.1.2 variables thours

** Table II.B1.5.54

See Table II.B1.1.3 variables thours

** Table II.B1.5.55

See Table II.B1.1.8 variables thours6

** Table II.B1.5.56

See Table II.B1.1.1 variables h_st296q04 d_st296q04

** Table II.B1.5.57

See Table II.B1.1.2 variables binv_st296q01 b_st296q04

** Table II.B1.5.58

See Table II.B1.1.2 variables b_st296q01 binv_st296q04

** Table II.B1.5.59

See Table II.B1.1.3 variables binv_st296q01 b_st296q04

** Table II.B1.5.60

See Table II.B1.1.3 variables b_st296q01 binv_st296q04

** Table II.B1.5.61

See Table II.B1.1.8 variables studyhmw d_st296

** Table II.B1.5.62

See Table II.B1.1.1 variables d_st326 h_st326

** Table II.B1.5.63

See Table II.B1.1.1 variables h_st326_learning_week  h_st326_leisure_week h_st326_tot_week h_st326_lear_wk6  h_st326_leis_wk6 h_st326_tot_wk7

** Table II.B1.5.64

See Table II.B1.1.1 variables st326q01ja6

** Table II.B1.5.65

See Table II.B1.1.1 variables st326q04ja6

** Table II.B1.5.66

See Table II.B1.1.8 variables st326q01ja6

** Table II.B1.5.67

See Table II.B1.1.8 variables st326q04ja6

** Table II.B1.5.68 to 76

See Table II.B1.1.2 variable h_st326q01 to h_st326q056 and h_st326_tot_week h_st326_learning_week h_st326_leisure_week

** Table II.B1.5.77

See Table II.B1.1.8 variables h_st326

** Table II.B1.5.78 to 80

See Table II.B1.1.8 variables h_st326_learning_week h_st326_lear_wk6 h_st326_leisure_week h_st326_leis_wk6 h_st326_tot_week h_st326_tot_wk7 

** Table II.B1.5.81

See Table II.B1.1.8 variables b_st322q07ja pv@math r_lifesat stresagr emocoagr

** Table II.B1.5.82

See Table II.B1.1.1 variable sc212


** Table II.B1.5.83 to 85

See Table II.B1.1.3 variable d_sc212

** Table II.B1.5.86

See Trend tables

** Table II.B1.5.87

See Tables II.B1.1.8 variables d_sc212, pv@math

** Table II.B1.5.88

See Table II.B1.1.8 variables d_sc212q01ja d_sc212q02ja d_sc212q03ja r_lifesat belong

** Table II.B1.5.89

See Table II.B1.1.1 variables ictreg ic179

** Table II.B1.5.90

See Table II.B1.1.2 variables ictreg

** Table II.B1.5.91

See Table II.B1.1.3 variables ictreg

** Table II.B1.5.92

See Table II.B1.1.8 variables ictreg d_ic179

** Table II.B1.5.93

See Table II.B1.1.1 variables r_fulltime r_parttime

** Table II.B1.5.94

See Table II.B1.5.8 variable r_fulltime

** Table II.B1.5.95

See Table II.B1.5.8 variable r_parttime

** Table II.B1.5.96

See table II.B1.1.3 variables p80_r_fulltime

** Table II.B1.5.97

See table II.B1.1.3 variables p20_r_parttime

** Table II.B1.5.98

See Trend Tables

** Table II.B1.5.99

See table II.B1.1.8 variables p80_r_fulltime p20_r_parttime
