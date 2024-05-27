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
**		Volume II Chapter 5
**
********************************************************************************

** SC017
********************************************************************************

local variables "sc017q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 2 =0 "Not at all or very little") (3 4=1 "To some extent or a lot"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SC018
********************************************************************************
  
*Calculate total number of teachers: 
** r_fulltime; r_parttime: full-time and part-time teachers
** r_isced6; r_isced7; r_isced8: bachelor, masters and doctoral equivalent qualified teachers 


* ADD: Do the same for ISCED 6 - 8 level teachers * 

cap drop 	sc018q01ta01bis
gen 		sc018q01ta01bis =  sc018q01ta01
cap drop 	sc018q01ta02bis
gen 		sc018q01ta02bis =  sc018q01ta02
replace 	sc018q01ta01bis = 0 if missing(sc018q01ta01) & !missing(sc018q01ta02)
replace 	sc018q01ta02bis = 0 if missing(sc018q01ta02) & !missing(sc018q01ta01)

cap drop 	sc018q02ta01bis 
gen 		sc018q02ta01bis = sc018q02ta01
cap drop 	sc018q02ta02bis
gen 		sc018q02ta02bis = sc018q02ta02
replace 	sc018q02ta01bis = 0 if missing(sc018q02ta01) & !missing(sc018q02ta02)
replace 	sc018q02ta02bis = 0 if missing(sc018q02ta02) & !missing(sc018q02ta01)


cap drop 	sc018q08ja01bis
gen 		sc018q08ja01bis =  sc018q08ja01
cap drop 	sc018q08ja02bis
gen 		sc018q08ja02bis =  sc018q08ja02
replace 	sc018q08ja01bis = 0 if missing(sc018q08ja01) & !missing(sc018q08ja02)
replace 	sc018q08ja02bis = 0 if missing(sc018q08ja02) & !missing(sc018q08ja01)

cap drop 	sc018q09ja01bis 
gen 		sc018q09ja01bis = sc018q09ja01
cap drop 	sc018q09ja02bis
gen 		sc018q09ja02bis = sc018q09ja02
replace 	sc018q09ja01bis = 0 if missing(sc018q09ja01) & !missing(sc018q09ja02)
replace 	sc018q09ja02bis = 0 if missing(sc018q09ja02) & !missing(sc018q09ja01)


cap drop 	sc018q10ja01bis 
gen 		sc018q10ja01bis = sc018q10ja01
cap drop 	sc018q10ja02bis
gen 		sc018q10ja02bis = sc018q10ja02
replace 	sc018q10ja01bis = 0 if missing(sc018q10ja01) & !missing(sc018q10ja02)
replace 	sc018q10ja02bis = 0 if missing(sc018q10ja02) & !missing(sc018q10ja01)


replace		sc018q01ta01bis = . if totat==0 //error 1
replace		sc018q01ta02bis = . if totat==0

gen 		error2 = 1 if missing(sc018q01ta01) & !missing(sc018q02ta01) 
replace		sc018q02ta01bis=. if error2==1

	* Part-time/Full-time errors * 
gen			error3 = 1 if missing(sc018q01ta02bis) & !missing(sc018q02ta02bis) 
replace		sc018q02ta02bis = . if error3==1

gen			error4 = 1 if sc018q01ta02bis < sc018q02ta02bis & !missing(sc018q01ta02bis) & !missing(sc018q02ta02bis)  
replace 	sc018q02ta02bis = . if error4==1

	* ISCED 6 errors * 

gen			error5 = 1 if missing(sc018q08ja02bis) & !missing(sc018q08ja02bis) 
replace		sc018q08ja02bis = . if error5==1

gen			error6 = 1 if sc018q08ja02bis < sc018q08ja02bis & !missing(sc018q01ta02bis) & !missing(sc018q08ja02bis)  
replace 	sc018q08ja02bis = . if error6==1

	* ISCED 7 errors * 

gen			error7 = 1 if missing(sc018q09ja02bis) & !missing(sc018q09ja02bis) 
replace		sc018q09ja02bis = . if error7==1

