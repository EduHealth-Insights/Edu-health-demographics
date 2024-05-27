*** PROGRAMME TO COMPUTE ANNUALISED CHANGE FROM A BETALOG
* A betalog is a file with 405 estimates per statistic (e.g. 81 weights * 5 plausible values)
* the betalog to estimate an annualised change must contain a "year" variable

*modified 27 May: to force independence of samples across years
*modified 22 august to account for new betalog (with numeric weight variable) lines 14-20

cap program drop pisa_ann_change
program define pisa_ann_change
	syntax , betalog(string) stats(namelist) outfile(string) [by(name) nbpv(integer 5)]
preserve
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
	keep `by' year pv `stats' rep
	reshape wide `stats', i(`by' year pv) j(rep)
	
	foreach stat in `stats' {
		forval i = 1/`nrep' {
			replace  `stat'`i' = `stat'0 if `stat'`i' == .
			}
		}	
	**
	tempfile all 
	save `all', replace

	foreach stat in `stats' {
		local outputstats "`outputstats' `stat'_annch_b `stat'_annch_se"
		}
	
	if "`by'" == "" {
		local byvar "by"
		local countries "_all"
		}
	else {
		local byvar "`by'"
		levelsof `by', l(countries)
		}
	tempname memhold
	postfile `memhold' str20 `byvar' double(`outputstats') using `outfile', replace

	foreach cnt in `countries' {
		if "`countries'" != "_all" use if `by' == "`cnt'" using `all', clear
		noi di as text "`cnt' :"
		local output ""
		foreach stat in `stats' {
				noi di as text "      reg `stat'`i' year"
*				use `all', clear
*				if "`by'" != "" keep if `by' == "`cnt'"
				tempname beta bvar b b_dev IMPV SV VCOV se
				matrix `beta' = J(1,5,.)
				matrix `bvar' = J(`nrep',5,.)

					forval pv = 1/`nbpv' {
						ereturn clear
						cap reg `stat'0 year if pv == `pv'
						if !_rc {
							matrix `beta'[1,`pv'] = _b[year]
							forval i = 1(1)`nrep' {
								qui reg `stat'`i' year if pv == `pv'
								matrix `bvar'[`i',`pv'] = _b[year]-`beta'[1,`pv']
								}
							}
						else if `pv' == 1 cap noisily reg `stat'0 year if pv == `pv'
						}
				matrix `b' = (`beta'*J(`nbpv',1,1/`nbpv')) 
				matrix `b_dev' = `beta'-J(1,`nbpv',`b'[1,1])

				matrix `IMPV' = (`b_dev' * `b_dev'') / (`nbpv' - 1)
				matrix `SV' = ((vecdiag(`bvar''*`bvar')/20)*J(`nbpv',1,1/`nbpv')) 

				matrix `VCOV' = `SV' + ((`nbpv' + 1)/`nbpv') * `IMPV'
				matrix list `b'

				scalar `se' = sqrt(`VCOV'[1,1])
			
				local output "`output' (`b'[1,1]) (`se')"
			}
		post `memhold' ("`cnt'") `output'
		}
	postclose `memhold'
	}
restore		

end
