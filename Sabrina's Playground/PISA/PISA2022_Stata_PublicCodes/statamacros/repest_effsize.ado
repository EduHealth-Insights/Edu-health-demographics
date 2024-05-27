* repest_effsize: Effect size calculated as the gap between the mean of 2 dependent variables, divided by the standard deviation of the mean of all students in the country.


cap program drop repest_effsize
program define repest_effsize, eclass
        syntax varlist (numeric) [if] [in] [aweight] , effect(varname numeric) [flag]

       foreach var in `varlist' {
			tempname `var'_sd `var'_b `var'_es `var'_f
			qui: su `var' [aw `exp'] `if' `in' 
			scalar ``var'_sd' = r(sd)
			cap: reg `var' `effect' [aw `exp'] `if' `in' 
			if _rc != 2000 {
				scalar ``var'_b' = _b[`effect']
				scalar ``var'_es' = ``var'_b'/``var'_sd'
				}
			else if _rc == 2000 {
				scalar ``var'_es' = .
				}
			else error _rc
				
			if "`stat_list'"=="" 	local lamf `"``var'_es'"'
			else 	local lamf `", ``var'_es'"'
													
			local stat_list   "`stat_list' `lamf'   "
			local name_list   "`name_list' `var'_es"  
			if "`flag'" !=""  {
					repest_flags `effect' if e(sample)==1, binarytest
					if "`flag_list'"=="" {
													local lamf `" `r(flag)'"'
															}
													else {
															local lamf `",  `r(flag)'"'
													}
													
					local flag_list   "`flag_list' `lamf'   "
					}       
	

			}
	
                
        // store stats
        tempname b flags
        matrix  `b' = [`stat_list']
        matrix colnames  `b' = `name_list'
        if "`flag'" !="" {
                matrix `flags'=[`flag_list']
                }
        matrix  `b' = r(beta)
        matrix colnames  `b' = `r(betanames)'
        ereturn post `b' 
        if "`flag'" !="" ereturn matrix flags=`flags'

end
