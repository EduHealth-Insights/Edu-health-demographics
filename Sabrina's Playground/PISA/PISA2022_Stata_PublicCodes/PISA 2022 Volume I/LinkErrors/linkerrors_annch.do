// Programme to compute link errors for linear and curvilinear trends
// These are the errors associated with potential differences in scales between cycles, when looking at changes across cycles (regression of score over year)

// Constructs simulated dataset under the constraint that the link error between any two waves is equal to the published link error.
// Then uses this database to simulate the link error on the annualised change.

// Last modified: May 2023
// Author: Francesco Avvisati

********************************************************
**** 1. CREATE MATRICES OF LINK VARIANCE:COVARIANCE **** 
********************************************************

*** We have variance in link error between each set of two cycles, i.e. between 2003/2006, 2003/2009, 2006/2009, etc.
*** This essentially assumes that 2003, 2006, 2009, etc. all differ by an offset, e.g. 2006 = 2003 + LE(2003/2006), 2009 = 2003 + LE(2003/2009)
*** Hence, LE(2003/2006) ~ N(0, V(2003/2006)), LE(2003/2009) ~ N(0, V(2003/2009)), etc.
*** However, we need to draw consistent link errors using the covariance via Cholesky matrices.

*** Cholesky matrices allow us to draw from the multivariate normal with a predefined covariance structure
	*** The square of the link error (i.e. the variance) is on the diagonal
	*** The covariance between various link errors are off the diagonal

	*** Formula: V(2006 - 2003) = V(2006) + V(2003) - 2COV(2003, 2006)
	*** Formula: V(LE(2009/2003) - LE(2006/2003)) = V(LE(2009/2003)) + V(LE(2006/2003)) - 2COV(LE(2009/2003), LE(2006/2003))
	*** Formula: V(LE(2009/2006)) = V(LE(2009/2003)) + V(LE(2006/2003)) - 2COV(LE(2009/2003), LE(2006/2003))
	*** FINAL FORMULA: COV(LE(2009/2003), LE(2006/2003)) = (V(LE(2009/2003)) + V(LE(2006/2003)) - V(LE(2009/2006))) / 2
	
	*** The matrix might look like:
	***		06/18 + 06/18		06/18 + 09/18		06/18 + 12/18		06/18 + 15/18
	***		09/18 + 06/18		09/18 + 09/18		09/18 + 12/18		09/18 + 15/18
	***		12/18 + 06/18		12/18 + 09/18		12/18 + 12/18		12/18 + 15/18
	***		15/18 + 06/18		15/18 + 09/18		15/18 + 12/18		15/18 + 15/18
	

set matsize 11000


**** science:
local scie0609 = 2.566^2

local scie0612 = 3.512^2
local scie0912 = 2.006^2

local scie0615 = 4.4821^2
local scie0915 = 4.5016^2
local scie1215 = 3.9228^2

local scie0618 = 3.47^2 		 
local scie0918 = 3.59^2 		
local scie1218 = 4.01^2 		
local scie1518 = 1.51^2 		

local scie0622 = 3.68^2  // updated 01/09		 
local scie0922 = 5.92^2  // updated 01/09		
local scie1222 = 5.20^2	 // updated 01/09		 		
local scie1522 = 1.38^2	 // updated 01/09		
local scie1822 = 1.61^2	 // updated 01/09		


// covariance matrix is not positive-definite with the above values. The following values have been increased in order to make matrix p-d, resulting in  more conservative SE*/

