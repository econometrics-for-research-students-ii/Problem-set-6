set more off
use "datarest.dta", clear

gen dis=1 if disabwrk==3 | disabtrn==2 | disabwrk==2
recode dis .=0
label var dis "1=individual reports any type of disability"

gen SMSA=1 if metro==2 
recode SMSA .=0
label var SMSA "1=central city metro area"

gen married=1 if marst==1
recode married .=0
label var married "1=married with spouse present"

tabulate region, generate(region) /*create regional dummies*/
drop region9 /*exclude Pacific Division*/

keep if race==1 /*white*/
drop if birthyear>=1940 /*born between 1930 and 1939*/
drop if bpl >= 90

count if disabwrk==. &  disabtrn==. /*check: no missing values for at least one 
										of the two disability variables.*/
count if higraded ==. | educrec==. /*no missing values for years of education*/

tabulate birthyear, generate(birthyear)
tabulate birthqtr, generate(birthqtr)
tabulate bpl, generate(bpl)

eststo m1: reg dis educrec
eststo m2: reg dis educrec married SMSA ib42.region
eststo m3: reg dis educrec married SMSA ib42.region i.birthyear

*no covariates and using the first three quarter of birth dummies as instruments
eststo m4: ivregress 2sls dis (educrec = ib4.birthqtr), first

*With covariates, including also year of birth dummies as covariates and using the quarter of birth dummies as instruments
eststo m5: ivregress 2sls dis SMSA married ib42.region i.birthyear (educrec = ib4.birthqtr SMSA married ib42.region i.birthyear), first

*With covariates, including also year of birth dummies as covariates and using the interaction between quarter of birth dummies and year of birth dummies as instruments,
eststo m6: ivregress 2sls dis SMSA married ib42.region i.birthyear (educrec = ib4.birthqtr##i.birthyear SMSA married ib42.region), first

*With covariates, including also year of birth dummies and state of birth dummies as covariates and using the interaction 
*between quarter of birth dummies and state of birth dummies as instruments
*(for the state of birth dummies use Wyoming as omitted category and include Washington DC)

eststo m7: ivregress 2sls dis SMSA married ib42.region i.birthyear ib56.bpl (educrec = ib4.birthqtr##ib56.bpl SMSA married ib42.region i.birthyear), first

esttab m1 m2 m3 m4 m5 m6 m7 using "exercise_2_regtable.tex", ///
indicate("birth year dummies = *birthyear" "region dummies = *region" ///
 "state dummies = *bpl") ///
addnotes("Notes: (1) to (3) are OLS, (4) to (7) are the second stage from a 2sls IV regression") ///
replace br se star(* 0.10 ** 0.05 *** 0.01) obslast nomtitles  ///
compress longtable 	b(%9.3f) se(%9.3f) 

reg dis birthqtr1 birthqtr2 birthqtr3 educrec
test _b[birthqtr1]=_b[birthqtr2]=_b[birthqtr3]=0
testparm birthqtr*

