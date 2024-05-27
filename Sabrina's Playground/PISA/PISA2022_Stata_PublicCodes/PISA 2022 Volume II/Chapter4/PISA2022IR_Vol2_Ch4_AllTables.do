********************************************************
*** PISA 2022 RESULTS: VOLUME II
*** Tables for  Ch4
** Creation Date: 01/01/2023												 
** Author: PISA TEAM, OECD													  
** Last Modification: 31/12/2023
********************************************************

** Load env

run 			"c:\temp\Do-files\EnvVol2.do"

** Load dataset

use 			"$infile/pisa2022completedata.dta", clear

** go to outfile folder

cd "$outfile"

** Table II.B1.4.1

See Table II.B1.1.1 Variable: preprim

** Table II.B1.4.2

See Table II.B1.1.2 Variable: d_preprim

** Table II.B1.4.3

See Table II.B1.1.3 Variable: d_preprim

** Table II.B1.4.4

See Trend tables

** Table II.B1.4.5

See Table II.B1.1.8 Variable:durecec preprim

** Table II.B1.4.6

** Table II.B1.4.7

See Table II.B1.1.1 Variable: r_st001, grade_modal, iscedlev3

** Table II.B1.4.8

See Table II.B1.1.2 Variable: db_grade

** Table II.B1.4.9

See Table II.B1.1.2 Variable: da_grade

** Table II.B1.4.10

See Table II.B1.1.1 Variable:repeat, st127

** Table II.B1.4.11

See Table II.B1.1.2 Variable: repeat

** Table II.B1.4.12

See Table II.B1.1.3 Variable: repeat

** Table II.B1.4.13

See Trend tables

** Table II.B1.4.14

See Table II.B1.1.8 Variable: repeat d_st127

** Table II.B1.4.15

See Table II.B1.1.9 Variable: repeat xd_st127

** Table II.B1.4.16

See Table II.B1.1.1 Variable: repeat, boy immig low@math read scie ess belong bullied

** Table II.B1.4.17

repest PISA, estimate (stata: normexposure immig fcntstuid cntschid, flag) by(cnt) outfile(isol_immig, replace) pisacoverage flag
// same with escs pv@math boys and schools variables

** Table II.B1.4.18

See Table II.B1.1.1 Variable: sc211

** Table II.B1.4.19

See Table II.B1.1.1 Variable: general iscedlev2 iscedlev3

** Table II.B1.4.20

See Table II.B1.1.2 Variable: general

** Table II.B1.4.21

See Table II.B1.1.2 Variable: vocational

** Table II.B1.4.22

See Table II.B1.1.3 Variable: general

** Table II.B1.4.23

See Table II.B1.1.3 Variable: vocational

** Table II.B1.4.24

See Trend tables.

** Table II.B1.4.25

See Table II.B1.1.8 Variable: general

** Table II.B1.4.26

See Table II.B1.1.1 Variable: sc042

** Table II.B1.4.27

See Table II.B1.1.3 Variable:d_sc042q01

** Table II.B1.4.28

See Table II.B1.1.3 Variable:d_sc042q02

** Table II.B1.4.29

See Trend Tables

** Table II.B1.4.30

See Table II.B1.1.8 Variable: d_sc042
