** EXPORT Engagement Tables 
** Program to subset and combine output files for final report tables, compute averages and export to excel.

** outfile and export  directory 
global outfile "V:\PISA_INITIALREPORT_2022\results\Trends\outfile"
global export "V:\PISA_INITIALREPORT_2022\results\Trends\export"


** Load country lists
run "V:\PISA_INITIALREPORT_2022\results\Trends\infile\averages.txt"
global averages "AVG AV12T"

*********************************************************
*** self-report effort / loweffort /relative effort  ****
*********************************************************

cd "$outfile"
foreach year in  2022 2018 1822 { //
	// selfreports
	foreach table in effort_selfreport_`year' effort_selfreport_gender_`year' {
			foreach AV in $averages {
				cd "$outfile"
				cntmean, table(`table') cntlist(${`AV'}) cntvar(cnt) label(`AV') missing
				copy `table'_`AV'.dta `table'.dta, replace 	// save with same filename as previously, to allow looping over multiple averages
				erase `table'_`AV'.dta
				}	
		}
				cd "$outfile"
	pisaexport2, dir($outfile) file(effort_selfreport_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.1.`year') sort(cnt) select(cnt, $CNT2022 $averages)
				cd "$outfile"
	pisaexport2, dir($outfile) file(effort_selfreport_gender_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.2.`year') sort(cnt) select(cnt, $CNT2022 $averages) order(_1_* _0_* _d_*)
	}
	
*** correlation with short term trend
				cd "$outfile"
use effort_selfreport_1822, clear
	foreach domn in math read scie {
		merge 1:1 cnt using I_B1_T_2`domn'_trend, keepusing(*1822*b) nogen keep(3)
	}
pwcorr *effort*b *1822*b
	pwcorr *effort*b *1822*b if cnt != "C268" // excl. outlier
	pwcorr *effort*b *1822*b if effort2_m_diff_c == "" // excl. low coverage countries 
corr effort2_m_diff_b pv_math_mean_1822_b 
	corr effort2_m_diff_b pv_math_mean_1822_b if cnt != "C268" // excl. outlier
	corr effort2_m_diff_b pv_math_mean_1822_b if effort2_m_diff_c == "" // excl. low coverage countries 


tw scatter  pv_math_mean_1822_b effort2_m_diff_b, m(i) mlabel(cnt) mlabpos(0) xtitle("Change in effort spent on high-stakes tests") ytitle("Change in PISA mathematics scores") title("Self-reported effort and performance changes (18-22)") name(effort2_math, replace)

tw scatter  pv_math_mean_1822_b effort2_m_diff_b if cnt != "C268" , m(i) mlabel(cnt) mlabpos(0) xtitle("Change in effort spent on high-stakes tests") ytitle("Change in PISA mathematics scores") title("Self-reported effort and performance changes (18-22)") name(effort2_math_2, replace)

*** correlation with short term trend
				cd "$outfile"
use effort_selfreport_1822, clear
	foreach domn in math read scie {
		merge 1:1 cnt using I_B1_T_2`domn'_trend, keepusing(*1822*b) nogen keep(3)
	}
pwcorr *effort*b *1822*b
	pwcorr *effort*b *1822*b if cnt != "C268" // excl. outlier
	pwcorr *effort*b *1822*b if effort2_m_diff_c == "" // excl. low coverage countries 
corr effort2_m_diff_b pv_math_mean_1822_b 
	corr effort2_m_diff_b pv_math_mean_1822_b if cnt != "C268" // excl. outlier
	corr effort2_m_diff_b pv_math_mean_1822_b if effort2_m_diff_c == "" // excl. low coverage countries 


tw scatter  pv_math_mean_1822_b effort2_m_diff_b, m(i) mlabel(cnt) mlabpos(0) xtitle("Change in effort spent on high-stakes tests") ytitle("Change in PISA mathematics scores") title("Self-reported effort and performance changes (18-22)") name(effort2_math, replace)

tw scatter  pv_math_mean_1822_b effort2_m_diff_b if cnt != "C268" , m(i) mlabel(cnt) mlabpos(0) xtitle("Change in effort spent on high-stakes tests") ytitle("Change in PISA mathematics scores") title("Self-reported effort and performance changes (18-22)") name(effort2_math_2, replace)

****************************************
*** performance by hour of testing  ****
****************************************

cd "$outfile"
foreach year in  2022 2018 1822 { //
	foreach table in scieendurance_`year' mathtrendendurance_`year' pvscieendurance_`year' pvmathendurance_`year' scieendurance_`year' pvreadendurance_`year' { 
			foreach AV in $averages {
				cd "$outfile"
				cntmean, table(`table') cntlist(${`AV'}) cntvar(cnt) label(`AV') missing
				copy `table'_`AV'.dta `table'.dta, replace 	// save with same filename as previously, to allow looping over multiple averages
				erase `table'_`AV'.dta
				}	
		}
	foreach domn in mathtrend scie {
		cd "$outfile"
		pisaexport2, dir($outfile) file(`domn'endurance_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.3`domn'.`year') sort(cnt) select(cnt, $CNT2022 $averages)
		}
	foreach domn in math read scie  {
		cd "$outfile"
	pisaexport2, dir($outfile) file(pv`domn'endurance_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.4`domn'.`year') sort(cnt) select(cnt, $CNT2022 $averages)
	}
}

