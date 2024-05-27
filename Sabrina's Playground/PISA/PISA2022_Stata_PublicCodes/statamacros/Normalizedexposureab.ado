* CALCULATE NO INTERACTION INDEX FOR TWO BINARY GROUPS (NOT COMPLEMENTARY)  
* in repest the flag options should be introduced within the brackets, not outside
* last change: 4/3/2019

cap program drop Normalizedexposureab
program Normalizedexposureab, eclass
 
 
syntax varlist(min = 4) [pweight]  [if] [in]  [,flag]
 
//varlist: varstat: variable of interest ; varstud: student identifier; vargroup: variable of units 

gettoken varstat vartemp : varlist 
gettoken varstat2 vartemp2 : vartemp 
gettoken varstud vargroup : vartemp2  

tempname b  flags

matrix `b'=J(1,2,0) 
matrix colnames `b' = "Exposure " "Norm_exposure" 	

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
		cap tab `vargroup' `if', nofreq
			local ngrpgr = r(r)
		
		local flags=max(`flags',(`nobssupgr'<30|`ngrp0'<5 ))
			display "`flag'"
	restore
			}
			
		levelsof `varstat2', local(varstatt)
 foreach x of local varstatt {
 preserve 
 keep if `varstat'==`x'
		qui count  `if'   
			local nobssupgr = r(N)
		cap tab `vargroup' `if', nofreq
			local ngrpgr = r(r)
		
		local flags=max(`flags',(`nobssupgr'<30|`ngrp0'<5 ))
				display "`flag'"
	restore
			}
			
}
	
	
 if `flags'==0 {



*missing values are excluded 
drop if missing(`varstat') 

	preserve
	
*** Number of students in each group  in each school and in country ***

	collapse (count) tot`varstat'_sch=`varstud' (sum) tot`varstat2'_sch=`varstat2'  [pw `exp'], by( `vargroup' `varstat')
	
		
	*** Number of students in each school (totstu_sch) and country (totstu_cnt) ***
	bysort `vargroup': egen totstu_sch=sum(tot`varstat'_sch)
	
	 
	egen totstu_cnt=sum(tot`varstat'_sch)
	
	*** Number of students by group in each school  and country   ***
	 
	bysort `vargroup': egen tota_sch=sum(tot`varstat'_sch*(`varstat'==1))  
	bysort `vargroup': egen totb_sch=sum(tot`varstat2'_sch)  
	
	  egen tota_cnt=sum(tot`varstat'_sch*(`varstat'==1))  
	  egen totb_cnt=sum(tot`varstat2'_sch)  
	
 
*** EXPOSURE INDEX ***

	* sub variables
	gen expos_base_sch = (tota_sch/tota_cnt )*(totb_sch/totstu_sch)
 
*** NORMALIZED EXPOSURE INDEX ***

	* sub variables
	gen propb_cnt = totb_cnt/totstu_cnt  
	gen propa_cnt = tota_cnt/totstu_cnt  
	
collapse (mean)  expos_base_sch  propb_cnt  propa_cnt, by(`vargroup' )  
collapse (sum)  expos_base_cnt=expos_base_sch  (mean) propb_cnt propa_cnt
	  
	
	* COUNTRY LEVEL  EXPOSURE INDEX VARIABLE
	gen expos_ind_`varstat' =expos_base_cnt
		
	* COUNTRY LEVEL NORMALIZED EXPOSURE INDEX VARIABLE
	gen norm_exposab_ind_`varstat' =1-expos_ind_`varstat'*(propb_cnt+propa_cnt)/propb_cnt 
	 
	 
 tempname b 
mkmat expos_ind_`varstat' norm_exposab_ind_`varstat'  , matrix( `b')
 
matrix colnames `b' = "Exposure " "Norm_exposure" 	

}	

ereturn post `b' 
  
end