** increase some link errors so that they are always monotonically decreasing in time
foreach la in 09 12 15 18 22 {
	local lerr = 0
	foreach fi in 18 15 12 09 06 { // cycling through link errors backwards, so that they are always monotonically decreasing in time
		if `fi' < `la' {
			if `lerr' > `scie`fi'`la'' { // condition is never true for the first link error encountered (lerr set to 0)
				di "scie`fi'`la' increased to " round(sqrt(`lerr'),.01)
				local scie`fi'`la' = `lerr'
			}
		local lerr = `scie`fi'`la''
		}
	}
}

** increase link errors to 18 or 22 to the higher value among the two 
foreach fi in 15 12 09 06 { 
	if `scie`fi'18' > `scie`fi'18' { 
			di "scie`fi'22 increased to  "round(sqrt(`scie`fi'18'),.01)
			local scie`fi'22 =  `scie`fi'18'
		}
	else { 
			di "scie`fi'18 increased to  "round(sqrt(`scie`fi'22'),.01)
			local scie`fi'18 =  `scie`fi'22'
		}
	}
** increase "problematic" link errors manually (check variance matrix to determine which ones to manipulate, ideally inside bounds set by previous rule)
local scie0912 = 2.4^2 		
local scie0615 = 5^2 		
local scie0915 = 5^2 		
local scie1215 = 4.4^2 		

mata 
	scievariance = ( `scie0622', (`scie0622'+`scie0922'-`scie0609')/2, (`scie0622'+`scie1222'-`scie0612')/2, (`scie0622'+`scie1522'-`scie0615')/2, (`scie0622'+`scie1822'-`scie0618')/2 \	///
					 (`scie0622'+`scie0922'-`scie0609')/2, `scie0922', (`scie0922'+`scie1222'-`scie0912')/2, (`scie0922'+`scie1522'-`scie0915')/2, (`scie0922'+`scie1822'-`scie0918')/2 \ 	///
					 (`scie0622'+`scie1222'-`scie0612')/2, (`scie0922'+`scie1222'-`scie0912')/2, `scie1222', (`scie1222'+`scie1522'-`scie1215')/2, (`scie1222'+`scie1822'-`scie1218')/2 \ 	///
					 (`scie0622'+`scie1522'-`scie0615')/2, (`scie0922'+`scie1522'-`scie0915')/2, (`scie1222'+`scie1522'-`scie1215')/2, `scie1522', (`scie1522'+`scie1822'-`scie1518')/2 \	///
					 (`scie0622'+`scie1822'-`scie0618')/2, (`scie0922'+`scie1822'-`scie0918')/2, (`scie1222'+`scie1822'-`scie1218')/2, (`scie1522'+`scie1822'-`scie1518')/2, `scie1822')
	scievariance
	symeigenvalues(scievariance) // check all positive (meaning that V matrix is positive-definite)
	sciechol = cholesky(scievariance)
	sciechol*sciechol' // check non-missing (meaning that V matrix is positive-definite)
	st_matrix("sciechol", sciechol) 
end

matrix list sciechol


**** mathematics:


local math0306 =1.350^2

local math0309 =1.990^2
local math0609 =1.333^2

local math0312 =1.931^2
local math0612 =2.084^2
local math0912 =2.294^2

local math0315 = 5.6080^2 
local math0615 = 3.5111^2 
local math0915 = 3.7853^2 
local math1215 = 3.5462^2 

local math0318 = 2.80^2 		
local math0618 = 3.18^2 		
local math0918 = 3.54^2 		
local math1218 = 3.34^2 		
local math1518 = 2.33^2 		

local math0322 = 5.54^2 	 // updated 01/09			
local math0622 = 4.09^2 	 // updated 01/09		
local math0922 = 4.28^2 	 // updated 01/09		
local math1222 = 3.58^2 	 // updated 01/09		
local math1522 = 2.74^2 	 // updated 01/09		
local math1822 = 2.24^2 	 // updated 01/09		

// covariance matrix is not positive-definite with the above values. The following values have been increased in order to make matrix p-d, resulting in  more conservative SE*/

** increase some link errors so that they are always monotonically decreasing in time
foreach la in 06 09 12 15 18 22 {
	local lerr = 0
	foreach fi in 18 15 12 09 06 03 { // cycling through link errors backwards, so that they are always monotonically decreasing in time
		if `fi' < `la' {
			if `lerr' > `math`fi'`la'' { // condition is never true for the first link error encountered (lerr set to 0)
				di "math`fi'`la' increased to " round(sqrt(`lerr'),.01)
				local math`fi'`la' = `lerr'
			}
		local lerr = `math`fi'`la''
		}
	}
}


** increase link errors to 15 or 18 to the higher value among the two 
foreach fi in 12 09 06 03 { 
	if `math`fi'18' > `math`fi'15' { 
			di "math`fi'15 increased to  "round(sqrt(`math`fi'18'),.01)
			local math`fi'15 =  `math`fi'18'
		}
	else { 
			di "math`fi'18 increased to  "round(sqrt(`math`fi'15'),.01)
			local math`fi'18 =  `math`fi'15'
		}
	}

** increase "problematic" link errors manually (check variance matrix to determine which ones to manipulate, ideally inside bounds set by previous rule)
	local math0315 = 5^2
 	local math0318 = 5^2
 
 	local math0306 = 3.2^2
 	local math0309 = 3.2^2
 	local math0609 = 3^2

	local math0312 = 3.2^2
	local math0612 = 3.2^2
	local math0912 = 3.2^2

	
mata 
	mathvariance =  (`math0322', (`math0322'+`math0622'-`math0306')/2, (`math0322'+`math0922'-`math0309')/2, (`math0322'+`math1222'-`math0312')/2, (`math0322'+`math1522'-`math0315')/2, (`math0322'+`math1822'-`math0318')/2 \	///
					 (`math0322'+`math0622'-`math0306')/2, `math0622', (`math0622'+`math0922'-`math0609')/2, (`math0622'+`math1222'-`math0612')/2, (`math0622'+`math1522'-`math0615')/2, (`math0622'+`math1822'-`math0618')/2 \ 	///
					 (`math0322'+`math0922'-`math0309')/2, (`math0622'+`math0922'-`math0609')/2, `math0922', (`math0922'+`math1222'-`math0912')/2, (`math0922'+`math1522'-`math0915')/2, (`math0922'+`math1822'-`math0918')/2 \ 	///
					 (`math0322'+`math1222'-`math0312')/2, (`math0622'+`math1222'-`math0612')/2, (`math0922'+`math1222'-`math0912')/2, `math1222', (`math1222'+`math1522'-`math1215')/2, (`math1222'+`math1822'-`math1218')/2 \	///
					 (`math0322'+`math1522'-`math0315')/2, (`math0622'+`math1522'-`math0615')/2, (`math0922'+`math1522'-`math0915')/2, (`math1222'+`math1522'-`math1215')/2, `math1522', (`math1522'+`math1822'-`math1518')/2 \	///
					 (`math0322'+`math1822'-`math0318')/2, (`math0622'+`math1822'-`math0618')/2, (`math0922'+`math1822'-`math0918')/2, (`math1222'+`math1822'-`math1218')/2, (`math1522'+`math1822'-`math1518')/2, `math1822')
	mathvariance
	symeigenvalues(mathvariance)
	mathchol = cholesky(mathvariance)
	mathchol*mathchol'
	st_matrix("mathchol", mathchol) 
end

matrix list mathchol


**** Reading:

local read0022 = 6.67^2 	// updated 01/09
local read0322 = 5.25^2		// updated 01/09
local read0622 = 8.56^2		// updated 01/09
local read0922 = 4.66^2		// updated 01/09
local read1222 = 6.01^2		// updated 01/09
local read1522 = 3.63^2		// updated 01/09
local read1822 = 1.47^2		// updated 01/09

local read0018 = 4.04^2 	
local read0318 = 7.77^2		
local read0618 = 5.24^2		
local read0918 = 3.52^2		
local read1218 = 3.74^2		
local read1518 = 3.93^2		

local read0015 = 6.8044^2 
local read0315 = 5.3907^2 
local read0615 = 6.6064^2 
local read0915 = 3.4301^2
local read1215 = 5.2535^2

local read0003 =5.321^2

local read0006 =4.963^2
local read0306 =4.480^2

local read0009 =4.937^2
local read0309 =4.088^2
local read0609 =4.069^2

local read0012 =5.923^2
local read0312 =5.604^2
local read0612 =5.580^2
local read0912 =2.602^2


// covariance matrix is not positive-definite with the above values. The following values have been increased in order to make matrix p-d, resulting in  more conservative SE


** increase some link errors so that they are always monotonically decreasing in time
foreach la in 03 06 09 12 15 18 22 {
	local lerr = 0
	foreach fi in 18 15 12 09 06 03 00 { // cycling through link errors backwards, so that they are always monotonically decreasing in time
		if `fi' < `la' {
			if `lerr' > `read`fi'`la'' { // condition is never true for the first link error encountered (lerr set to 0)
				di "read`fi'`la' increased to " round(sqrt(`lerr'),.01)
				local read`fi'`la' = `lerr'
			}
		local lerr = `read`fi'`la''
		}
	}
}

** increase "problematic" link errors manually (check variance matrix to determine which ones to manipulate, ideally inside bounds set by previous rule)
local read0022 =8.25^2 //  this was decreased ! 

local read0309 =7^2
local read0609 =6^2
local read0312 =7^2
local read1522 = 3.9^2		
local read0015 = 7^2 
local read0315 = 7^2 
local read0618 = 7.5^2 
local read0918 = 5^2 
local read1218 = 5^2 

mata 
	readvariance = ( `read0022', (`read0022'+`read0322'-`read0003')/2, (`read0022'+`read0622'-`read0006')/2, (`read0022'+`read0922'-`read0009')/2, (`read0022'+`read1222'-`read0012')/2, (`read0022'+`read1522'-`read0015')/2, (`read0022'+`read1822'-`read0018')/2 \	///
					 (`read0022'+`read0322'-`read0003')/2, `read0322', (`read0322'+`read0622'-`read0306')/2, (`read0322'+`read0922'-`read0309')/2, (`read0322'+`read1222'-`read0312')/2, (`read0322'+`read1522'-`read0315')/2, (`read0322'+`read1822'-`read0318')/2 \	///
					 (`read0022'+`read0622'-`read0006')/2, (`read0322'+`read0622'-`read0306')/2, `read0622', (`read0622'+`read0922'-`read0609')/2, (`read0622'+`read1222'-`read0612')/2, (`read0622'+`read1522'-`read0615')/2, (`read0622'+`read1822'-`read0618')/2 \ ///
					 (`read0022'+`read0922'-`read0009')/2, (`read0322'+`read0922'-`read0309')/2, (`read0622'+`read0922'-`read0609')/2, `read0922', (`read0922'+`read1222'-`read0912')/2, (`read0922'+`read1522'-`read0915')/2, (`read0922'+`read1822'-`read0918')/2 \ ///
					 (`read0022'+`read1222'-`read0012')/2, (`read0322'+`read1222'-`read0312')/2, (`read0622'+`read1222'-`read0612')/2, (`read0922'+`read1222'-`read0912')/2, `read1222', (`read1222'+`read1522'-`read1215')/2, (`read1222'+`read1822'-`read1218')/2 \	///
					 (`read0022'+`read1522'-`read0015')/2, (`read0322'+`read1522'-`read0315')/2, (`read0622'+`read1522'-`read0615')/2, (`read0922'+`read1522'-`read0915')/2, (`read1222'+`read1522'-`read1215')/2, `read1522', (`read1522'+`read1822'-`read1518')/2 \ ///
					 (`read0022'+`read1822'-`read0018')/2, (`read0322'+`read1822'-`read0318')/2, (`read0622'+`read1822'-`read0618')/2, (`read0922'+`read1822'-`read0918')/2, (`read1222'+`read1822'-`read1218')/2, (`read1522'+`read1822'-`read1518')/2, `read1822')
	readvariance
	eigenvalues(readvariance)
	det(readvariance)
	readchol = cholesky(readvariance)
	readchol*readchol'
	st_matrix("readchol", readchol) 
end

matrix list readchol


********************************************************************************************
**** 2. GENERATE DB FOR SIMULATIONS FROM LINK ERRORS (PRESUMING ONLY SHIFT IS DUE TO LE)  **** 
********************************************************************************************




*** Generates various simulated link errors
*** The final format of the file is:
***		simulation#		year	linkerror(to 2022)		epsilon(random#)
***		1				2003	#						#
***		1				2006	#						#
***		1				2009	#						#
***		1				2012	#						#
***		1				2015	#						#
***		2				2003	#						#
***		...
***		2000			2015	#						#
foreach domn in read math scie {
	clear
	set obs 8000

	set seed 6012016
	foreach wave in  2000 2003 2006 2009 2012 2015 2018 2022 {
		cap drop epsilon`wave'
		if  `wave' != 2022 qui gen epsilon`wave' = rnormal()
		else gen epsilon`wave' = 0
		}
		
	if "`domn'" == "read" 		mkmat epsilon2000 epsilon2003 epsilon2006 epsilon2009 epsilon2012 epsilon2015 epsilon2018, matrix(noise)
	else if "`domn'" == "math" 	mkmat 		      epsilon2003 epsilon2006 epsilon2009 epsilon2012 epsilon2015 epsilon2018, matrix(noise)
	else if "`domn'" == "scie" 	mkmat 			  			  epsilon2006 epsilon2009 epsilon2012 epsilon2015 epsilon2018, matrix(noise)

	matrix link = noise * `domn'chol'

	svmat link, names(link)

	if "`domn'" == "read" {
		rename link1 link2000
		rename link2 link2003
		rename link3 link2006
		rename link4 link2009
		rename link5 link2012
		rename link6 link2015
		rename link7 link2018
	}
	else if "`domn'" == "math" {
		ren link1 link2003
		ren link2 link2006
		ren link3 link2009
		ren link4 link2012
		ren link5 link2015
		ren link6 link2018
	}
	else if "`domn'" == "scie" {
		ren link1 link2006
		ren link2 link2009
		ren link3 link2012
		ren link4 link2015
		ren link5 link2018
	}
	generate link2022 = 0
	capture generate link2001 = link2000
	capture generate link2002 = link2000
	capture generate link2010 = link2009
// pisa-d link?
	capture generate link2017 = link2015

*** checking that linking errors on simple differences correspond to the ones used as input:

	foreach first in 00 03 06 09 12 15 18 {
		foreach last in 03 06 09 12 15 18 22 {
			if real("`last'") > real("`first'") {
				capture confirm variable link20`first' 
				if !_rc {
					capture drop trend`first'`last' 
					generate trend`first'`last' = link20`last'-link20`first'
					quietly summarize trend`first'`last', d
					display "trend`first'`last' : " %4.3f r(mean) "    (check if close to 0)"
					display "lerr`first'`last' : " %4.3f sqrt(r(Var)) "    (check if close to " %4.3f sqrt(``domn'`first'`last'') ")" 
				}
			}
		}
	}

	capture drop trend*
	generate sim = _n
	reshape long link@ epsilon@, i(sim) j(year)

	generate y = year - 2018
	generate y2 = y^2
	tempfile linkerror_`domn'
	save `linkerror_`domn'', replace
	}


********************************************************************************************
**** 3. Run regression on previous DB to gauge magnitude of link errors for linear/curvilinear trends)  **** 
********************************************************************************************

**** Which countries have assessed in which years? (To allow for comparisons of similar trends)
**** the cntyears.xlsx file includes for each country, reading years ("2009;2012;2015;2018;2022"), maths years, and science years 
 
***** 
 **** Compute link errors for each combination of years
quietly cd "$linkerrors"
tempname memhold
postfile `memhold' str4 domain str64 years int simulations float linkerror linkerror_s linkerror1 linkerror2 using  lerr_curv_change2022 , replace	
local S  = 2000 // number of simulations to be used. Max is 2000	

foreach domn in read math scie {
	import excel "$infile\cntyears.xlsx", firstrow sheet("cntyears") clear
	levelsof `domn'years, clean l(yearcombinations)
	foreach years in `yearcombinations' {
		local years = subinstr("`years'",";",",",.)
		if length("`years'") > 4 {
			display "`years'"
			use `linkerror_`domn'', clear
			capture drop trend* line curv
			quietly generate trend = .
			quietly generate trend_s = .
			quietly generate line = .
			quietly generate curv = .
			******
			** link error for annualised change
			display `"estimating linear and curvilinear linkerrors for ("`domn'") ("`years'") (`S')"'
			forvalues i = 1/`S' {
				quietly regress link y if sim == `i' & inlist(year,`years')
				quietly replace trend = _b[y] in `i'
				quietly regress link y if sim == `i' & inlist(year,`years') & year >= 2012 // short decennial trend
				quietly replace trend_s = _b[y] in `i'
				if length("`years'") > 19 { 			// At least four data points in years
					quietly regress link y y2 if sim == `i' & inlist(year,`years')
					quietly replace line = _b[y] in `i'
					quietly replace curv = _b[y2] in `i'
				}
			}
			
			
			** Linear link errors
			quietly summarize trend, d
			local lerr = sqrt(r(Var))
			display "trend : " %4.3f r(mean)
			display "lerr (`years') : " %4.3f `lerr'
			
			quietly summarize trend_s, d
			local lerr_s = sqrt(r(Var))
			display "trend_s : " %4.3f r(mean)
			display "lerr_s (`years') : " %4.3f `lerr_s'
			
			** Curvilinear link errors
			if length("`years'") > 19 { 
				quietly summarize curv, d
				local lerr2 = sqrt(r(Var))
				quietly summarize line, d
				local lerr1 = sqrt(r(Var))
				display "lerr1 (`years') : " %4.3f `lerr1'
				display "lerr2 (`years') : " %4.3f `lerr2'
				post `memhold'  ("`domn'") ("`years'") (`S') (`lerr') (`lerr_s') (`lerr1') (`lerr2')
			}
			else post `memhold'  ("`domn'") ("`years'") (`S') (`lerr') (`lerr_s') (.) (.)
		}
		else post `memhold'  ("`domn'") ("`years'") (`S') (.) (.) (.) (.)
	}
}
postclose `memhold'


quietly cd "$linkerrors"

use lerr_curv_change2022, clear
compress
foreach var of varlist linkerror linkerror_s {
	replace `var' = 10*`var'  // linear trends are reported as "decennial trends"
	}
format linkerror* %5.4f
keep if length(years)>4
export excel domain years linkerror linkerror_s using linkerrors.xls, sheet(AT.ann2) sheetreplace first(var)
export excel domain years linkerror1 linkerror2 using linkerrors.xls, sheet(AT.curv) sheetreplace first(var)

*************************************************************
**** 4. Assign link errors to countries and to averages  **** 
*************************************************************

import excel "$infile\cntyears.xlsx", firstrow sheet("cntyears") clear
	merge 1:1 cnt using "$infile\cnt_fcnt", nogen keep(1 3)
	drop cnt 
	ren fcnt cnt
reshape long @years, string i(cnt) j(domain)
	replace years = subinstr(years,";",",",.)
merge m:1 domain years using lerr_curv_change2022, keepusing(domain years linkerror*) nogen
foreach var of varlist linkerror linkerror_s {
	replace `var' = 10*`var'  // linear trends are reported as "decennial trends"
	}
tempfile cntlinkerror
save `cntlinkerror', replace


foreach domn in read math scie {
	use `cntlinkerror', clear
	keep if domain == "`domn'"
	keep cnt linkerror*
	rename linkerror* linkerror*_b
	save lerr_curv_change_`domn'_2022, replace

	*** compute averages
	save lerr_curv_change_`domn'_2022_AV, replace // initialise file (good name, no averages for the moment)
	foreach list in AVG AV0022R AV0322 AV0622R AV0622 AV0922 AV1222 AV00T AV03T AV06T AV12T AV1822NB AV12TE {
		cntmean, table(lerr_curv_change_`domn'_2022_AV) cntlist(${`list'}) cntvar(cnt) label(`list') 
		use lerr_curv_change_`domn'_2022_AV_`list', clear
		save lerr_curv_change_`domn'_2022_AV, replace
		erase  lerr_curv_change_`domn'_2022_AV_`list'.dta
		}
	rename (linkerror_b linkerror_s_b linkerror1_b linkerror2_b) (longtrend_le shorttrend_le line_le curv_le)
	save lerr_curv_change_`domn'_2022_AV, replace
}

