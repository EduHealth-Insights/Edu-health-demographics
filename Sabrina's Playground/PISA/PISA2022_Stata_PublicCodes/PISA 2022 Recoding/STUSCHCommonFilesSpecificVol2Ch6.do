********************************************************************************
**																			  **
** STU_CommonFiles: Program to create common variables for STU Dataset		  **
**					Specific Vol 2											  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD												  	  **
** Last Modification: 31/12/2023											  **
**																			  **
********************************************************************************

********************************************************************************
**																			 
**		Volume II Chapter 6
**
********************************************************************************

** SC035
********************************************************************************
local variables "sc035q*a"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}																			
		
local variables "sc035q*b"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}						

** SC034
********************************************************************************

local variables "sc034q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 =0 "Never") (2 3 =1 "At least once a year") (4 5 =2 "At least once a month"), gen(d_`vr' )  // XX: ou bien faire : "At least once a month" inclu dans "At least once a year ? "
		label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}		

recode sc034q01na 1=0 2/5=1, gen (dbis_sc034q01)
recode sc034q02na 1=0 2/5=1, gen (dbis_sc034q02)
recode sc034q03ta 1/3=0 4/5=1, gen (dbis_sc034q03)
recode sc034q04ta 1/3=0 4/5=1, gen (dbis_sc034q04)



** SC198
********************************************************************************			


local variables "sc198q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}				
 

** SC037
********************************************************************************	

local variables "sc037q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3=0 "No") (1/2=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}	
	
	
* Recoding for teacher mentoring
recode sc037q08ta (2 = .) (.i .m =.) (3 = 0), gen(part1mentoring)
recode sc037q08ta (1 = .) (2 = 1) (.i .m =.) (3 = 0), gen(part2mentoring)


** SC032
********************************************************************************	

local variables "sc032q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC011
********************************************************************************	

local variables "sc011q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (3=0 "There are no other schools in this area ") (1/2=1 "There is at least one other schools in this area "), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC200
********************************************************************************	

local variables "sc200q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (3=. ) (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** PA006
********************************************************************************	

local variables "pa006q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "Not important/somewhat important") (3/4=1 "Important/Very important"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC201
********************************************************************************	

local variables "sc201q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "From never to about twice a year") (3/5=1 "From once a month to everyday"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SC193
********************************************************************************	

local variables "sc193q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/2=0 "No impact/Small impact") (3/4=1 "Moderate impact/Large impact"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SCHLTYPE
********************************************************************************
** recode shltype for tables 2sc and 4st

recode schltype (3=1) (1/2 =0), gen(schltype_pub)
recode schltype (2=1) (1 3 =0), gen(schltype_govdep)
recode schltype (1=1) (2/3 =0), gen(schltype_priv)
recode schltype (3=1) (2 = 2) (1 = .), gen(schltype_govdep4st)
recode schltype (3=1) (1 = 2) (2 = .), gen(schltype_priv4st)
recode schltype (3=1) (1/2 = 2), gen(schltype_allpriv4st)

* killing countries with 0 cases
recode schltype_priv4st (1 = .), gen(test1)
egen test1c = sum(test1), by (cnt)
replace schltype_priv4st = . if test1c == 0

recode schltype_govdep4st (1 = .), gen(test2)
egen test2c = sum(test2), by (cnt)
replace schltype_govdep4st = . if test2c == 0

drop test1* test2*

** sc011reg
********************************************************************************

gen sc011reg=sc011q01ta
recode sc011reg (3=1) (1=3)


   
   * School autonomy
********************************************************************************

** Low and High autonomy school
* first step: is to make schauto 'continuous' and calculate quartiles
capture drop country
encode cnt, gen(country) 
tab country, m		
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace schauto=. if schauto==.m | schauto==.i | schauto==.v | schauto==.n
capture drop schauto_cont
gen double schauto_cont = schauto + e10
sum schauto_cont
capture drop schauto_p25
capture drop schauto_p75
gen double schauto_p25=.
gen double schauto_p75=.

levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile schauto_cont if country==`k' [aw=w_fstuwt], p(25 75)
	qui replace schauto_p25=r(r1) if country==`k'
	qui replace schauto_p75=r(r2) if country==`k'
	}
*
	
* second step: generate the new variables exploiting the quartiles
capture drop low_schauto
capture drop med_schauto
capture drop high_schauto
capture drop lowhighschauto

* Genereate schools with low auto
gen 		low_schauto =.
replace 	low_schauto=0 if schauto_cont>schauto_p25 & schauto_cont!=.
replace 	low_schauto=1 if schauto_cont<=schauto_p25 & schauto_cont!=.
label var low_schauto "Bottom quarter school autonomy"
label define schauto_low 0 "Not low autonomy" 1 "Low autonomy"
label value low_schauto schauto_low

* Generate schools with medium auto
gen 		med_schauto =.
replace 	med_schauto=0 if (schauto_cont<=schauto_p25 | schauto_cont>schauto_p75) & schauto_cont!=.
replace 	med_schauto=1 if schauto_cont>schauto_p25 & schauto_cont<=schauto_p75 & schauto_cont!=.
label var med_schauto "Medium school autonomy"
label define schauto_med 0 "Not medium autonomy" 1 "Medium autonomy"
label value med_schauto schauto_med 

* Generate schools with high auto	
gen 		high_schauto =. 
replace 	high_schauto=0 if schauto_cont<=schauto_p75 & schauto_cont!=.
replace 	high_schauto=1 if schauto_cont>schauto_p75 & schauto_cont!=.
label var high_schauto "Top quarter school auto"
label define schauto_high 0 "Not high autonomy" 1 "High autonomy"
label value high_schauto schauto_high

* Generate a variable: schools with low and high auto 	
gen lowhighschauto=. 
replace lowhighschauto=0 	if  low_schauto==1 & low_schauto!=. 
replace lowhighschauto=1	if  high_schauto==1 & high_schauto!=. 
label var lowhighschauto "Top/bottom quarter school auto"
label define lhschauto 0 "Low autonomy" 1 "High autonomy"
label value lowhighschauto lhschauto

tab lowhighschauto, m
tab high_schauto, m
tab low_schauto, m


* School srespcur
********************************************************************************

** Low and High srespcurschool
* first step: is to make srespcur 'continuous' and calculate quartiles
capture drop country
encode cnt, gen(country) 	
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace srespcur=. if srespcur==.m | srespcur==.i | srespcur==.v | srespcur==.n
capture drop srespcur_cont
gen double srespcur_cont = srespcur + e10
sum srespcur_cont
capture drop srespcur_p25
capture drop srespcur_p75
gen double srespcur_p25=.
gen double srespcur_p75=.

levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile srespcur_cont if country==`k' [aw=w_fstuwt], p(25 75)
	qui replace srespcur_p25=r(r1) if country==`k'
	qui replace srespcur_p75=r(r2) if country==`k'
	}
*
	
* second step: generate the new variables exploiting the quartiles
capture drop low_srespcur
capture drop med_srespcur
capture drop high_srespcur
capture drop lowhighsrespcur

* Genereate schools with low srespcur
gen 		low_srespcur =.
replace 	low_srespcur=0 if srespcur_cont>srespcur_p25 & srespcur_cont!=.
replace 	low_srespcur=1 if srespcur_cont<=srespcur_p25 & srespcur_cont!=.
label var low_srespcur "Bottom quarter school srespcur"
label define srespcur_low 0 "Not low srespcur" 1 "Low srespcur"
label value low_srespcur srespcur_low

