********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Tables for  Ch3
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

** Table II.B1.3.1

See table II.B1.1.1 Variables: teachsup st270

** Table II.B1.3.2

See Table II.B1.1.2 Variables: teachsup

** Table II.B1.3.3

See Table II.B1.1.3 variables: teachsup

** Table II.B1.3.4

See Trend folder

** Table II.B1.3.5

See Table II.B1.1.8 Variables: teachsup d_st270

** Table II.B1.3.6

Table II.B1.1.9 Variables: teachsup xd_st270

** Table II.B1.3.7

global variables "teachsup"
global outcome "r_lifesat belong sdleff anxmat grosagr bsmj "

foreach vr in $variables {
	foreach out in $outcome {
		repest PISA, estimate (stata: reg `out' i.`vr' if !missing(escs) & !missing(xescs)) results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_BEF, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' i.`vr' escs xescs) 						    results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT, replace) pisacoverage flag
	}
}

** Table II.B1.3.8

global variables " d_st270q01ja d_st270q02ja d_st270q03ja d_st270q04ja teachsup"
global outcome "anxmat"
foreach vr in $variables {
	foreach out in $outcome {
		repest PISA, estimate (stata: reg `out' `vr' if !missing(escs) & !missing(xescs) & !missing(pv@math)) results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_BEF, replace) pisacoverage flag
		repest PISA, estimate (stata: reg `out' `vr' escs xescs if !missing(pv@math)) 						  results(add(r2)) by(cnt) outfile(pisa22vol2_type5st_reg_`out'_`vr'_AFT1, replace) pisacoverage flag
	}
}

** Table II.B1.3.9

See table II.B1.1.1 Variables: disclim st273

** Table II.B1.3.10

See Table II.B1.1.2 Variables: disclim

** Table II.B1.3.11

See Table II.B1.1.3 variables: disclim

** Table II.B1.3.12

See Trend folder

** Table II.B1.3.13

See Table II.B1.1.8 Variables: disclim d_st273

** Table II.B1.3.14

See Table II.B1.1.9 Variables: disclim xd_st273

** Table II.B1.3.15

See table II.B1.3.7 variables: disclim

** Table II.B1.3.16

See table II.B1.3.8 variables: disclim d_st273

** Table II.B1.3.17

See table II.B1.1.1 Variables: feelsafe st265

** Table II.B1.3.18

See table II.B1.1.2 Variables: feelsafe

** Table II.B1.3.19

See table II.B1.1.3 Variables: feelsafe

** Table II.B1.3.20

See table II.B1.1.8 Variables: feelsafe d_st265

** Table II.B1.3.21

See table II.B1.1.9 Variables: feelsafe xd_st265

** Table II.B1.3.22

See table II.B1.3.7 variables: feelsafe

** Table II.B1.3.23

See table II.B1.1.1 Variables: schrisk st266

** Table II.B1.3.24

See table II.B1.1.2 Variables: schrisk

** Table II.B1.3.25

See table II.B1.1.3 Variables: schrisk

** Table II.B1.3.26

See table II.B1.1.8 Variables: schrisk d_st266

** Table II.B1.3.27

See table II.B1.1.9 Variables: schrisk xd_st266

** Table II.B1.3.28

See table II.B1.3.7 variables: schrisk

** Table II.B1.3.29

* Step1: Relationship between predictor and mediators controlling for SESs
repest PISA, estimate (stata: reg feelsafe schrisk escs xescs) by(cnt)  outfile(pisa22vol2_type11_med1_feelsafe_schrisk, replace) pisacoverage flag
repest PISA, estimate (stata: reg teachsup  schrisk escs xescs) by(cnt)  outfile(pisa22vol2_type11_med1_teachsup_schrisk, replace)  pisacoverage flag
* Step2: Relationship between predictor and outcome controlling for SESs (using same samples so exclude missings)
repest PISA, estimate (stata: reg belong schrisk escs xescs if !missing(feelsafe) & !missing(teachsup)) by(cnt) outfile(pisa22vol2_type11_med2_belong_schrisk, replace) pisacoverage flag
* Step3: Relationship between predictor and outcome controlling for SESs and first predictor (using same samples so exclude missings)
repest PISA, estimate (stata: reg belong schrisk escs xescs feelsafe if !missing(teachsup)) by(cnt) outfile(pisa22vol2_type11_med3_belong_schrisk, replace) pisacoverage flag
* Step3: Relationship between predictor and outcome controlling for SESs and both predictors (using same samples so exclude missings)
repest PISA, estimate (stata: reg belong schrisk escs xescs feelsafe teachsup) 			   by(cnt) outfile(pisa22vol2_type11_med4_belong_schrisk, replace) pisacoverage flag

** Table II.B1.3.30

See table II.B1.1.1 Variables: bullied, nfreqbullied9, st038all st038

** Table II.B1.3.31

See table II.B1.1.2 Variables: st038all

** Table II.B1.3.32

See table II.B1.1.3 Variables: st038all

** Table II.B1.3.33

See trend folder

** Table II.B1.3.34

See table II.B1.1.8 Variables: bullied, d_st038all

** Table II.B1.3.35

See table II.B1.1.9 Variables: bullied, xd_st038all

** Table II.B1.3.36

See table II.B1.3.7 variables: bullied

** Table II.B1.3.37

See table II.B1.1.1 Variables: skipping st062q01 st062q02

** Table II.B1.3.38

See table II.B1.1.2 Variables: d_st062q01

** Table II.B1.3.39

See table II.B1.1.3 Variables: d_st062q01

** Table II.B1.3.40

See table II.B1.1.1 Variables: st062q03 tardysd

** Table II.B1.3.41

See table II.B1.1.2 Variables: d_st062q03

** Table II.B1.3.42

See table II.B1.1.3 Variables: d_st062q03

** Table II.B1.3.43

See Trend tables

** Table II.B1.3.44

See table II.B1.1.8 Variables: skipping d_st062q01 d_st062q02

** Table II.B1.3.45

See table II.B1.1.9 Variables: skipping xd_st062q01 xd_st062q02

** Table II.B1.3.46

See table II.B1.1.8 Variables: d_st062q03

** Table II.B1.3.47

See table II.B1.1.8 Variables: st062

** Table II.B1.3.48

See table II.B1.1.9 Variables: xd_st062q03 

** Table II.B1.3.49

See table II.B1.1.1 Variables: misssc st260

** Table II.B1.3.50

See table II.B1.1.2 Variables: misssc

** Table II.B1.3.51

See table II.B1.1.3 Variables: misssc

** Table II.B1.3.52

See table II.B1.1.8 Variables: misssc d_st260

** Table II.B1.3.53

See table II.B1.1.9 Variables: misssc xd_st260

** Table II.B1.3.54

See table II.B1.1.8 Variables: st260

** Table II.B1.3.55

See table II.B1.1.1 Variables: st261

** Table II.B1.3.56

See table II.B1.1.2 Variables:d_st261q01

** Table II.B1.3.57

See table II.B1.1.3 Variables:d_st261q01

** Table II.B1.3.58

See table II.B1.1.1 Variables: r_sc064

** Table II.B1.3.59

See table II.B1.1.2 Variables: d_sc064q05

** Table II.B1.3.60

See table II.B1.1.2 Variables: d_sc064q06

** Table II.B1.3.61

See table II.B1.1.2 Variables: d_sc064q01

** Table II.B1.3.62

See table II.B1.1.2 Variables: d_sc064q02

** Table II.B1.3.63

See table II.B1.1.3 Variables: d_sc064q05

** Table II.B1.3.64

See table II.B1.1.3 Variables: d_sc064q06

** Table II.B1.3.65

See table II.B1.1.3 Variables: d_sc064q01

** Table II.B1.3.66

See table II.B1.1.3 Variables: d_sc064q02

** Table II.B1.3.67

See Trend tables

** Table II.B1.3.68

See table II.B1.1.8 Variables: d_sc064

** Table II.B1.3.69

See table II.B1.1.1 Variables: famsup st300

** Table II.B1.3.70

See table II.B1.1.2 Variables: famsup 

** Table II.B1.3.71

See table II.B1.1.3 Variables: famsup 

** Table II.B1.3.72

See table II.B1.1.8 Variables: famsup 

** Table II.B1.3.73

See table II.B1.1.8 Variables: st300

** Table II.B1.3.74

See table II.B1.1.9 Variables: famsup xd_st300

** Table II.B1.3.75

See table II.B1.3.7 variables: famsup
