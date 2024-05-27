*** PROGRAMME TO COMPUTE ANNUALISED CHANGE FROM A BETALOG
* A betalog is a file with up to 810 estimates per statistic (e.g. 81 weights * `nbpv' plausible values)
* the betalog to estimate an annualised change must contain a "year" variable

*modified 27 May: to force independence of samples across years
*modified 22 august to account for new betalog (with numeric weight variable) lines 14-20

* modified 1/6/2023 to allow for over_levels and tests across over_levels.
* modified 12/7/2023 to include option fast (similar to the repest option fast, computes SV based only on 1st PV), clean memory, and log time.

cap program drop pisa_curv_change
program define pisa_curv_change
	syntax , betalog(string) stats(namelist) outfile(string) [by(varname) over_level test nbpv(integer 5) CURVilinear fast]
* preserve
qui {
	use `betalog', clear // file with all beta estimates from replicate weights and pvs
	cap confirm numeric variable weight 
	if _rc != 0 {
		replace weight = "w_fstr0" if weight == "w_fstuwt" 
		gen rep = real(regexr(weight,"w_fstr",""))
		drop weight
		}
	else rename weight rep
	qui su rep
	local nrep = r(max)
	** 27 may
	tempvar group
	egen `group' = group(wave)
	replace rep = rep+(`nrep'*(`group'-1)) if rep>0 // with 80 rep: values 1-80 for year 1, 81-160 for year2 ,etc
	qui su rep 
	local nrep = r(max)	
	keep `by' `over_level' year pv `stats' rep
	if "`test'" != "" {
		qui su over_level
		local max = r(max)
		local min = r(min)
		reshape wide `stats', i(`by' year pv rep) j(over_level)
		foreach stat in `stats' {
			gen `stat'd = `stat'`max' - `stat'`min'
			}
		reshape long `stats', i(`by' year pv rep) j(over_level) string
	}
	reshape wide `stats', i(`by' `over_level' year pv) j(rep)
	
	foreach stat in `stats' {
		forval i = 1/`nrep' {
			replace  `stat'`i' = `stat'0 if `stat'`i' == .
			}
		}	
	**
	tempfile all 
		if "`curvilinear'" == "curvilinear" {
			tempvar curv
			gen `curv' = year^2 
			}
	cap tostring over_level, replace
	save `all', replace

	foreach stat in `stats' {
		if "`curvilinear'" == "curvilinear" local outputstats "`outputstats' `stat'_line_b  `stat'_line_se `stat'_curv_b `stat'_curv_se"
		else local outputstats "`outputstats' `stat'_year_b `stat'_year_se"
		}
	
	if "`by'" == "" {
		local byvar "by"
		local countries "_all"
		}
	else {
		local byvar "`by'"
		levelsof `by', l(countries)
		}
	if "`over_level'" == "" {
		local over ""
		local over_levels "1"
		}
	else {
		local over "str3 over_level"
		levelsof over_level, l(over_levels)
		}
	clear
	tempname memhold
	postfile `memhold' str20 `byvar' `over' double(`outputstats') using `outfile', replace
*set trace on
	foreach cnt in `countries' {
	 foreach level in `over_levels' {
		if "`countries'" != "_all" & "`over'" == "" use if `by' == "`cnt'" using `all', clear
		if "`countries'" != "_all" & "`over'" != "" {
			use if `by' == "`cnt'" & over_level == "`level'" using `all', clear
			local outlevel ("`level'")
			}
		if "`countries'" == "_all" & "`over'" != "" {
			use if over_level == "`level'" using `all', clear
			local outlevel ("`level'")
			}
		noi di as text "`cnt' `level' :"
		local output ""
		foreach stat in `stats' {
				qui tic //timer on
				noi di as text "      reg `stat'`i' year `curv' " , _c
*				use `all', clear
*				if "`by'" != "" keep if `by' == "`cnt'"
				tempname beta bvar b b_dev IMPV SV VCOV se
				matrix `beta' = J(1,`nbpv',.)
				if "`fast'" != "fast"  matrix `bvar' = J(`nrep',`nbpv',.)
				else 				   matrix `bvar' = J(`nrep',1,.)
				if "`curvilinear'" == "curvilinear" {
					tempname ceta cvar c c_dev cIMPV cSV cVCOV cse
					matrix `ceta' = J(1,`nbpv',.)
					if "`fast'" != "fast"  matrix `cvar' = J(`nrep',`nbpv',.)
					else 				   matrix `cvar' = J(`nrep',1,.)
					}
					forval pv = 1/`nbpv' {
						ereturn clear
						cap reg `stat'0 year  `curv' if pv == `pv'
						if !_rc {
							matrix `beta'[1,`pv'] = _b[year]
							if "`curvilinear'" == "curvilinear" matrix `ceta'[1,`pv'] = _b[`curv']
							if "`fast'" != "fast" | `pv' == 1 {
								forval i = 1(1)`nrep' {
									qui reg `stat'`i' year `curv' if pv == `pv'
									matrix `bvar'[`i',`pv'] = _b[year]-`beta'[1,`pv']
									if "`curvilinear'" == "curvilinear" matrix `cvar'[`i',`pv'] = _b[`curv']-`ceta'[1,`pv']
									}
								}
							}
						else if `pv' == 1 cap noisily reg `stat'0 year `curv' if pv == `pv'
						}
				matrix `b' = (`beta'*J(`nbpv',1,1/`nbpv')) 
				matrix `b_dev' = `beta'-J(1,`nbpv',`b'[1,1])

				matrix `IMPV' = (`b_dev' * `b_dev'') / (`nbpv' - 1)
				if "`fast'" != "fast" matrix `SV' = ((vecdiag(`bvar''*`bvar')/20)*J(`nbpv',1,1/`nbpv')) 
				else 				  matrix `SV' = (vecdiag(`bvar''*`bvar')/20) 
				matrix `VCOV' = `SV' + ((`nbpv' + 1)/`nbpv') * `IMPV'
				matrix list `b'

				scalar `se' = sqrt(`VCOV'[1,1])
				if "`curvilinear'" == "curvilinear" {
					matrix `c' = (`ceta'*J(`nbpv',1,1/`nbpv')) 
					matrix `c_dev' = `ceta'-J(1,`nbpv',`c'[1,1])

					matrix `cIMPV' = (`c_dev' * `c_dev'') / (`nbpv' - 1)
					if "`fast'" != "fast" matrix `cSV' = ((vecdiag(`cvar''*`cvar')/20)*J(`nbpv',1,1/`nbpv')) 
					else 				  matrix `cSV' = (vecdiag(`cvar''*`cvar')/20) 

					matrix `cVCOV' = `cSV' + ((`nbpv' + 1)/`nbpv') * `cIMPV'
					matrix list `c'

					scalar `cse' = sqrt(`cVCOV'[1,1])
					local output "`output' (`b'[1,1]) (`se') (`c'[1,1]) (`cse')"
					}
				
				else local output "`output' (`b'[1,1]) (`se')"
				noi toc 
			}
		post `memhold' ("`cnt'") `outlevel' `output'
		}
	 }	
	postclose `memhold'
	}
*set trace off
*restore		

end