* Generate schools with medium srespcur
gen 		med_srespcur =.
replace 	med_srespcur=0 if (srespcur_cont<=srespcur_p25 | srespcur_cont>srespcur_p75) & srespcur_cont!=.
replace 	med_srespcur=1 if srespcur_cont>srespcur_p25 & srespcur_cont<=srespcur_p75 & srespcur_cont!=.
label var med_srespcur "Medium school srespcur"
label define srespcur_med 0 "Not medium srespcur" 1 "Medium srespcur"
label value med_srespcur srespcur_med 

* Generate schools with high srespcur	
gen 		high_srespcur =. 
replace 	high_srespcur=0 if srespcur_cont<=srespcur_p75 & srespcur_cont!=.
replace 	high_srespcur=1 if srespcur_cont>srespcur_p75 & srespcur_cont!=.
label var high_srespcur "Top quarter school srespcur"
label define srespcur_high 0 "Not high srespcur" 1 "High srespcur"
label value high_srespcur srespcur_high

* Generate a variable: schools with low and high srespcur 	
gen lowhighsrespcur=. 
replace lowhighsrespcur=0 	if  low_srespcur==1 & low_srespcur!=. 
replace lowhighsrespcur=1	if  high_srespcur==1 & high_srespcur!=. 
label var lowhighsrespcur "Top/bottom quarter school srespcur"
label define lhsrespcur 0 "Low srespcur" 1 "High srespcur"
label value lowhighsrespcur lhsrespcur



** Low and High srespres
* first step: is to make srespres 'continuous' and calculate quartiles
capture drop country
encode cnt, gen(country) 	
set seed 1842
capture drop e10
gen double e10=uniform()/1000000000
replace srespres=. if srespres==.m | srespres==.i | srespres==.v | srespres==.n
capture drop srespres_cont
gen double srespres_cont = srespres + e10
sum srespres_cont
capture drop srespres_p25
capture drop srespres_p75
gen double srespres_p25=.
gen double srespres_p75=.

levelsof country, local(countries) 
foreach k of local countries {
	di `k'
	_pctile srespres_cont if country==`k' [aw=w_fstuwt], p(25 75)
	qui replace srespres_p25=r(r1) if country==`k'
	qui replace srespres_p75=r(r2) if country==`k'
	}
*
	
* second step: generate the new variables exploiting the quartiles
capture drop low_srespres
capture drop med_srespres
capture drop high_srespres
capture drop lowhighsrespres

* Genereate schools with low srespres
gen 		low_srespres =.
replace 	low_srespres=0 if srespres_cont>srespres_p25 & srespres_cont!=.
replace 	low_srespres=1 if srespres_cont<=srespres_p25 & srespres_cont!=.
label var low_srespres "Bottom quarter school srespres"
label define srespres_low 0 "Not low srespres" 1 "Low srespres"
label value low_srespres srespres_low

* Generate schools with medium srespres
gen 		med_srespres =.
replace 	med_srespres=0 if (srespres_cont<=srespres_p25 | srespres_cont>srespres_p75) & srespres_cont!=.
replace 	med_srespres=1 if srespres_cont>srespres_p25 & srespres_cont<=srespres_p75 & srespres_cont!=.
label var med_srespres "Medium school srespres"
label define srespres_med 0 "Not medium srespres" 1 "Medium srespres"
label value med_srespres srespres_med 

* Generate schools with high srespres	
gen 		high_srespres =. 
replace 	high_srespres=0 if srespres_cont<=srespres_p75 & srespres_cont!=.
replace 	high_srespres=1 if srespres_cont>srespres_p75 & srespres_cont!=.
label var high_srespres "Top quarter school srespres"
label define srespres_high 0 "Not high srespres" 1 "High srespres"
label value high_srespres srespres_high

* Generate a variable: schools with low and high srespres 	
gen lowhighsrespres=. 
replace lowhighsrespres=0 	if  low_srespres==1 & low_srespres!=. 
replace lowhighsrespres=1	if  high_srespres==1 & high_srespres!=. 
label var lowhighsrespres "Top/bottom quarter school srespres"
label define lhsrespres 0 "Low srespres" 1 "High srespres"
label value lowhighsrespres lhsrespres
