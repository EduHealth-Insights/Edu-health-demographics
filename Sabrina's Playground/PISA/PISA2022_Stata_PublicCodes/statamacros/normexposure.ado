* CALCULATE NORM_EXPOSURE (ISOLATION) INDEX FOR BINARY VARIABLES 


cap program drop normexposure
program normexposure, eclass
 
 
 syntax varlist(min = 3) [pweight]  [if] [in] [,flag]
 
//varlist: varstat: variable of interest ; varstud: student identifier; vargroup: variable of units 

gettoken varstat vartemp : varlist  
gettoken varstud vargroup : vartemp  


*missing values are excluded 
drop if missing(`varstat') 

tempname b  flags

matrix `b'=J(1,1,0) 
matrix colnames `b' = "Normex"
	
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
	
*** EXPOSURE INDEX ***

	* sub variables
	gen expos_base_sch = (tot1_sch/tot1_cnt )*(tot0_sch/totstu_sch)

*** NORMALIZED EXPOSURE INDEX ***

	* sub variables
	gen prop0_cnt = tot0_cnt/totstu_cnt  

	
collapse (mean) expos_base_sch prop0_cnt, by(`vargroup' )  
collapse (sum) expos_base_cnt=expos_base_sch (mean) prop0_cnt
	  
	
	* COUNTRY LEVEL  EXPOSURE INDEX VARIABLE
	gen expos_ind_`varstat' =expos_base_cnt
		
		
	* COUNTRY LEVEL NORMALIZED EXPOSURE INDEX VARIABLE
	gen norm_expos_ind_`varstat' =1-expos_ind_`varstat'/prop0_cnt
	 
mkmat norm_expos_ind_`varstat' expos_ind_`varstat' , matrix( `b')

matrix colnames `b' = "Norm_exposure" "Exposure" 
}
 	ereturn post `b' 
  
end



