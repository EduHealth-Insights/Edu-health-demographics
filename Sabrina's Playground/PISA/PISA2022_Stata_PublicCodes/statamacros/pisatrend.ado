*** PISATREND  
* created 21 May 2014


cap program drop pisatrend
program define pisatrend
	syntax  , table(string) first(integer) last(integer) [linkerror(string) scale(string) linkerrortable(string) keep]
	
	preserve
	local trend = substr("`first'",3,2) + substr("`last'",3,2)
	foreach cycle in `first' `last' {
		confirm file `table'_`cycle'.dta
		}	
	qui {
		use `table'_`last', clear
		gen cycle = `last'
		append using `table'_`first', gen(temp)
		replace cycle = `first' if temp == 1
		drop temp
		ren * T_*
		cap ren _* T__*
		ren T_cnt cnt
		ren T_cycle cycle
		sort cnt cycle
		reshape wide T_*, i(cnt) j(cycle)
		**************
		* link error *
		**************
		foreach c1 in `first' {
			foreach c2 in  `last' {
			if `c2' > `c1' {
				*******************
				* Load link error *
				*******************
	if  "`scale'" == "math" {
						if   `c1' == 2003 & `c2' == 2006 local lerr = 1.35
						else if `c1' == 2003 & `c2' == 2009 local lerr = 1.99
						else if `c1' == 2003 & `c2' == 2012 local lerr = 1.931
						else if `c1' == 2003 & `c2' == 2015 local lerr = 5.6080 
						else if `c1' == 2003 & `c2' == 2018 local lerr = 2.80 	// Updated 06/09/2019
						else if `c1' == 2006 & `c2' == 2009 local lerr = 1.333
						else if `c1' == 2006 & `c2' == 2012 local lerr = 2.084
						else if `c1' == 2006 & `c2' == 2015 local lerr = 3.5111 
						else if `c1' == 2006 & `c2' == 2018 local lerr = 3.18	// Updated 06/09/2019
						else if `c1' == 2009 & `c2' == 2012 local lerr = 2.294
						else if `c1' == 2009 & `c2' == 2015 local lerr = 3.7853 
						else if `c1' == 2009 & `c2' == 2018 local lerr = 3.54	// Updated 06/09/2019
						else if `c1' == 2012 & `c2' == 2015 local lerr = 3.5462 
						else if `c1' == 2012 & `c2' == 2018 local lerr = 3.34	// Updated 06/09/2019
						else if `c1' == 2015 & `c2' == 2018 local lerr = 2.33	// Updated 06/09/2019

						else if `c1' == 2003 & `c2' == 2022 local lerr = 5.54 	// Updated 01/09/2023
						else if `c1' == 2006 & `c2' == 2022 local lerr = 4.09 	// Updated 01/09/2023
						else if `c1' == 2009 & `c2' == 2022 local lerr = 4.28 	// Updated 01/09/2023
						else if `c1' == 2012 & `c2' == 2022 local lerr = 3.58 	// Updated 01/09/2023
						else if `c1' == 2015 & `c2' == 2022 local lerr = 2.74 	// Updated 01/09/2023
						else if `c1' == 2018 & `c2' == 2022 local lerr = 2.24 	// Updated 01/09/2023
						else di "no link error available"
						}
					else if  "`scale'" == "read" {
						if `c1' == 2000 & `c2' == 2003 local lerr = 5.321
						else if `c1' == 2000 & `c2' == 2006 local lerr = 4.963
						else if `c1' == 2000 & `c2' == 2009 local lerr = 4.937
						else if `c1' == 2000 & `c2' == 2012 local lerr = 5.923
						else if `c1' == 2000 & `c2' == 2015 local lerr = 6.8044
						else if `c1' == 2000 & `c2' == 2018 local lerr = 4.04	// Updated 06/09/2019
						else if `c1' == 2003 & `c2' == 2006 local lerr = 4.48
						else if `c1' == 2003 & `c2' == 2009 local lerr = 4.088
						else if `c1' == 2003 & `c2' == 2012 local lerr = 5.604
						else if `c1' == 2003 & `c2' == 2015 local lerr = 5.3907
						else if `c1' == 2003 & `c2' == 2018 local lerr = 7.77	// Updated 06/09/2019
						else if `c1' == 2006 & `c2' == 2009 local lerr = 4.069
						else if `c1' == 2006 & `c2' == 2012 local lerr = 5.58
						else if `c1' == 2006 & `c2' == 2015 local lerr = 6.6064
						else if `c1' == 2006 & `c2' == 2018 local lerr = 5.24 	// Updated 06/09/2019
						else if `c1' == 2009 & `c2' == 2012 local lerr = 2.602
						else if `c1' == 2009 & `c2' == 2015 local lerr = 3.4301 
						else if `c1' == 2009 & `c2' == 2018 local lerr = 3.52	// Updated 06/09/2019
						else if `c1' == 2012 & `c2' == 2015 local lerr = 5.2535 
						else if `c1' == 2012 & `c2' == 2018 local lerr = 3.74	// Updated 06/09/2019
						else if `c1' == 2015 & `c2' == 2018 local lerr = 3.93	// Updated 06/09/2019

						else if `c1' == 2000 & `c2' == 2022 local lerr = 6.67 	// Updated 01/09/2023
						else if `c1' == 2003 & `c2' == 2022 local lerr = 5.25 	// Updated 01/09/2023
						else if `c1' == 2006 & `c2' == 2022 local lerr = 8.56 	// Updated 01/09/2023
						else if `c1' == 2009 & `c2' == 2022 local lerr = 4.66 	// Updated 01/09/2023
						else if `c1' == 2012 & `c2' == 2022 local lerr = 6.01 	// Updated 01/09/2023
						else if `c1' == 2015 & `c2' == 2022 local lerr = 3.63 	// Updated 01/09/2023
						else if `c1' == 2018 & `c2' == 2022 local lerr = 1.47 	// Updated 01/09/2023
						
						else di "no link error available"
						}
					else if  "`scale'" == "scie" {
						if `c1' == 2006 & `c2' == 2009 local lerr = 2.566
						else if `c1' == 2006 & `c2' == 2012 local lerr = 3.512
						else if `c1' == 2009 & `c2' == 2012 local lerr = 2.006
						else if `c1' == 2006 & `c2' == 2015 local lerr = 4.4821 
						else if `c1' == 2009 & `c2' == 2015 local lerr = 4.5016 
						else if `c1' == 2012 & `c2' == 2015 local lerr = 3.9228 
						else if `c1' == 2006 & `c2' == 2018 local lerr = 3.47		// Updated 06/09/2019
						else if `c1' == 2009 & `c2' == 2018 local lerr = 3.59		// Updated 06/09/2019
						else if `c1' == 2012 & `c2' == 2018 local lerr = 4.01		// Updated 06/09/2019
						else if `c1' == 2015 & `c2' == 2018 local lerr = 1.51		// Updated 06/09/2019

						else if `c1' == 2006 & `c2' == 2022 local lerr = 3.68 	// Updated 01/09/2023
						else if `c1' == 2009 & `c2' == 2022 local lerr = 5.92 	// Updated 01/09/2023
						else if `c1' == 2012 & `c2' == 2022 local lerr = 5.20	// Updated 01/09/2023
						else if `c1' == 2015 & `c2' == 2022 local lerr = 1.38 	// Updated 01/09/2023
						else if `c1' == 2018 & `c2' == 2022 local lerr = 1.61 	// Updated 01/09/2023
						
						else di "no link error available"
						}
					else if  "`scale'" == "crea" & `c1' == 2009 & `c2' ==2012 local lerr = 2.48
					else if  "`scale'" == "flit" {
						if `c1' == 2012 & `c2' ==2015 local lerr = 5.3309
						if `c1' == 2012 & `c2' ==2018 local lerr = 5.55			// Updated 06/09/2019
						if `c1' == 2015 & `c2' ==2018 local lerr = 9.37			// Updated 06/09/2019

						else if `c1' == 2012 & `c2' == 2022 local lerr = 4.05	// Updated 01/09/2023
						else if `c1' == 2015 & `c2' == 2022 local lerr = 3.47 	// Updated 01/09/2023
						else if `c1' == 2018 & `c2' == 2022 local lerr = 2.20 	// Updated 01/09/2023
						
						else di "no link error available"
						}
						else di as res "scale unknown, no link error available"
					}	
				}
			}

		**************
		if "`linkerrortable'" != "" {
			merge 1:1 cnt using `linkerrortable'
			qui levelsof cnt if _merge == 1 , l(nole) clean
			noi di as res "No Link error found for `nole'"
			qui keep if _merge != 2
			qui drop _merge			
			}
		* noisily des
		**************
		foreach var of varlist *_b`last' {
				local stub = subinstr("`var'","_b`last'","",1)
				local stuberr = subinstr("`stub'","T_","",1)
				cap confirm variable `stub'_b`first'
				if !_rc {
					gen `stub'_diff_b = `stub'_b`last' - `stub'_b`first'
					if regexm("T_`linkerror'","`stub'") == 0 & "`linkerrortable'" == "" {
						gen `stub'_diff_se = sqrt(`stub'_se`last'^2 + `stub'_se`first'^2)
						}
					else if "`linkerrortable'" != "" {
						cap confirm variable `stuberr'
						if !_rc {
							gen `stub'_diff_se = sqrt(`stub'_se`last'^2 + `stub'_se`first'^2 + `stuberr'^2)
							noisily di  as res "link error added for `stuberr'"
							}
						else {
							gen `stub'_diff_se = sqrt(`stub'_se`last'^2 + `stub'_se`first'^2)
							noi di as res "No link error added for `stuberr'"
							}
						}
					else if regexm("T_`linkerror'","`stub'") != 0{
						noisily di "link error (`lerr') added for `stub'"
						noisily di "sqrt(`stub'_se`last'^2 + `stub'_se`first'^2 + `lerr'^2)"
						gen `stub'_diff_se = sqrt(`stub'_se`last'^2 + `stub'_se`first'^2 + `lerr'^2)
						}
					cap confirm variable `stub'_f`last'  `stub'_f`first'
					if !_rc gen `stub'_diff_f = max(`stub'_f`last',`stub'_f`first')
					cap confirm variable `stub'_c`last' `stub'_c`first'
					if !_rc {
						generate `stub'_diff_c = "" 
						replace `stub'_diff_c = "†" if (`stub'_c`last' == "†") | (`stub'_c`first' == "†")
						replace `stub'_diff_c = "‡" if (`stub'_c`last' == "‡") | (`stub'_c`first' == "‡")
						replace `stub'_diff_c = "" if (`stub'_b`last' == .) | (`stub'_b`first' == .)
						}
					}
				}
		if "`keep'" == "" keep cnt *_diff_*
		else {
			foreach el in b se f c {
				foreach year in first last {
					cap ren *_`el'``year'' *_``year''_`el'
					}
				}
			}
		ren T_* *	
	}
	save `table'_`trend' , replace
	restore
end
