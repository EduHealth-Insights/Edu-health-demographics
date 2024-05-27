********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Data Preparation all chaptr
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023	
********************************************************
clear 			all
set more 		off, perm

run 			"c:\temp\EnvVol2.do"

** ChapterWELL BEING
********************************************************

local			keepvol2wellbeing "cnt cntschid fcntstuid fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* escs boy lowhighescs iscedlev3 sample_all immback lowhighxescs med_xescs city schlocation private lowhighximmback *lifesat* *satis* *st226* *wb155q* xescs *wb155* anxmat *sdleff belong grosagr"

use 			 `keepvol2wellbeing' using "${confidentialdata}\2022\pisa2022completedata.dta", clear


**Save chapter-specific PISA 2022 dataset
qui compress
save "${infile}/Vol2_wellbeing.dta", replace

** Chapter COVID
********************************************************


local 			keepvol2covid "cnt cntschid cntstuid fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* xescs escs boy lowhighescs iscedlev3 sample_all immback lowhighxescs med_xescs city schlocation private lowhighximmback *st347* *st348* *st349* d_nodevice d_laptop d_phone d_famdev d_schdev st350* *d_less* *d_more* *st351* *st352* *st353* *st354* *st355* *st356* *sc213* *d_owndev* *d_covid* *d_other* *sc214* *sc215* *sc216* *sc217* *sc218* *sc219* *sc220* *sc221* *sc222* *sc223* *d_before* *d_repsonse* *sc224* *probself *sdleff *schsust sample_all *probscri *scsuprted *scsuprt *famsupsl *lifesat *satisfied* anxmat grosagr bsmj d_devi* d_healthprof* *st062* tertiary *skill* *st263* r_lifesat *belong* d_covresp d_covresp0 d_covresp12 d_grade feellah"


use 			 `keepvol2covid' using "${confidentialdata}\2022\pisa2022completedata.dta", clear


*Check/compute nb missings for sc213*
egen sc213both_m = rmiss2(sc213q01ja sc213q02ja)

*create new var that sums sc213* - recoding missings as 0 when at least one item has been answered.
gen sc213q01ja_b=sc213q01ja
recode sc213q01ja_b (.=0) if sc213both_m==1

gen sc213q02ja_b=sc213q02ja
recode sc213q02ja_b (.=0) if sc213both_m==1

gen sc213_both = sc213q01ja_b+sc213q02ja_b


recode st347q01ja (3/6=.), gen(st347q01ja_0d1) //diff 0 to up to 1 month
recode st347q01ja (1 4 5 6=.), gen(st347q01ja_1d3) //diff 1 to up to 3 month
recode st347q01ja (1 2 5 6=.), gen(st347q01ja_3d6) //diff 3 to up to 6 month
recode st347q01ja (1 2 3 6=.), gen(st347q01ja_6d12) //diff 6 to 12 month
recode st347q01ja (1/4=.), gen(st347q01ja_12d13) //diff 12 month to over 1 year

recode st347q01ja (1 2 3 4 5 6= 2) (.=1), gen (st347q01m)
recode st347q02ja (1 2 3 4 5 6= 2) (.=1), gen (st347q02m)

local variables " feellah"
foreach vr of varlist `variables' {
	capture drop sample_`vr'
	gen sample_`vr' = 1
	replace sample_`vr' = 0 if st347q01ja == 1
}


qui compress
qui save "$infile\Vol2_covid", replace


** Chapter LIFE
********************************************************

local			keepvol2life "cnt cntschid fcntstuid fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* xescs escs boy lowhighescs iscedlev3 sample_all immback lowhighxescs med_xescs city schlocation private lowhighximmback *st034* *st038* *st062* *st260* *st261* *st265* *st266* *st267* *st270* *st273* *st300* *sc061* *sc064* *sc192* *sc172* *skipping *tardysd *bull* *feelsafe *schrisk *misssc *belong *relatst teachbeha *st062* *famsup encourpg *belong* *schrisk negsclim *teachsup *disclim d_covid r_lifesat *sdleff* anxmat grosagr bsmj tertiary *satisfied* *st356* *skill* *st263* *healthprof* feellah st347q01ja"

use 			 `keepvol2life' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

local variables " feellah"
foreach vr of varlist `variables' {
	capture drop sample_`vr'
	gen sample_`vr' = 1
	replace sample_`vr' = 0 if st347q01ja == 1
}

qui compress
qui save "$infile\Vol2_life", replace

** Chapter Stratification
********************************************************

local keepvol2stratification "cnt iscedlev cntschid cntstuid xmodalisced fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* escs boy lowhighescs iscedlev3 sample_all immback xescs lowhighxescs med_xescs city schlocation low_pv*math high_pv*math vocational immig private lowhighximmback *st001* st125* st126* *st127* *sc012* *sc042* *pa006* xmodalisced *durecec *preprim *grade* *repeat schsel general *sc185*"


* Use PISA 2022 complete data - contains generated common variables - and save the mini dataset
use 			 `keepvol2stratification' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

recode iscedlev3 (0=1 "isced level 2") (1=0 "isced level 3"), gen(iscedlev2)
recode iscedlev3 (0=1 "isced level 2") (1=2 "isced level 3"), gen(iscedlev23)

qui  compress 
qui save "$infile\Vol2_stratification", replace