gen			error8 = 1 if sc018q09ja02bis < sc018q09ja02bis & !missing(sc018q01ta02bis) & !missing(sc018q09ja02bis)  
replace 	sc018q09ja02bis = . if error8==1

	* ISCED 8 errors * 

gen			error9 = 1 if missing(sc018q10ja02bis) & !missing(sc018q10ja02bis) 
replace		sc018q10ja02bis = . if error9==1

gen			error10 = 1 if sc018q10ja02bis < sc018q10ja02bis & !missing(sc018q01ta02bis) & !missing(sc018q10ja02bis)  
replace 	sc018q02ta02bis = . if error10==1

cap drop	n_teachers 
gen			n_teachers = sc018q01ta01bis+(sc018q01ta02bis*.5) //XXX assumption that part-time is half-time? 
label var 	n_teachers "Total number of teachers"
sum 		n_teachers totat //almost identical

cap drop	r_fulltime 
gen 		r_fulltime = sc018q01ta01bis/n_teachers
replace		r_fulltime = r_fulltime*100
label var 	r_fulltime "Percentage of full-time teachers"
cap drop	r_parttime
gen 		r_parttime = (sc018q01ta02bis*.5)/n_teachers
replace		r_parttime = r_parttime*100
label var 	r_parttime "Percentage of part-time teachers"

** r_certified: fully certified teachers
cap drop 	n_certified
gen			n_certified = sc018q02ta01bis+(sc018q02ta02bis*.5)
label var 	n_certified "Number of certified teachers"

cap drop	r_certified
gen 		r_certified = n_certified/n_teachers
sum 		r_certified proatce //almost identical
replace		r_certified = r_certified*100
label var 	r_certified  "Percentage of fully certified teachers"

** r_isced6: bachelor equivalent qualified teachers 
cap drop 	n_isced6
gen			n_isced6 = sc018q08ja01bis+(sc018q08ja02bis*.5)
label var 	n_isced6 "Number of ISCED 6 qualified teachers"

cap drop	r_isced6
gen 		r_isced6 = n_isced6/n_teachers
replace		r_isced6 = r_isced6*100
label var 	r_isced6  "Percentage of ISCED 6 qualified teachers"


** r_isced7: master equivalent qualified teachers 
cap drop 	n_isced7
gen			n_isced7 = sc018q08ja01bis+(sc018q08ja02bis*.5)
label var 	n_isced7 "Number of ISCED 7 qualified teachers"

cap drop	r_isced7
gen 		r_isced7 = n_isced7/n_teachers
replace		r_isced7 = r_isced7*100
label var 	r_isced7  "Percentage of ISCED 7 qualified teachers"



** r_isced8: doctoral equivalent qualified teachers 
cap drop 	n_isced8
gen			n_isced8 = sc018q08ja01bis+(sc018q08ja02bis*.5)
label var 	n_isced8 "Number of ISCED 8 qualified teachers"

cap drop	r_isced8
gen 		r_isced8 = n_isced8/n_teachers
replace		r_isced8 = r_isced8*100
label var 	r_isced8  "Percentage of ISCED 8 qualified teachers"

* p20_r_fulltime p20_r_parttime p20_r_certified p20_r_isced*
local variables "r_fulltime r_parttime r_certified r_isced*"
foreach vr of varlist `variables' {
capture drop p20_`vr'
label define p20_`vr' 0 "Below 20%" 1 "At least 20%" 
gen	p20_`vr'=.
replace p20_`vr'= 1 if `vr'>=20 & !missing(`vr') 
replace p20_`vr'= 0 if `vr'<20 & !missing(`vr') 
label val p20_`vr' p20_`vr'
}

* p80_r_fulltime p80_r_certified 
local variables "r_fulltime"
foreach vr of varlist `variables' {
capture drop p80_`vr'
label define p80_`vr' 0 "Below 80%" 1 "At least 80%" 
gen	p80_`vr'=.
replace p80_`vr'= 1 if `vr'>=80 & !missing(`vr') 
replace p80_`vr'= 0 if `vr'<80 & !missing(`vr') 
label val p80_`vr' p80_`vr'
}


