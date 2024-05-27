* DECOMPOSE MULTIGROUP ENTROPY INDEX (NO DIVERSITY INDEX) USING A SUPERGROUP VARIABLE 
* requires calculentropy.ado 
* in repest the flag options should be introduced within the brackets, not outside
* last change: 4/3/2019



cap program drop segregationentropydecomp
program segregationentropydecomp, eclass
syntax varlist(max = 4)  [pweight  ]  [if] [in]  ,nbval(integer) [,flag]
 
//varstat: variable of interest ;  varstud: student identifier; vargroup: variable of units; vargroup: variable of units;varsupergroup: group of units  ;nbscalar: nbre of distinct values of vasupergroup (added because issue with repest otherwise) 
gettoken varstat vartemp : varlist 
gettoken varsupergroup vartemp2 : vartemp 
gettoken varstud vargroup : vartemp2 
 
tempname b  flags
local sizeb=3+`nbval'*4 
display "sizeb `sizeb'"
local flags=0 
if "`flag'"!=""{

			qui count  `if' 
			local nobs0 = r(N)
			cap tab `vargroup' `if', nofreq
			local ngrp0 = r(r)
			local flags=(`nobs0'<30 |`ngrp0'<5 )
matrix `b' =J(1,3,0)  
matrix colnames `b' = "Entropy_Index_tot" "CompBetGroupEntropy" "CompBetGroupEntropy_prop" 

			
		levelsof `varsupergroup', local(varsupergroupt)
 foreach x of local varsupergroupt {
 preserve 
 keep if `varsupergroup'==`x'
			qui count  `if'   
			local nobssupgr = r(N)
			cap tab `vargroup' `if', nofreq
			local ngrsupgr = r(r)
			local flags=max(`flags',(`nobssupgr'<30 |`ngrsupgr'<5 ))
			display `flags'
matrix b`x'=J(1,4,0) 
matrix colnames b`x' = "CompEntropy_Gr`x'" "CompEntropy_Gr`x'_prop" "Entropy_Gr`x'" "lambda_Gr`x'"  
matrix `b' =[`b',b`x'] 

			restore
			}
}
			
 if `flags'==1 { 
 matrix `b' =J(1,`sizeb',0)   
 }

  else {
//To obtain segregation level 
qui calculentropy `varstat' `varstud' `vargroup'  [pw `exp']
matrix b=e(b) 
matrix `b' =b[1,colnumb(b,"Entropy_Index")]  
matrix colnames `b' = "Entropy_Index_tot" 


//to check that we have enough non missing observations for the variable supergroup 
  mdesc `varsupergroup' 
 local nbmiss=r(percent)  
local sizeb2=2+`nbval'*4 

qui: distinct `varsupergroup' 
local ndist_c =r(ndistinct) 
if  (`nbmiss'==100 | `ndist_c'==1)  { //all missing observations in the country or only one type

matrix `b' =[`b',J(1,`sizeb2',0)]   
}
else { 

//To obtain  component of the decomposition induced by competition between supergroups  
 
	qui	calculentropy  `varstat' `varstud' `varsupergroup'  [pw `exp']
	matrix bg=e(b) 
		matrix TotalEntropy=bg[1,colnumb(bg,"Entropy_tot")]     
		matrix Ntot=bg[1,colnumb(bg,"Ntot")]   
		//It is provided only if the number of missing for the super group is below 10%
		if `nbmiss'  <10{   
		matrix bsch =bg[1,colnumb(bg,"Entropy_Index")]  
		matrix bschpct =bsch[1,1]/`b'[1,1]*100 
		} 
		else { 
		matrix bsch =J(1,1,0)  
		matrix bschpct =J(1,1,0) 
		} 
		matrix colnames bsch="CompBetGroupEntropy" 
		matrix colnames bschpct="CompBetGroupEntropy_prop" 
		matrix `b' =[`b',bsch,bschpct]   
//To obtain  components of the decomposition corresponding to all supergroups (segregation level within each supergroup)  

 levelsof `varsupergroup', local(varsupergroupt)
 foreach x of local varsupergroupt {
 preserve  
 
keep if  `varsupergroup'==`x'
//keep if cnt=`x' 
qui calculentropy `varstat' `varstud' `vargroup' [pw `exp']
matrix temp`x' =e(b) 
matrix Entropy`x' = temp`x'[1,colnumb(temp`x',"Entropy_Index")]
matrix TotalEntropy`x' = temp`x'[1,colnumb(temp`x',"Entropy_tot")]
matrix Ntot`x' = temp`x'[1,colnumb(temp`x',"Ntot")]
 
matrix lambda`x'=TotalEntropy`x'[1,1]/TotalEntropy[1,1]*Ntot`x'[1,1]/Ntot[1,1]
matrix comp`x'=lambda`x'*Entropy`x' 
matrix comp`x'_p=comp`x'[1,1]/`b'[1,1]*100
 
matrix b`x'=[comp`x',comp`x'_p,Entropy`x',lambda`x'] 
matrix colnames b`x' = "CompEntropy_Gr`x'" "CompEntropy_Gr`x'_prop" "Entropy_Gr`x'" "lambda_Gr`x'"  
matrix `b' =[`b',b`x'] 

restore 
}

 }	
}
 ereturn post `b' 
   
   end 

