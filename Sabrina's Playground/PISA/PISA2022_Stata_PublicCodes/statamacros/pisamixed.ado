// Variance decomposition (total, between and within variance, + ICC) with pisa-like data

// Francesco AVVISATI
// v1: 26 APR 2016

// modified on: 28 apr - add marksample to check sample not void
// modified on: 27 may - correct syntax for femodel (varlist syntax does not accept pv@)
// modified on: 17 oct 2017 - added option stddev 

cap program drop pisamixed
program define pisamixed, eclass
	syntax , femodel(string) wgt(varname)  [remodel(string) bweight(varname) by(string) options(string) VARiance stddev icc INCLusion keep(string) nbpv(integer 5) QUIetly outfile(string)]
	marksample touse
// complete model syntax with weights 

local model "`femodel' [pw = `wgt']"
if "`remodel'" != "" local model "`model' || `remodel', pweight(`bweight') pwscale(size)"
else local options ", `options'"
di "mixed `model' `options'"
// check if PVs in model
	local pv_here=regexm("`femodel' `remodel'","@") 
// build syntax for derived estimators
if "`variance'" != "" | "`stddev'" != "" | "`icc'" != "" | "`inclusion'" != "" {
	local derived ""
	if "`variance'" != "" local derived "`derived' (var_between: exp([lns1_1_1]_cons)^2 ) (var_within: exp([lnsig_e]_cons)^2)"
	if "`stddev'" != "" local derived "`derived' (sd_between: exp([lns1_1_1]_cons) ) (sd_within: exp([lnsig_e]_cons))"
	if "`icc'" != "" local derived "`derived' (icc: exp([lns1_1_1]_cons)^2 / ( exp([lnsig_e]_cons)^2 + exp([lns1_1_1]_cons)^2 ))"
	if "`inclusion'" != "" local derived "`derived' (inclusion: 100*(1- (exp([lns1_1_1]_cons)^2 / ( exp([lnsig_e]_cons)^2 + exp([lns1_1_1]_cons)^2 ))))"
	}
	
// determine by levels
	gettoken by_var by_options : by, parse(",")
	if regexm("`by_options'","levels\(([^\)]*)")   local by_levels=regexs(1)
	if "`by_levels'"=="" {
		if "`by'" != "" {
			levelsof `by_var', local(by_levels) 
			}
		else local by_levels  = "_pooled"
		}
	local by_levels : list clean by_levels // build esample database 


	
// build dataset
preserve 
	tempfile base_dataset by_level_dataset  results_bylevel results_all
	qui save `base_dataset'	
	
foreach by_level in `by_levels' {
	qui use `base_dataset',clear
	tempfile by_level_dataset results_bylevel 	
	if "`by_var'" != "" qui keep if `by_var' == "`by_level'" //by_var must be string
 	di as res "`by_level' " _c
	// check that obs > 0
	local check = "`femodel' `remodel'" 
	local check = subinstr("`check'",":","",.)
	local check = subinstr("`check'","@","1",.)
	local check = strtrim(stritrim("`check'"))
	local check = subinstr("`check'"," ",",",.)
	qui count if `touse' == 1 & missing(`check') == 0
	if r(N) != 0 {
		// if no PVs:
		if `pv_here' == 0 {
			* estimate model by country
			`quietly' mixed `model' `options'
			* add requested scalars to results
			if "`derived'" != "" {
				if "`keep'" != "" {
					local depvar = word("`femodel'",1)
					unab depvar: `depvar'
					unab keep: `keep'
					foreach coef in `keep' {
						local derived "`derived' (`coef': [`depvar']`coef')"
						}
					}
				`quietly' nlcom `derived', post
				}
			}
		// if  PVs:
		* estimate model by pv
		if `pv_here' == 1 {
			tempname b V
			local betas ""
			local vcovs ""
			forval ip = 1(1)`nbpv' {
				di "PV`ip' " _c
				tempname beta`i' VCOV`i'
				local model`ip' = subinstr("`model'","@","`ip'",.)
				`quietly' mixed `model`ip'' `options'
				* add requested scalars to results
				if "`derived'" != "" {
					local derived`ip' "`derived'"
					if "`keep'" != "" {
						local depvar = word("`femodel'",1)
						local depvar`ip' = subinstr("`depvar'","@","`ip'",.)
						local keep`ip' = subinstr("`keep'","@","`ip'",.)
						unab depvar`ip': `depvar`ip''
						unab keep`ip': `keep`ip''
						foreach coef`ip' in `keep`ip'' {
							local derived`ip' "`derived`ip'' (`coef`ip'': [`depvar`ip'']`coef`ip'')"
							}
						}
					
					`quietly' nlcom `derived`ip'', post
					}
				matrix `beta`i'' = e(b)
				matrix `VCOV`i'' = e(V)
				local betas "`betas' `beta`i''"
				local vcovs "`vcovs' `VCOV`i''"
				}
			pisamixed_PVvariance, nbpv(`nbpv') betas(`betas') vcovs(`vcovs')
			matrix `b' = r(beta)
			matrix `V' = r(VCOV)
			ereturn repost b=`b' V=`V'
			}	
			

		// in all cases:
		* build results database
		* save results to matrix
		tempname beta VCOV memhold_bylevel
		matrix `beta' = e(b)
		matrix `VCOV' = e(V)

		pisamixed_post_memhold_bylevel, vcov("`VCOV'") beta("`beta'") memname("`memhold_bylevel'") by_level(`by_level') tempdata("`results_bylevel'") colnames(`colnames') by_var(`by_var') 
		postclose `memhold_bylevel' 
		if	"`hasposted_ever'"=="1" {
			qui use `results_all', clear
			append using `results_bylevel'
			qui save `results_all',replace
			}
		else if "`hasposted_ever'"!="1" {
			qui use `results_bylevel', replace
			qui	save `results_all', replace
			local hasposted_ever=1
			}
		}
	else di as error "no observations" // if no observations
	di ""
	}
	if "`outfile'" != ""  {
		qui use `results_all', clear
 		qui save "`outfile'", replace
	}
