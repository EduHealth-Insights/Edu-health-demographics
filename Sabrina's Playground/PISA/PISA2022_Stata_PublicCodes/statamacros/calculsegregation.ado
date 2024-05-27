* CALCULATE SEGREGATION INDICES FOR BINARY VARIABLE, NORM_EXPOSURE (ISOLATION INDEX), ISOLATION, DISSIMILARITY, ENTROPY (NO DIVERSITY INDEX) 
* in repest the flag options should be introduced within the brackets, not outside
* last change: 4/3/2019


cap program drop calculsegregation
program calculsegregation, eclass
 
 
 syntax varlist(min = 3) [pweight]  [if] [in] [,flag]
 
//varlist: varstat: variable of interest ; varstud: student identifier; vargroup: variable of units 

gettoken varstat vartemp : varlist  
gettoken varstud vargroup : vartemp  


*missing values are excluded 
drop if missing(`varstat') 

tempname b  flags

matrix `b'=J(1,6,0) 
matrix colnames `b' = "Uneveness" "Exposure" "Norm_exposure" "Isolation" "Dissimilarity" "Entropy"
	
local flags=0 
if "`flag'"!=""{
			qui count  `if' 
			local nobs0 = r(N)
			cap tab `vargroup' `if', nofreq
			local ngrp0 = r(r)
			local flags=(`nobs0'<30 |`ngrp0'<5 )
			
		levelsof `varstat', local(varstatt)
 foreach x of local varstatt {
 preserve 
 keep if `varstat'==`x'
			qui count  `if'   
			local nobssupgr = r(N)
			local flags=max(`flags',(`nobssupgr'<30))
			display "`flag'"
	restore
			}
}
			
 if `flags'==0 {



	preserve
	
*** Number of students in each group  in each school and in country ***

	collapse (count) tot`varstat'_sch=`varstud' [pw `exp'], by( `vargroup' `varstat')
	
		
	*** Number of students in each school (totstu_sch) and country (totstu_cnt) ***
	bysort `vargroup': egen totstu_sch=sum(tot`varstat'_sch)
	
	egen totstu_cnt=sum(tot`varstat'_sch)
	 
		*** Number of students by group in each school  and country   ***
	 
	bysort `vargroup': egen tot1_sch=sum(tot`varstat'_sch*(`varstat'==1))  
	bysort `vargroup': egen tot0_sch=sum(tot`varstat'_sch*(`varstat'==0))  
	
	  egen tot1_cnt=sum(tot`varstat'_sch*(`varstat'==1))  
	  egen tot0_cnt=sum(tot`varstat'_sch*(`varstat'==0))  
	

*** UNEVENNES INDEX ***
	
	* sub variables  
	
	gen unev_base_sch = abs((tot1_sch/tot1_cnt) - (totstu_sch/totstu_cnt))

 
*** EXPOSURE INDEX ***

	* sub variables
	gen expos_base_sch = (tot1_sch/tot1_cnt )*(tot0_sch/totstu_sch)
 
*** NORMALIZED EXPOSURE INDEX ***

	* sub variables
	gen prop0_cnt = tot0_cnt/totstu_cnt  

*** ISOLATION INDEX  ***

	* sub variables
	gen iso_base_sch = (tot1_sch*tot1_sch)/(tot1_cnt*totstu_sch)  
	
*** DISSIMILARITY INDEX  ***
	
	* sub variables
	gen dissim_base_sch = abs((tot1_sch/tot1_cnt)-(tot0_sch/tot0_cnt)) 
 
*** ENTROPY INDEX  ***
	
	* sub variables
    gen entropy_base_sch=-totstu_sch/totstu_cnt *(min(0,tot1_sch/ totstu_sch * ln(tot1_sch/ totstu_sch))+min(0,tot0_sch/ totstu_sch * ln(tot0_sch/ totstu_sch )))
	gen entropy_cnt_tot=-tot1_cnt/ totstu_cnt * ln(tot1_cnt/ totstu_cnt )-tot0_cnt/ totstu_cnt * ln(tot0_cnt/ totstu_cnt )
	
	
collapse (mean) unev_base_sch expos_base_sch  iso_base_sch  dissim_base_sch  prop0_cnt  entropy_base_sch entropy_cnt_tot, by(`vargroup' )  
collapse (sum) unev_base_cnt=unev_base_sch  expos_base_cnt=expos_base_sch  iso_base_cnt=iso_base_sch dissim_base_cnt=dissim_base_sch  entropy_base_cnt=entropy_base_sch (mean) prop0_cnt entropy_cnt_tot
	  
	  
	* COUNTRY LEVEL UNEVENESS INDEX VARIABLE
	gen unev_ind_`varstat' = 0.5*unev_base_cnt
	
	* COUNTRY LEVEL ISOLATION INDEX VARIABLE
	gen iso_ind_`varstat' = iso_base_cnt
	
	* COUNTRY LEVEL  EXPOSURE INDEX VARIABLE
	gen expos_ind_`varstat' =expos_base_cnt
		
	* COUNTRY LEVEL NORMALIZED EXPOSURE INDEX VARIABLE
	gen norm_expos_ind_`varstat' =1-expos_ind_`varstat'/prop0_cnt
	 
	* COUNTRY LEVEL DISSIM INDEX VARIABLE
	gen dissim_ind_`varstat' = 0.5*dissim_base_cnt
	
	
	* COUNTRY LEVEL ENTROPY INDEX VARIABLE
	gen entropy_ind_`varstat' =  1-entropy_base_cnt/entropy_cnt_tot
	 
  
mkmat unev_ind_`varstat' expos_ind_`varstat' norm_expos_ind_`varstat' iso_ind_`varstat' dissim_ind_`varstat' entropy_ind_`varstat'   , matrix( `b')

matrix colnames `b' = "Uneveness" "Exposure" "Norm_exposure" "Isolation" "Dissimilarity" "Entropy"
}
 	ereturn post `b' 
  
end