local variables "proatce"
foreach vr of varlist `variables' {
capture drop p80_`vr'
label define p80_`vr' 0 "Below 80%" 1 "At least 80%" 
gen	p80_`vr'=.
replace p80_`vr'= 1 if `vr'>=0.80 & !missing(`vr') 
replace p80_`vr'= 0 if `vr'<0.80 & !missing(`vr') 
label val p80_`vr' p80_`vr'
}

* recode proatce propat6 propat7 propat8 propmath : as there are prop > 1 

local variables "proatce propat6 propat7 propat8 propmath"
foreach vr of varlist `variables' {
replace `vr'= 1 if `vr'>1 & !missing(`vr') 
}


** SC002
********************************************************************************
  
*School size
gen 		n_boys = sc002q01ta
gen 		n_girls = sc002q02ta
replace 	n_boys = 0 if missing(sc002q01ta) & !missing(sc002q02ta)
replace 	n_girls= 0 if missing(sc002q02ta) & !missing(sc002q01ta)
gen 		schsize2 = n_boys + n_girls 
* replace schsize2 = schsize if cnt == "D359" // XXX Which country was it in PISA 2018 ? Austria  
sum 		schsize schsize2 //almost identical

** stratio2: Student-teacher ratio
recode 		n_teachers (0.5 = 1), gen(n_teachers2)
gen 		stratio2 = schsize2 / n_teachers2
replace 	stratio2 = 1 if stratio2 < 1
replace 	stratio2 = 100 if stratio2 > 100 & !missing(stratio2)  
sum 		stratio stratio2 //identical to stratio 

** smtratio: Student-mathematics teacher ratio
gen 		smtratio = schsize2 / (n_teachers2*propmath)
replace 	smtratio = 1 if smtratio < 1
replace 	smtratio = 100 if smtratio > 100 & !missing(smtratio)  

** SC004
********************************************************************************

** computeach: Number of computers with internet per teacher
capture 	drop computeach 
gen 		computeach = sc004q07na / totat
label 		var computeach "Number of computers with internet per teacher in school"

** white: Interactive whiteboards per student in the school
capture 	drop white
gen 		white = sc004q05na / schsize
label 		var white "Number of whiteboards per student in school"

** projector: Data projectors per student
capture 	drop projector
gen 		projector = sc004q06na / schsize
label 		var projector "Number of data projectors per student in school"
	
** SC190
********************************************************************************
	
local variables "sc190q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 =1 "Yes") (2=0 "No"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** IC179
********************************************************************************
			
	
local variables "ic179q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 2 =0 "Strongly disagree or disagree") (3 4=1 "Strongly agree or agree"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}		

** SC155
********************************************************************************
	
local variables "sc155q06* sc155q07* sc155q08* sc155q09* sc155q10*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 2 =0 "Strongly disagree or disagree") (3 4=1 "Strongly agree or agree"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

local variables "sc155q11*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 2 =1 "Strongly disagree or disagree") (3 4=0 "Strongly agree or agree"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}	
																																	

** ST059 & SC175
********************************************************************************															

* XXX demander confirmation de mettre en missing les heures trop importantes en maths (40 h?) et en tout (83h?)
 
 
recode sc175q01ja (0 = .) (121/10000 = .), gen (d_sc175q01ja)
recode sc175q02ja (0 = .) (121/10000 = .), gen (d_sc175q02ja)
 
cap drop  		mmins 
gen 			mmins = (st059q01ta * d_sc175q01ja) 
replace 		mmins = . if mmins>2400 & !missing(mmins)
label var 		mmins "Learning time per week in mathematics (in minutes)"
count if mmins>2400 & !missing(mmins) 			//If learning time per week in mathematics (MMINS) was greater than 2400 min(40 hours), it was replaced by missing

cap drop  		tmins 
gen 			tmins = (st059q02ja * d_sc175q02ja) 
replace 		tmins = . if tmins>5000 & !missing(tmins)
label var 		tmins "Learning time per week in all subjects (in minutes)"
count if tmins>5000 & !missing(tmins) 			//If learning time per week in all subjects  (TMINS) was greater than 5000 min(83 hours), it was replaced by missing
	
	
* Learning time in hours
foreach x in m t {
	cap drop  `x'hours
	gen `x'hours = `x'mins / 60
	}