foreach year in  2022  { //
	foreach table in math`year'endurance_`year' pplusbystage pplusbystage_nm { 
			foreach AV in $averages {
				cd "$outfile"
				cntmean, table(`table') cntlist(${`AV'}) cntvar(cnt) label(`AV') missing
				copy `table'_`AV'.dta `table'.dta, replace 	// save with same filename as previously, to allow looping over multiple averages
				erase `table'_`AV'.dta
				}	
		}
		cd "$outfile"
		pisaexport2, dir($outfile) file(math`year'endurance_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.3math.`year') sort(cnt) select(cnt, $CNT2022 $averages)
		}
		cd "$outfile"
pisaexport2, dir($outfile) file(pplusbystage) directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.5) sort(cnt) select(cnt, $CNT2022 $averages)
		cd "$outfile"
pisaexport2, dir($outfile) file(pplusbystage_nm) directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.5.nm) sort(cnt) select(cnt, $CNT2022 $averages)


****************************************
*** Straightlining  ****
****************************************

cd "$outfile"
foreach year in  2022 2018 1822 { //
	foreach table in rflu_`year' rflu_gender_`year' esl_`year' esl_gender_`year'  { 
			foreach AV in $averages {
				cd "$outfile"
				cntmean, table(`table') cntlist(${`AV'}) cntvar(cnt) label(`AV') missing
				copy `table'_`AV'.dta `table'.dta, replace 	// save with same filename as previously, to allow looping over multiple averages
				erase `table'_`AV'.dta
				}	
		}
		cd "$outfile"
		pisaexport2, dir($outfile) file(rflu_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.6.`year') sort(cnt) select(cnt, $CNT2022 $averages)
		cd "$outfile"
		pisaexport2, dir($outfile) file(rflu_gender_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.7.`year') sort(cnt) select(cnt, $CNT2022 $averages) order(_1_* _0_* _d_*)
		cd "$outfile"
		pisaexport2, dir($outfile) file(esl_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.8.`year') sort(cnt) select(cnt, $CNT2022 $averages)
		cd "$outfile"
		pisaexport2, dir($outfile) file(esl_gender_`year') directory2($export) outfile(I_A8_EFFORT.xlsx) outsheet(I.A8.9.`year') sort(cnt) select(cnt, $CNT2022 $averages) order(_1_* _0_* _d_*)
	}

	
*** figures
cd "$outfile"

local year 2022 
use pvmathendurance_`year' , clear
 merge 1:1 cnt using pvreadendurance_`year', nogen keep(3)
 merge 1:1 cnt using pvscieendurance_`year' , nogen keep(3)
 	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
	foreach domn in math read scie {
	gr bar _d_pv_`domn'_m_b, over(cnt, sort(1) label(angle(90))) name(`domn'decline, replace) xsize(12) ytitle("Difference in PV " "`domn' 2022 (H2 - H1)") nofill
	gr export `domn'decline.png, name(`domn'decline) replace
}
	
pwcorr _d_*b
	
tw scatter _d_pv_math_m_b _d_pv_scie_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("science decline (H2 - H1)") ytitle("math decline (H2 - H1)") title("Academic endurance (2022)") name(endurance_ms, replace)

tw scatter _d_pv_read_m_b _d_pv_scie_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("science decline (H2 - H1)") ytitle("reading decline (H2 - H1)") title("Academic endurance (2022)") name(endurance_rs, replace)

tw scatter _d_pv_math_m_b _d_pv_read_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("reading decline (H2 - H1)") ytitle("math decline (H2 - H1)") title("Academic endurance (2022)") name(endurance_mr, replace)

foreach domn in read math scie {
	egen rank`domn' = rank(_d_pv_`domn'_m_b)
}
egen rank = rowtotal(rank*)


cd "$outfile"
local year "2022"
use pvscieendurance_`year' , clear
 merge 1:1 cnt using scieendurance_`year', nogen keep(3)
 	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)
pwcorr _d_*b

	cd "$outfile"
local year "2022"
use pvmathendurance_`year' , clear
 merge 1:1 cnt using mathtrendendurance_`year', nogen keep(3)
 merge 1:1 cnt using pplusbystage , nogen keep(3)
 	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)

	
pwcorr _d_*b
	
tw scatter _d_pv_math_m_b _d_pv_scie_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("science decline (H2 - H1)") ytitle("math decline (H2 - H1)") title("Academic endurance (2022)") name(endurance_ms, replace)

cd "$outfile"
use rflu_2022 , clear
 merge 1:1 cnt using levels_read_2022, nogen keep(3)
 merge 1:1 cnt using pplusbystage , nogen keep(3)
 	ren cnt fcnt
	merge m:1 fcnt using "V:\PISA_INITIALREPORT_2022\results\Trends\infile\cnt_fcnt", nogen keep(1 3)

	
pwcorr rfluallsame_m_b lp_pv_read_l_m_b
	
tw scatter rfluallsame_m_b lp_pv_read_l_m_b, m(i) mlabel(cnt) mlabpos(0) xtitle("% low-performers") ytitle("rflu straightliners") title("RFLU Patterns") name(endurance_ms, replace)
