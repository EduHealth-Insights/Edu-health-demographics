clear all
set more off, perm

********************************************************************************
**																			  **
**  Clean All Stata Files files												  **
**																			  **
** Creation Date: 01/01/2023												  **
** Author: PISA Team, OECD													  **
** Last Modification: 31/12/2023										  	  **
**																			  **
********************************************************************************


********************************************************************************
** Define location of folder												  **
********************************************************************************

** Stata Datasets
global pisa2022Stata "C:\temp\PISAsource\2022\"
** Result location
global pisa2022team "C:\temp\PISAsource\2022\"

cd "$pisa2022Stata"

********************************************************************************
** Cleaning STU Datasets													  **
********************************************************************************


cap noisily use "$pisa2022Stata\cy08_ms_stu_qqq.dta", clear

ds, has(vall)
* Find values x if labelled as "Valid Skip", and recode them to a missing value
foreach v in `r(varlist)' {
	foreach x in 5 95 995 9995 99995 999995 9999995 99999995 999999995  { 
	local lbl : label (`v') `x'
	*  di "`lbl'"
	   if `"`lbl'"' == "Valid Skip" { 
		replace `v' = .v if `v' == `x' 
		local label : value label `v' 
		label def `label' .v "Valid skip", modify
		}
	}
	* Find values x if labelled as "Not Reached", and recode them to a missing value
	foreach x in 6 96 996 9996 99996 999996 9999996 99999996 999999996 { 
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Not Reached" { 
		replace `v' = .r if `v' == `x' 
		local label : value label `v'
		label def `label' .r "Not reached", modify 
		local newname = substr("`f'",1,length("`f'")-4)
		}
	}
	* Find values x if labelled as "Not applicable", and recode them to a missing value
	foreach x in 7 97 997 9997 99997 999997 9999997 99999997 999999997 { 
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Not Applicable" { 
		replace `v' = .n if `v' == `x' 
		local label : value label `v' 
		label def `label' .n "Not applicable", modify
		}
	}
	* Find values x if labelled as "Invalid", and recode them to a missing value	
		foreach x in 8 98 998 9998 99998 999998 9999998 99999998 999999998 { 
		  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Invalid" { 
		replace `v' = .i if `v' == `x' 
		local label : value label `v' 
		label def `label' .i "Invalid", modify 
		}
	}
	* Find values x if labelled as "No Response", and recode them to a missing value
	foreach x in 9 99 999 9999 99999 999999 9999999 99999999 999999999 { // identify variables where code x9 corresponds to "valid skip"
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "No Response" { 
		replace `v' = .m if `v' == `x' 
		local label : value label `v' 
		label def `label' .m "No response", modify
		}
	}
}


* Save Into appropriate folder with pisa2022 name

save "$pisa2022team\pisa2022student.dta", replace





********************************************************************************
** Cleaning SCH Datasets													  **
********************************************************************************


cap noisily use "$pisa2022Stata\cy08_ms_sch_qqq.dta", clear
ds, has(vall)
* Find values x if labelled as "Valid Skip", and recode them to a missing value
foreach v in `r(varlist)' {
	foreach x in 5 95 995 9995 99995 999995 9999995 99999995 999999995  { 
	local lbl : label (`v') `x'
	*  di "`lbl'"
	   if `"`lbl'"' == "Valid Skip" { 
		replace `v' = .v if `v' == `x' 
		local label : value label `v' 
		label def `label' .v "Valid skip", modify
		}
	}
	* Find values x if labelled as "Not Reached", and recode them to a missing value
	foreach x in 6 96 996 9996 99996 999996 9999996 99999996 999999996 { 
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Not Reached" { 
		replace `v' = .r if `v' == `x' 
		local label : value label `v'
		label def `label' .r "Not reached", modify 
		local newname = substr("`f'",1,length("`f'")-4)
		}
	}
	* Find values x if labelled as "Not applicable", and recode them to a missing value
	foreach x in 7 97 997 9997 99997 999997 9999997 99999997 999999997 { 
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Not Applicable" { 
		replace `v' = .n if `v' == `x' 
		local label : value label `v' 
		label def `label' .n "Not applicable", modify
		}
	}
	* Find values x if labelled as "Invalid", and recode them to a missing value	
		foreach x in 8 98 998 9998 99998 999998 9999998 99999998 999999998 { 
		  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "Invalid" { 
		replace `v' = .i if `v' == `x' 
		local label : value label `v' 
		label def `label' .i "Invalid", modify 
		}
	}
	* Find values x if labelled as "No Response", and recode them to a missing value
	foreach x in 9 99 999 9999 99999 999999 9999999 99999999 999999999 { // identify variables where code x9 corresponds to "valid skip"
	  local lbl : label (`v') `x'
	 * di "`lbl'"
	   if `"`lbl'"' == "No Response" { 
		replace `v' = .m if `v' == `x' 
		local label : value label `v' 
		label def `label' .m "No response", modify
		}
	}
}


* Save Into appropriate folder with pisa2022 name

save "$pisa2022team\pisa2022school.dta", replace