*** PISALINKERROR 
* created 26 Jan 2016
* 24 feb : option nomatch added


cap program drop pisalinkerror
program define pisalinkerror
	syntax  , table(string) linkerrortable(string) [nomatch]
	confirm file `table'.dta
	confirm file "`linkerrortable'.dta"
	preserve
	qui {
		use `table', clear
		merge 1:1 cnt using "`linkerrortable'", keepusing(cnt *_le)
		levelsof cnt if _merge == 1 , l(nole) clean
		if "`nole'" != "" noi di "No Link error found for `nole'"
		keep if _merge != 2
		drop _merge
		unab le : *_le
		foreach var of varlist `le' {
				local stub = regexr("`var'","_le$","")
				if "`match'" != "nomatch" {
					foreach coef of varlist *_b {
						if regexm("`coef'","`stub'") {
							local coef = regexr("`coef'","_b$","")
							replace `coef'_se = sqrt(`coef'_se^2 + `stub'_le^2)
							noi di as res "	link error `stub'_le added to `coef'"
							}
						}
					drop `stub'_le
					}
				else if wordcount("`le'") == 1 {
					replace `stub'_se = sqrt(`stub'_se^2 + `le'^2)
					noi di as res "`stub':	link error `le' added"
					}
				else error 134
				}
		cap	drop `le'
	}
	save `table'_le , replace
	restore
end