di ""
restore
end


cap program drop pisamixed_PVvariance
program define pisamixed_PVvariance, rclass
	syntax , nbpv(integer) betas(string) vcovs(string) [, fast] 
	
	if (wordcount("`betas'") !=  wordcount("`vcovs'")) | wordcount("`betas'") != `nbpv' {
		error 197
		}
	tokenize `vcovs'
 
 	local sum_beta = subinstr(trim("`betas'"), " ", " + ", .)
 	local sum_vcov = subinstr(trim("`vcovs'"), " ", " + ", .)
 
	tempname b b_dev IMPV SV VCOV
	matrix `b' = (`sum_beta') / `nbpv'
	foreach beta in `betas' {
		local dev_beta = "`dev_beta'" + "(`b' - `beta')" + " \ "
		}
	local dev_beta = regexr("`dev_beta'", "\\.$" ,"")
	matrix `b_dev' = (`dev_beta')
	matrix `IMPV' = (`b_dev'' * `b_dev') / (`nbpv' - 1)
	if "`fast'" == "" matrix `SV' = (`sum_vcov') / `nbpv'
 	else matrix `SV' = `1' 
	matrix `VCOV' = `SV' + ((`nbpv' + 1)/`nbpv') * `IMPV'
 	return matrix beta = `b'
	return matrix VCOV = `VCOV'
end


cap program drop pisamixed_gen_memhold_bylevel	
program define pisamixed_gen_memhold_bylevel, rclass
	syntax, tempdata(string) memname(string) colnames(string) [by_var(string)  ]
	if "`by_var'" == "" local by_var "_pooled"
	local output_names ""
			foreach name in `colnames' {
				local lab=strtoname(abbrev("`name'",28)) //I have changed the limit here because of triple interactions
				local output_names  "`output_names' `lab'_b `lab'_se "
 				}
		qui postfile `memname' str20 `by_var' double(`output_names') using `tempdata', replace
	end	
	
cap program drop pisamixed_post_memhold_bylevel	
program define pisamixed_post_memhold_bylevel
	syntax, tempdata(string) memname(string) beta(string) vcov(string) by_level(string) [colnames(string) by_var(string) flag(string) pvalue eform]
	tempname se 
	mata: `se'= sqrt(diagonal(st_matrix("`vcov'")))
	mata: st_matrix("`se'",`se'') //we must transpose
	local output ""
	local nc = colsof(`beta')

	local b_names : colfullnames `beta'
	local colnames : subinstr local b_names ":"  "_", all

	forval i = 1/`nc' {
		local output "`output' (`beta'[1,`i']) (`se'[1,`i'])"
		}
		
	cap post `memname' ("`by_level'") `output'  
	if _rc!=0 {
		pisamixed_gen_memhold_bylevel , tempdata(`tempdata') memname(`memname') colnames(`colnames') by_var(`by_var') 
		post `memname' ("`by_level'") `output'  	
		}
 end

 
 
 /* note: if derived variables are included, pisamixed will replace the b/V matrices from mixed with those from nlcom
 the following lines are a draft to correct this.

 tempname b V
matrix `b' = e(b)
matrix `V' = e(V)

 
tempname bd Vd
matrix `bd' = e(b)
matrix `Vd' = e(V)
matrix `b' = [`b',`bd']
mata :	V = blockdiag(st_matrix("`V'"),st_matrix("`Vd'"))
mata: st_matrix("`V'",V)
matrix list `b'
matrix list `bd'
matrix list e(b)
set trace on
ereturn repost b=`b'
// V=`V'
set trace off
*/