label var 		mhours "Learning time per week in mathemathics (in hours)"
label var 		thours "Total learning time (in hours)"

** ST296
********************************************************************************	
local variables "st296q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=1  "Up to 30 minutes") (2=2 "More than 30 minutes and up to 1 hour") (3=3 "More than 1 hour and up to 2 hours") (4=4 "More than 2 hours and up to 3 hours") (5/6 =5 "More than three hours"), gen(d_`vr')
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

local variables "st296q*"
foreach vr of varlist `variables' {
	capture drop b_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=0 "Up to 2 hours") (4/6=1 "More than 2 hours"), gen(b_`vr')
	label val b_`vr' b_`vr' // Add value labels
	_crcslbl b_`vr' `vr' // Add the full variable label
}

local variables "st296q*"
foreach vr of varlist `variables' {
	capture drop binv_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=1 "Up to 2 hours") (4/6=0 "More than 2 hours"), gen(binv_`vr')
	label val binv_`vr' binv_`vr' // Add value labels
	_crcslbl binv_`vr' `vr' // Add the full variable label
}



** SC180 & SC181
********************************************************************************

cap drop sc181both
gen sc181both=.
replace sc181both=1 if sc181q01ja==1 & sc181q02ja==1
replace sc181both=0 if sc181q01ja==2 & sc181q02ja==2



local variables "sc181q* sc180q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 =1 "Yes") (2=0 "No"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** SC212
********************************************************************************


local variables "sc212q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 =1 "Yes") (2=0 "No"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** SC053
********************************************************************************
		
local variables "sc053q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (2=0 "No") (1=1 "Yes"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}

** ST326
********************************************************************************

** Digital time ** 

** Recoding PBA to CBA



replace st326q01ja = st326q07ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q07ja >= 1 & st326q07ja <=8)
replace st326q01ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q07ja >=9 & st326q07ja <=12)
replace st326q02ja = st326q08ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q08ja >= 1 & st326q08ja <=8)
replace st326q02ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q08ja >=9 & st326q08ja <=12)
replace st326q03ja = st326q09ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q09ja >= 1 & st326q09ja <=8)
replace st326q03ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q09ja >=9 & st326q09ja <=12)
replace st326q04ja = st326q10ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q10ja >= 1 & st326q10ja <=8)
replace st326q04ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q10ja >=9 & st326q10ja <=12)
replace st326q05ja = st326q11ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q11ja >= 1 & st326q11ja <=8)
replace st326q05ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q11ja >=9 & st326q11ja <=12)
replace st326q06ja = st326q12ja if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q12ja >= 1 & st326q12ja <=8)
replace st326q06ja = 9 if ((cnt == "C297" | cnt == "C428" | cnt == "C467" | cnt == "C526") & st326q12ja >=9 & st326q12ja <=12)

drop st326q12ja st326q11ja st326q10ja st326q09ja st326q08ja st326q07ja



local variables "st326q*"
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1=0  "None") (2=1 " Up to 1 hour") (3=2 "More than 1 hour and up to 2 hours") (4=3 "More than 2 hours and up to 3 hours") (5/6=4 "More than 3 hours and up to 5 hours") (7/8=5 "More than 5 hours and up to 7 hours") (9=6 "More than 7 hours"), gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}


** m_st326: categories converted into mins
local variables "st326q*"
foreach vr of varlist `variables' {
   capture drop m_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
   recode `vr' (1=0) (2=30) (3=90) (4=150) (5=210) (6=270) (7=330) (8=390) (9=450), gen(m_`vr' )
   label val m_`vr' m_`vr' // Add value labels
   _crcslbl m_`vr' `vr' // Add the full variable label
}

** h_st326: mins converted into hours
local variables "st326q*"
foreach vr of varlist `variables' {
   cap drop  h_`vr'
   gen h_`vr' = m_`vr' / 60
   label val h_`vr' h_`vr' // Add value labels
   _crcslbl h_`vr' `vr' // Add the full variable label
   }


** ST322
********************************************************************************
	
