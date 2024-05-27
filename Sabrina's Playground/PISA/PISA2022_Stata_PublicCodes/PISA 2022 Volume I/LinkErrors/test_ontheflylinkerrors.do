*** programme to test that "on the fly" link errors for cumulative frequencies provide valid results

** test validity of code using simulated data - does the method give approximately the same result when used on synthetic data that obey the assumptions?


cd "c:\temp\Volume I"


***** PARAMETERS *** 
local lerr = 3 // link error (in the same scale as scores)
local cutscore = 410 // score at which the cumulative percentage is computed
local S  = 6000 // number of simulations to be used. 	
********************



clear 
set seed 1105
local obs = max(5000,`S')
set obs `obs'
gen pv1mock = rnormal(500,100)
save mockpv, replace

tempname memhold
postfile `memhold' int simulations float scale_err cum_err using  sim_based_lerr , replace	
	use mockpv, clear
	cap drop cum_err scale_err
	gen scale_err = .
	gen cum_err = .
	forvalues i = 1/`S' {
		cap drop pv1mock_s*
		local scale_err_s = rnormal(0,`lerr')
		qui replace scale_err = `scale_err_s' in `i'
		qui gen pv1mock_s = pv1mock + `scale_err_s'
		qui gen pv1mock_s_cum = 100*(pv1mock_s <= `cutscore')
		su pv1mock_s_cum, meanonly
		qui replace cum_err = r(mean) in `i'
	}
	quietly summarize cum_err, d
	local cum_err = sqrt(r(Var))
	quietly summarize scale_err, d
	local scale_err = sqrt(r(Var))
	post `memhold'  (`S') (`scale_err') (`cum_err') 

postclose `memhold'

cap gen pv1mock_cum = 100*(pv1mock <= `cutscore')
su pv1mock_cum, meanonly

forval m = 1/1 {
	di as res "cumulative frequency: " %4.2f r(mean) " %"
	di as res "scale error: " `lerr'
	di as res "delta-method linkerror: " (`lerr'/100)*normalden(invnorm(r(mean)/100))*100
	use sim_based_lerr, clear
	list
	}