** Chapter Resources
********************************************************
local keepvol2resources "cnt cntschid cntstuid fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* escs boy lowhighescs iscedlev3 sample_all immback xescs lowhighxescs med_xescs city schlocation private lowhighximmback *st059* *st294* *st295* *st296* *st322* *st326* *sc002* *sc004* *sc017* *sc018* *sc053* *sc155* *sc168* *sc175* *sc180* *sc181* *sc190* *sc189* *sc212* *ic179* staffshort error* *teachers *fulltime *parttime *proatce *certified propat* *isced* propsupp proadmin promgmt proostaf schsize* stratio* smtratio computeach white projector general *mins *hours *studyhmw mathexc *hours allactiv mactiv edushort *ratcmp* rattab digdvpol ictreg digprep *st273* allstaff  propstaff stuntstaff_ratio totat totstaff r_lifesat stresagr emocoagr *sc190* belong"

* Use PISA 2022 complete data - contains generated common variables - and save the mini dataset
use 			 `keepvol2resources' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

qui compress
qui save "$infile\Vol2_resources", replace



** Chapter Governance
********************************************************

local keepvol2governance "cnt cntschid fcntstuid fregion age st003d02t st003d03t st001d01t st022q01ta st021q01ta w_fstuwt w_fsturwt* pv*math pv*read pv*scie low_* high_* escs boy lowhighescs iscedlev3 sample_all immback xescs lowhighxescs med_xescs city schlocation private lowhighximmback *sc011* *sc013* *sc014* *sc016* *sc032* *sc034* *sc035* *sc037* *sc193* *sc185*  *sc195* *sc198* *sc200* *sc201* *sc202* *pa006* *mentoring *schauto *tchpart *srespcur *srespres *schltype* edulead instlead stdtest tdtest teafdbk dbis* lowhighschauto lowhighsrespcur lowhighsrespres r_lifesat"


* Use PISA 2022 complete data - contains generated common variables - and save the mini dataset
use 			 `keepvol2governance' using "${confidentialdata}\2022\pisa2022completedata.dta", clear



qui compress
qui save "$infile\Vol2_governance", replace


** Create a 2nd specific dataset for Tables 1mod (modal)
********************************************************

* Select Chapter's Specific Variables
local keepvol2modal "cnt cntschid fcntstuid fregion escs xescs schltype private general proat* iscedl sample_all staffshort edushort schsize totmath mclsize stratio smtratio age sc001q01ta sc003* sc018q0* sc176* sc182* st004d01t st022q01ta clsize xmodalisced immig grade r_fulltime r_parttime r_certified r_isced6 w_*"
use 			 `keepvol2modal' using "${confidentialdata}\2022\pisa2022completedata.dta", clear

sort cntschid


preserve
	collapse (sum) w_fstuwt w_fsturwt*, by(cnt cntschid)
	compress
	save stuw, replace
restore


preserve
	collapse (mean) escs xescs schltype private general proat* iscedl staffshort edushort schsize totmath mclsize stratio smtratio age sc001q01ta sc003* sc018q0* sc176* sc182* st004d01t st022q01ta clsize xmodalisced immig grade r_fulltime r_parttime r_certified r_isced6 w_*, by(cnt cntschid)
	drop w_fstuwt w_fsturwt*
	merge m:1 cnt cntschid using stuw, nogen
	recode private (0 = 1) (1 = 0)
	recode schltype (1 = 3) (3 = 1)
	compress
	save school, replace
restore

// database schw 
// cointains replicate school weights, (based on replicate factors computed from student q)

use stuw, clear	
	forval r = 1/80 {
		cap drop rep`r'
		gen rep`r' = w_fsturwt`r' / w_fstuwt
		}
	/// valid replicate factors (from technical report, ch 8): 0.5/1.5, 1.70710/.6464, 0.2929/1.3536
	recode rep* (0/0.4 = 0.2929) (0.4/0.6 = 0.5) (0.6/0.8 = 0.6464) (0.8/1.2 = 1) (1.2/1.4 = 1.3536) (1.4/1.6 = 1.5) (1.5/max = 1.70710)
	*	tab1 rep1-rep5
	drop w_fstu*
	merge 1:1 cnt cntschid using school, keepusing(cnt cntschid w_schgrnrabwt) nogen keep(3)
	gen w_fschwt = w_schgrnrabwt
	forval r = 1/80 {
		gen w_fschrwt`r' = w_schgrnrabwt * rep`r'
		} 
save schw, replace

// merge with school database
	use school, clear
	merge m:1 cnt cntschid using schw, nogen
	save school, replace


** define disadvantaged schools according to various dimensions
preserve
keep cnt xescs w_*
drop if cnt=="C245" //only one cnt has no escs
set seed 6842
foreach disadv of varlist xescs {
	cap drop `disadv'u 
	cap drop `disadv'q
	gen `disadv'u = `disadv' + .000001*runiform() //** add random noise to xescs
	gen `disadv'q = .
	tempvar qq
	levelsof cnt, l(countries) clean
	foreach cnt in `countries' {
		cap drop `qq'
		xtile `qq' = `disadv'u [pw=w_fstuwt] if cnt == "`cnt'", nq(4) 	
		replace `disadv'q = `qq' if !missing(`disadv'u) & cnt == "`cnt'"
		}
	}
	
save tempescs, replace
restore

// final school database
use school, clear
merge m:m cnt using tempescs, nogen
qui compress
qui save "$infile\Vol2_modal", replace

** Create log to say job is done

log using "$logs2\DataPrepVol2_is_done_without_error", text replace

** close log
log close