local variables "st322q*" //4 categories d_st322
foreach vr of varlist `variables' {
	capture drop d_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (6=0 "Not applicable") (1 =1 "Never or almost never") (2 3 4 =2 "Less than half of the time/About half of the time/More than half of the time") (5 =3 "All or almost all of the time") , gen(d_`vr' )
	label val d_`vr' d_`vr' // Add value labels
	_crcslbl d_`vr' `vr' // Add the full variable label
}



local variables "st322q*" //dummy  b_st322
foreach vr of varlist `variables' {
	capture drop b_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1 6 =0 "Never or almost never/Not Applicable") (2/5 =1 "Less than half of the time/About half of the time/Not Applicable/More than half of the time/All or almost all of the time"), gen(b_`vr' )
	label val b_`vr' b_`vr' // Add value labels
	_crcslbl b_`vr' `vr' // Add the full variable label
}


** ratcmp2
********************************************************************************
gen r_ratcmp2=ratcmp2*100
replace 	r_ratcmp2 = 100 if r_ratcmp2 > 100 & !missing(r_ratcmp2) 
** r_studyhmw
********************************************************************************
capture drop r_studyhmw
gen r_studyhmw=studyhmw

**st296
******************************************************************************** 
** m_st296: categories converted into mins
local variables "st296q*"
foreach vr of varlist `variables' {
   capture drop m_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
   recode `vr' (1=15) (2=45) (3=90) (4=150) (5=210) (6=270), gen(m_`vr' )
   label val m_`vr' m_`vr' // Add value labels
   _crcslbl m_`vr' `vr' // Add the full variable label
}

** h_st296: mins converted into hours
local variables "st296q*"
foreach vr of varlist `variables' {
   cap drop  h_`vr'
   gen h_`vr' = m_`vr' / 60
   label val h_`vr' h_`vr' // Add value labels
   _crcslbl h_`vr' `vr' // Add the full variable label
   }

** New non-teaching staff rati
******************************************************************************** 

gen allstaff = totat + totstaff 

gen propteach = (totat/allstaff)*100
gen propstaff = (totstaff/allstaff)*100

gen stustaff_ratio = schsize/allstaff 
gen stuntstaff_ratio = schsize/totstaff 

** ST273 recoded 
********************************************************************************

local variables "st273q*"
foreach vr of varlist `variables' {
	capture drop d2_`vr' // Drop the new variables which are going to be used for recoding, as Stata is not able to rewrite variables
	recode `vr' (1/3=1 " Some lessons/Most lessons/Every lesson") (4=0 "Never or almost never"), gen(d2_`vr' ) // For the sake of getting proper results, recode all the missing values to .
	label val d2_`vr' d2_`vr' // Add value labels
	_crcslbl d2_`vr' `vr' // Add the full variable label
}


*********************************
* Time spent on digital devices * 
*********************************


** From h_st326, calculate the weekly time spent on digital resources with the assumption that 
* there are 5 schools days per week and 2 days of week-ends. 
   
egen h_st326_learning_school_day = rowtotal(h_st326q01ja  h_st326q02ja ), missing 
gen h_st326_learning_school_day_week = h_st326_learning_school_day*5 
gen h_st326_learning_weekend_week  =    h_st326q03ja * 2 
egen h_st326_learning_week = rowtotal(h_st326_learning_school_day_week h_st326_learning_weekend_week), missing


egen h_st326_leisure_school_day = rowtotal(h_st326q04ja  h_st326q05ja ), missing 
gen h_st326_leisure_school_day_week = h_st326_leisure_school_day*5 
gen h_st326_leisure_weekend_week  =    h_st326q06ja * 2 
egen h_st326_leisure_week = rowtotal(h_st326_leisure_school_day_week h_st326_leisure_weekend_week), missing


egen h_st326_tot_week = rowtotal(h_st326_learning_week  h_st326_leisure_week), missing 



*********************************
* Time spent on regular lessons * 
*********************************

