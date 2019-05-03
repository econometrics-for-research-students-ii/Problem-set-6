***********************************************
* Problem set 3, Econometrics
***********************************************

clear
clear all
cd "/Users/giacomomangiante/Desktop/Zurich/Semester II/Econometrics/part 2/PS 2/"

***********************************************
* 6.1
***********************************************
import excel "./berkeley.xls", sheet("Sheet1") clear 
drop if A == ""
gen male = B == "Men"

* b)
bys B: egen tot_ad = sum(C)
bys B: egen tot = sum(E)
gen share_ad = tot_ad/tot

* d) see Excel file

* f)
quietly tab A, gen(dum)
drop dum1

preserve
expand 2
gen accept = _n <= 12

reg accept male dum*
estimates store regf1
restore

reg F male dum* [fw = E]
estimates store regf2

esttab regf2 using "./tables/exf.tex", ///
mtitle("OLS") r2  ///
starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
title(Paramater estimates from OLS \label{tab:exf}) ///
booktabs replace

***********************************************
* 6.2
***********************************************
use "./datarest.dta", clear
set more off

* reduce the sample
keep if birthyear >= 1930 & birthyear <= 1939
keep if sex == 1
keep if race == 1
drop if bpl >= 90
drop if educrec == .

* generate the variables
gen disab = disabtrn == 2 | disabwrk == 2 | disabwrk == 3 | disabwrk == 3| disabwrk == 4
replace disab = . if missing(disabtrn, disabwrk)
drop if disab == .
gen smsa    = metro == 2
gen married = marst == 1
quietly tab region, gen(reg_dum)
drop reg_dum9
quietly tab birthqtr, gen(birth_dum)
drop birth_dum4


* h)
global xvar smsa married reg_dum*

reg disab educrec
estimates store reg1
reg disab educrec $xvar birthqtr
estimates store reg2 
reg disab educrec $xvar i.birthyear
estimates store reg3

esttab reg1 reg2 reg3, cells("b(star label(Coef.) fmt(%9.3f)) ") se noparentheses stats(N r2,fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) 

esttab reg1 reg2 reg3 using "./tables/2a.tex", ///
keep(educrec $xvar) mtitle("OLS 1" "OLS 2" "OLS 3") ///
starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
title(Paramater estimates from OLS \label{tab:2a}) ///
alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace

* j)
ivregress 2sls disab (educrec = birth_dum*)
estimates store tsls1
ivregress 2sls disab $xvar i.birthyear (educrec = birth_dum*)
estimates store tsls2
ivregress 2sls disab $xvar i.birthyear (educrec = birth_dum*#i.birthyear)
estimates store tsls3
ivregress 2sls disab $xvar i.birthyear ib56.bpl (educrec = birth_dum*#ib56.bpl)
estimates store tsls4

esttab reg1 reg2 reg3 tsls1 tsls2 tsls3 tsls4, keep(educrec $xvar) cells("b(star label(Coef.) fmt(%9.3f)) ") se noparentheses stats(N r2,fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) 

esttab reg1 reg2 reg3 tsls1 tsls2 tsls3 tsls4 using "./tables/3a.tex", ///
mtitle("OLS 1" "OLS 2" "OLS 3" "IV 1" "IV 2" "IV 3" "IV 4") ///
keep(educrec $xvar) starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
title(Paramater estimates from OLS and IV \label{tab:3a}) ///
alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace

* k)
reg educrec birth_dum* 
testparm birth_dum*

reg educrec birth_dum* $xvar i.birthyear
testparm birth_dum* $xvar i.birthyear

reg educrec birth_dum*#i.birthyear $xvar
testparm birth_dum*#i.birthyear $xvar
 
reg educrec birth_dum*#ib56.bpl i.birthyear $xvar
testparm birth_dum*#ib56.bpl i.birthyear $xvar








