********HEALTH/EDUCATION**************
*********SAMPLE***********
*restricting sample for males, born between [1930,1939]
keep if sex==1 & birthyear>=1930 & birthyear<=1939 & race==1

*dropping the variables that correspond to the wrong district
drop if bpl>=90

*dropping for a missing education
drop if missing(educrec)

*dropping for a missing either of two disabilities
drop if missing(disabwrk| disabtrn)

*****VARIABLES**********

*generating health variable
gen health=0 if disabwrk!=2 & disabwrk!=3 & disabtrn!=2

*replacing missing values with zeros in health variable
replace health = 1 if (health >= .)

*generating some covariates accroding to the exercise
gen SMSA=1 if metro==2
gen married=1 if marst==1

*replacing missing values with zeros
replace SMSA = 0 if (SMSA >= .)
replace married = 0 if (married >= .)

*generating 9 regional dummies (further will exclude Pacific Deivision)
*quietly tabulate region, generate(g)

*generating year of birth dummies
*quietly tabulate birthyear, generate(by)

*generating birth date dummy
*quietly tabulate birthqtr, generate(bq)

*generating birth region dummies
*quietly tabulate bpl, generate(bp)

*******OLS REGRESSIONS**************
eststo x1: quietly reg health educrec
eststo x2: quietly reg health educrec SMSA married ib42.region birthqtr
eststo x3: quietly reg health educrec SMSA married ib42.region i.birthyear
esttab x1 x2 x3 using example.tex, label replace booktabs title(Regression table\label{tab1})


*******2SLS REGRESSIONS**************
eststo x1: quietly ivregress 2sls health (educrec = ib4.birthqtr)
eststo x2: quietly ivregress 2sls health SMSA married ib42.region i.birthyear (educrec = ib4.birthqtr)
eststo x3: quietly ivregress 2sls health SMSA married ib42.region i.birthyear (educrec = ib4.birthqtr#i.birthyear)
eststo x4: quietly ivregress 2sls health SMSA married ib42.region i.birthyear ib56.bpl (educrec = ib4.birthqtr#ib56.bpl)
esttab x1 x2 x3 x4 using example.tex, label replace booktabs title(Regression table\label{tab1})

**************First-stage************************************
eststo x1: quietly reg educrec ib4.birthqtr
testparm ib4.birthqtr
eststo x2: quietly reg educrec ib4.birthqtr SMSA married ib42.region i.birthyear
testparm ib4.birthqtr
eststo x3: quietly reg educrec ib4.birthqtr#i.birthyear SMSA married ib42.region i.birthyear
testparm ib4.birthqtr#i.birthyear
eststo x4: quietly reg educrec ib4.birthqtr#ib56.bpl SMSA married ib42.region i.birthyear ib56.bpl
testparm ib4.birthqtr#ib56.bpl
esttab x1 x2 x3 x4 using example.tex, label replace booktabs title(Regression table\label{tab1})