cap drop thours6
gen thours6 = thours
replace thours6 = 1 if thours<=20
replace thours6 = 2 if thours>20 & thours<=24
replace thours6 = 3 if thours>24 & thours<=27
replace thours6 = 4 if thours>27 & thours<=32
replace thours6 = 5 if thours>32 & thours<=39
replace thours6 = 6 if thours>39 & !missing(thours)
label define 	hours6 1 "20 hours or less" 2 "Between 20 and less than 24 hours" /*
				*/ 3 "Between 24 and less than 27 hours" 4 "Between 27 and less than 32 hours" /*
				*/5 "Between 32 and less than 39 hours" 6 "39 hours or more"
label values 	thours6 hours6
label var 		thours6 "Total learning per week time (6 categories)"


*********************************
* Time spent on mathematics lessons * 
*********************************

**  mhours6
	//colapsing response categories to 6
foreach x in  mhours   {
	cap drop `x'6
	gen `x'6 = `x'
	forvalues i = 1/6 {
		replace `x'6 = `i' if `x'>(`i'-1) & `x'<=`i'
		replace `x'6 = 1 if `x'==0
		replace `x'6 = 6 if `x'>6 & !missing(`x')
		}

*label define 	lb`x' 1 "1 hour or less" 2 "2 hours or less (but more than 1)" /*
				*/ 3 "3 hours or less (but more than 2)" 4 "4 hours or less (but more than 3)" /*
				*/5 "5 hours or less (but more than 4)" 6 "More than 5 hours"
label values 	`x' lb`x'
}
label var 		mhours6 "Learning time per week in math (6 categories)"

*
**lhours0
	//creating dummy for 0 hours of language
gen 			mhours0 = .
replace			mhours0 = 1 if mmins==0
replace			mhours0 = 0 if mmins>0 & !missing(mmins)
label var		mhours0 "Does not have classes of mathematics"


** mhours6_32/43/54/65
	//creating dummies to compute differences between hour categories
foreach x in  mhours  thours {
	recode `x'6 (3/6=.), gen(`x'6_21)
	recode `x'6 (1 4 5 6=.), gen(`x'6_32)
	recode `x'6 (1 2 5 6=.), gen(`x'6_43)
	recode `x'6 (1 2 3 6=.), gen(`x'6_54)
	recode `x'6 (1/4=.), gen(`x'6_65)
}





*********************************************
* Time spent on homework (maths and overall)* 
*********************************************


**  d_st296q01ja d_st296q04ja 5_32/43/54
	//creating dummies to compute differences between hour categories
	
*gen st296q01ja5 = d_st296q01ja 
*gen st296q04ja5 = d_st296q04ja 

foreach x in  st296q01ja st296q04ja {
gen `x'5 = d_`x' 
	recode `x'5 (3/5=.), gen(`x'5_21)
	recode `x'5 (1 4 5 =.), gen(`x'5_32)
	recode `x'5 (1 2 5 =.), gen(`x'5_43)
	recode `x'5 (1/3=.), gen(`x'5_54)

}




************************************************************************************************
* Time spent on digital resources : at school learning, weekly learning, weekly leisure, total * 
************************************************************************************************

 * Total * 
 
cap drop h_st326_tot_wk7
gen h_st326_tot_wk7 = h_st326_tot_week
replace h_st326_tot_wk7 = 1 if h_st326_tot_week<=10
replace h_st326_tot_wk7 = 2 if h_st326_tot_week>10 & h_st326_tot_week<=20
replace h_st326_tot_wk7 = 3 if h_st326_tot_week>20 & h_st326_tot_week<=30
replace h_st326_tot_wk7 = 4 if h_st326_tot_week>30 & h_st326_tot_week<=40
replace h_st326_tot_wk7 = 5 if h_st326_tot_week>40 & h_st326_tot_week<=60
replace h_st326_tot_wk7 = 6 if h_st326_tot_week>60 & h_st326_tot_week<=80
replace h_st326_tot_wk7 = 7 if h_st326_tot_week>80 & !missing(h_st326_tot_week)

label define 	digihours7 1 "10 hours or less" 2 "Between 10 and less than 20 hours" /*
				*/ 3 "Between 20 and less than 30 hours" 4 "Between 30 and less than 40 hours" /*
				*/5 "Between 40 and less than 60 hours" 6  "Between 60 and less than 80 hours" 7 "80 hours or more"
