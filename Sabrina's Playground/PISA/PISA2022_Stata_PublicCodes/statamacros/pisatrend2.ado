*** PISATREND2
* created 26 Jan 2016
* modified 8/7/2016 - corrected bug in line 27 (linkerrortable)
* modified 06/09/2019 - link errors to 2019 added
* modified 10/05/2023 - provisional link errors to 2022 added
* modified 10/05/2023 - on-the-fly link errors for cumulative percentages (percentage above/below Level X)



cap program drop pisatrend2
program define pisatrend2
	syntax  namelist(max=1 name=type), table(string) first(numlist >1999 integer) last(numlist >1999 integer) [stub(namelist) linkerror(real 0) scale(string) linkerrortable(string) keep]
	
	if "`type'" == "scale" {
		if "`scale'" == "" {
			di as error "No scale specified in option scale()"
			error 198
			}
		}
	else if "`type'" == "manual" {
		if "`linkerror'" == "" {
			di as error "No linkerror specified in option linkerror()"
			error 198
			}
		}
	else if "`type'" == "simple" {
		if "`linkerror'" != "" | "`scale'" != "" | "`linkerrortable'" != "" {
			di as res "Options linkerror(), scale() and table() are ignored with pisatrend2 simple"
			local linkerror "" 
			local scale ""
			local linkerrortable ""
			}
		}
	else if "`type'" == "table" {
		if "`linkerrortable'" == "" {
			di as error "No linkerror table specified in option linkerrortable()"
			error 198
			}
		}	
	if "`type'" == "cumulative" {
		if "`scale'" == "" {
			di as error "No scale specified in option scale()"
			error 198
			}
		}
		

	preserve
	confirm file "`table'.dta"
	use "`table'", clear
	if "`type'" == "simple" & "`stub'" == "" {
		unab estimates: *_b
		foreach word in `estimates' {
			local stub = "`stub' "+ regexr("`word'","(_b)$","")
			}
		}
		
	if "`type'" != "table" {
		foreach c1 in `first' {
			foreach c2 in  `last' {
			if `c2' > `c1' {
				local trend = substr("`c1'",3,2) + substr("`c2'",3,2)
				*******************
				* Load link error *
				*******************
				if "`type'" == "scale" | "`type'" == "cumulative" {
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
				else if "`type'" == "manual" local lerr = "`linkerror'"
				else if "`type'" == "simple" local lerr = 0

				************************
				* Compute differences  *
				************************
				
				local varlast ""
				foreach name in `stub' {
					cap confirm variable `name'_`c2'_b `name'_`c1'_b 
					if !_rc {
						qui gen `name'_`trend'_b = `name'_`c2'_b - `name'_`c1'_b
						if "`scale'" == "" {
							qui gen `name'_`trend'_se = sqrt(`name'_`c2'_se^2 + `name'_`c1'_se^2)
							}
						else if "`type'" != "cumulative" {
							noisily di as res "trend `trend': link error for `scale' (`lerr') added for `name'"
							qui gen `name'_`trend'_se = sqrt(`name'_`c2'_se^2 + `name'_`c1'_se^2 + `lerr'^2)
							}
						else if "`type'" == "cumulative" {
/*If we assume that scores follow a normal distribution with standard deviation S.D. we can use the delta-method to compute approximate link errors: the delta method linearises the scale transformation g(x) around the value of x=X. For example, if g(x) is the cumulative standard normal distribution function F(x)*100, the delta-method link error is (LERR/S.D.)*f(x)*100. If our stat S is the "percentage below score N", we can first express the value of X (a point in the standard normal distribution) as X = F^(-1)(S/100), then apply the above formula to get LERR_S = (LERR/S.D.)*f(F^(-1)(S/100))*100
•	f is the (standard) normal density function (normalden() in stata terms)
•	F^(-1) the inverse (standard) normal cumulative function (invnorm() in  stata terms)
•	LERR is the original scale link error 
•	S.D. is the standard deviation of the score distribution for the population of interest
•	S/100 is the proportion of students above/below a certain cutoff for the population of interest.
*/
							noisily di as res "trend `trend': link error for the cumulative `scale' distribution computed using the delta method for all values of `name'"
							tempvar `name'_`c2'_le
							qui gen ``name'_`c2'_le' = (`lerr'/100)*normalden(invnorm(`name'_`c2'_b/100))*100 // assuming that the current lerr is scaled to a S.D. of 100, and that coefficients are expressed as percentages
							qui gen `name'_`trend'_se = sqrt(`name'_`c2'_se^2 + `name'_`c1'_se^2 + ``name'_`c2'_le'^2)
							cap drop ``name'_`c2'_le'
							}
						cap confirm variable `name'_`c2'_f  `name'_`c1'_f
						if !_rc qui gen `name'_`trend'_f = max(`name'_`c2'_f,`name'_`c1'_f)
						}
					}
				}
			}
		}
	}
		
	else if "`type'" == "table" {
		confirm file "`linkerrortable'.dta"
		qui merge 1:1 cnt using "`linkerrortable'", keepusing(cnt *_le)
		qui levelsof cnt if _merge == 1 , l(nole) clean
		if "`nole'" != "" noi di as res "No Link error found for `nole'"
		qui keep if _merge != 2
		qui drop _merge
		foreach c1 in `first' {
			foreach c2 in  `last' {
			if `c2' > `c1' {
				local trend = substr("`c1'",3,2) + substr("`c2'",3,2)
				************************
				* Compute differences  *
				************************
				local varlast ""
				foreach name in `stub' {
					cap confirm variable `name'_`c2'_b `name'_`c1'_b 
					if !_rc {
						qui gen `name'_`trend'_b = `name'_`c2'_b - `name'_`c1'_b
						cap confirm variable  `name'_`trend'_le
						if !_rc {
							noisily di  as res "trend `trend': link error added for `name'"
							qui gen `name'_`trend'_se = sqrt(`name'_`c2'_se^2 + `name'_`c1'_se^2 + `name'_`trend'_le^2)
							}
						else di as error "Linkerror `name'_`trend'_le not found"
						cap confirm variable `name'_`c2'_f  `name'_`c1'_f
						if !_rc qui gen `name'_`trend'_f = max(`name'_`c2'_f,`name'_`c1'_f)
						}
					}
				else di as error "variables `name'_`c2'_b `name'_`c1'_b not found"
				}
			}
		}
	qui drop *_le
	}

	save `table'_trend, replace
	restore
end
