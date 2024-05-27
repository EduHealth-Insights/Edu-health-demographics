* CALCULATE MULTIGROUP ENTROPY INDEX  (NO DIVERSITY INDEX) 
* last change: 6/6/2019 - flag added (CM)

cap program drop calculentropy
program calculentropy, eclass
 
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
*** Number of students in each group  in each school and by country ***
		 
	collapse (count) tot`varstat'_sch=`varstud' [pw `exp'], by( `vargroup' `varstat')
	
	bysort `varstat': egen tot`varstat'_cnt=sum(tot`varstat'_sch)
	
	
	*** Number of students in each school (totstu_sch) and country (totstu_cnt) ***
	bysort `vargroup': egen totstu_sch=sum(tot`varstat'_sch)
	
	 
	egen totstu_cnt=sum(tot`varstat'_sch)
	
	

*** ENTROPY INDEX  ***
	
	* sub variables 
	/*for school it is weighted by the prop of students in the school*/ 
	gen comp_entropy_gr_sch=-totstu_sch/totstu_cnt *tot`varstat'_sch/ totstu_sch * ln((tot`varstat'_sch/ totstu_sch ))
	gen comp_entropy_gr_cnt=-1 * tot`varstat'_cnt/ totstu_cnt * ln((tot`varstat'_cnt/ totstu_cnt ))
	
 
	collapse (sum) entrop_base_sch=comp_entropy_gr_sch (mean) comp_entropy_gr_cnt totstu_cnt, by (`varstat')
	
	collapse (sum) entrop_base_cnt =entrop_base_sch (sum)  entrop_base_cnt_tot=comp_entropy_gr_cnt (mean)  totstu_cnt  

 
	* COUNTRY LEVEL ENTROPY INDEX VARIABLE

gen entrop_ind_`varstat' = 1-entrop_base_cnt/ entrop_base_cnt_tot

collapse (mean) entrop_ind_`varstat'  entrop_base_cnt_tot N=totstu_cnt  

mkmat entrop_ind_`varstat' entrop_base_cnt_tot N, matrix( `b')
 
matrix colnames `b' = "Entropy_Index"  "Entropy_tot" "Ntot"  
}

ereturn post `b' 
  
end


 
 