label values 	h_st326_tot_wk7 digihours7
label var 		h_st326_tot_wk7 "Total learning per week time (7 categories)"


foreach x in  h_st326_tot_wk {
	recode `x'7 (3/7=.), gen(`x'7_21)
	recode `x'7 (1 4 5 6 7=.), gen(`x'7_32)
	recode `x'7 (1 2 5 6 7=.), gen(`x'7_43)
	recode `x'7 (1 2 3 6 7=.), gen(`x'7_54)
	recode `x'7 (1 2 3 4 7=.), gen(`x'7_65)
	recode `x'7 (1/5=.), gen(`x'7_76)
}

* Learning (by week) * 

cap drop h_st326_lear_wk6
gen h_st326_lear_wk6 = h_st326_learning_week
replace h_st326_lear_wk6 = 1 if h_st326_learning_week<=5
replace h_st326_lear_wk6 = 2 if h_st326_learning_week>5 & h_st326_learning_week<=10
replace h_st326_lear_wk6 = 3 if h_st326_learning_week>10 & h_st326_learning_week<=20
replace h_st326_lear_wk6 = 4 if h_st326_learning_week>20 & h_st326_learning_week<=40
replace h_st326_lear_wk6 = 5 if h_st326_learning_week>40 & h_st326_learning_week<=60
replace h_st326_lear_wk6 = 6 if h_st326_learning_week>60 & !missing(h_st326_learning_week)
label define 	digihours_learning6 1 "5 hours or less" 2 "Between 5 and less than 10 hours" /*
				*/ 3 "Between 10 and less than 20 hours" 4 "Between 20 and less than 40 hours" /*
				*/5 "Between 40 and less than 60 hours" 6 "60 hours or more"
label values 	h_st326_lear_wk6 digihours_learning6
label var 		h_st326_lear_wk6 "Total digital learning per week time (6 categories)"


* Leisure (by week) * 

cap drop h_st326_leis_wk6
gen h_st326_leis_wk6 = h_st326_leisure_week
replace h_st326_leis_wk6 = 1 if h_st326_leisure_week<=5
replace h_st326_leis_wk6 = 2 if h_st326_leisure_week>5 & h_st326_leisure_week<=10
replace h_st326_leis_wk6 = 3 if h_st326_leisure_week>10 & h_st326_leisure_week<=20
replace h_st326_leis_wk6 = 4 if h_st326_leisure_week>20 & h_st326_leisure_week<=40
replace h_st326_leis_wk6 = 5 if h_st326_leisure_week>40 & h_st326_leisure_week<=60
replace h_st326_leis_wk6 = 6 if h_st326_leisure_week>60 & !missing(h_st326_leisure_week)
label define 	digihours_leisure6 1 "5 hours or less" 2 "Between 5 and less than 10 hours" /*
				*/ 3 "Between 10 and less than 20 hours" 4 "Between 20 and less than 40 hours" /*
				*/5 "Between 40 and less than 60 hours" 6 "60 hours or more"
label values 	h_st326_leis_wk6 digihours_leisure6
label var 		h_st326_leis_wk6 "Total digital leisure per week time (6 categories)"


foreach x in  h_st326_leis_wk h_st326_lear_wk {
	recode `x'6 (3/6=.), gen(`x'6_21)
	recode `x'6 (1 4 5 6=.), gen(`x'6_32)
	recode `x'6 (1 2 5 6=.), gen(`x'6_43)
	recode `x'6 (1 2 3 6=.), gen(`x'6_54)
	recode `x'6 (1/4=.), gen(`x'6_65)
}




* Learning at school (by school day) : 7 categories, from 0 to 6 * 
foreach x in  st326q01ja  {
gen `x'6 = d_`x' 
	recode `x'6 (2/6=.), gen(`x'6_10)
	recode `x'6 (0 3 4 5 6 =.), gen(`x'6_21)
	recode `x'6 (0 1 4  5 6 =.), gen(`x'6_32)
	recode `x'6 (0 1 2 5 6 =.), gen(`x'6_43)
	recode `x'6 (0 1 2 3 6 =.), gen(`x'6_54)
	recode `x'6 (0/4=.), gen(`x'6_65)

}
