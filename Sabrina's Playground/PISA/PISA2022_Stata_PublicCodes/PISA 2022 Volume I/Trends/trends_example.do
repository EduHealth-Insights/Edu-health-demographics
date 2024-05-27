// This file illustrates the process through which trend tables in PISA 2022 Results (Volume I) were built. 
// The process consists of 3 steps: 
// 1. Estimate the required statistics separately on each cycle/database. 
// 2. Compute regression-based statistics (linear and quadratic trends across cycles)
// 3. Compose the tables for reporting from the outputs of the preceding two steps; compute interational means, raw differences across cycles, and add link errors to the standard errors as appropriate. 


// 1. Estimate the required statistics separately on each cycle/database. 
// compute stats on mathematics scores (means, percentiles, SD/IDR) for all cycles

#delim ;
do "C:\temp\Trends\trends_stats.do" 
	"job1"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_CH2_cnt.dta"
	"math"
	"stats_math_2022"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job2"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2018.dta"
	"math"
	"stats_math_2018"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job3"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2015.dta"
	"math"
	"stats_math_2015"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job4"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2012.dta"
	"math"
	"stats_math_2012"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job5"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2009.dta"
	"math"
	"stats_math_2009"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job6"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2006.dta"
	"math"
	"stats_math_2006"
	"CNT2022"
	"NULL"
	"betalog"
	;

do "C:\temp\Trends\trends_stats.do" 
	"job7"
	"V:\PISA_INITIALREPORT_2022\sandbox\Volume I\Infile\I_B1_2003.dta"
	"math"
	"stats_math_2003"
	"CNT2022"
	"NULL"
	"betalog"
	;
#delim cr


// 2. Compute regression-based statistics (linear and quadratic trends across cycles)
// compute linear trend - uses the output (betalog) of trends*stats as input
#delim ;
do "C:\temp\Trends\lineartrends.do" 
	"job8"
	"log_stats_math" 
	"2003 2006 2009 2012 2015 2018 2022"
	"mean p10 p25 p50 p75 p90"
;
#delim cr

// compute quadratic trend - uses the output (betalog) of trends*stats as input
#delim ;
do "C:\temp\Trends\quadratictrends.do" 
	"job9"
	"log_stats_math" 
	"2003 2006 2009 2012 2015 2018 2022"
	"mean"
;
#delim cr

// 3. Compose the tables for reporting from the outputs of the preceding two steps; compute interational means, raw differences across cycles, and add link errors to the standard errors as appropriate. 
// here: mean scores and linear/quadratic trends for mean scores

**********************
*** Table I_B1_T_2 ***
**********************

cd "${outfile}"
local domn "math"
local waves "2003 2006 2009 2012 2015 2018 2022"
		*** merge results from all cycles
			local repestresults : subinstr local waves "20" " stats_`domn'_20", all
			di "`repestresults'"
			qui {
				clear
				append using `repestresults', gen(wave)
				replace wave = real(word("`waves'",wave))
				***select variables to keep
				keep cnt wave *mean* 
				***
				unab results : *_b *_se
				reshape wide `results', i(cnt) j(wave)
				ren *_b(####) *_(####)_b
				ren *_se(####) *_(####)_se
				}
		*** add, rename and rescale any regression-based trends (if applicable)
		merge 1:1 cnt using stats_read_2000_lineartrend, nogen keepusing(cnt *mean*)
		ren *_year_* *_longtrend_*
		merge 1:1 cnt using stats_read_2012_lineartrend, nogen keepusing(cnt *mean*)
		ren *_year_* *_shorttrend_*
		foreach var of varlist *_longtrend_* *_shorttrend_* {
			replace `var' = `var'*10 // multiply by 10 to get 10-year-trend
			}
		merge 1:1 cnt using stats_read_quadratictrend, nogen keepusing(cnt *mean*)
		
	*** save for the first time (without averages nor link errors)
		save I_B1_T_2`domn', replace

	*** compute averages 		
			foreach AV in $averages {
				cntmean, table(I_B1_T_2`domn') cntlist(${`AV'}) cntvar(cnt) label(`AV') missing
				copy I_B1_T_2`domn'_`AV'.dta I_B1_T_1`domn'.dta, replace 	// save with same filename as previously, to allow looping over multiple averages
				erase I_B1_T_2`domn'_`AV'.dta
				}	

	*** compute trends, add link errors
		local last "2022"
		local first : list waves - last

		pisatrend2 scale, table(I_B1_T_2`domn') stub(pv_read_mean) first(`first') last(`last') scale(`domn')
		* add linkerrors for linear/curvlinear trends
		pisalinkerror, table(I_B1_T_2`domn'_trend) linkerrortable(${linkerrors}\lerr_curv_change_`domn'_2022_AV) match		

		*** export to excel
			pisaexport2, dir($outfile) file(I_B1_T_2`domn'_trend_le) directory2($export) outfile(I_B1_T.xlsx) outsheet(I_B1_T_2`domn') sort(cnt) select(cnt, $CNT2022 $averages)



