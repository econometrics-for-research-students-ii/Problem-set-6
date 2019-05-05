*==============================================================
*This code is for Econometrics -2 PS6

*Date: 01/May/2019
*Author: Krishna Srinivasan 
*krishna.srinivasan@econ.uzh.ch

*==============================================================

***************************************************************
*                      Initialize 
***************************************************************
version 14
set more off

local dir : pwd
cd `dir'


***************************************************************
*                    Problem 6.1
***************************************************************
import excel "Berkeley.xls", clear
encode B, generate(male)  
replace male = 0 if male ==2

encode A, generate(major)

rename B applicants
rename C admit
rename D deny 
rename E total 
rename F pc_admit_field

drop if admit ==. 
drop A applicants

*******************************
*a) 
*******************************
*Total of men 
summ total if male==1 
scalar total_men=r(sum)

*Total of women
summ total if male==0 
scalar total_women=r(sum)

*Total of admitted men
summ admit if male==1 
scalar total_admit_men=r(sum)

*Total of admitted women
summ admit if male==0 
scalar total_admit_women=r(sum)

display total_admit_men/total_men
display total_admit_women/total_women

*Compute ATE is the pc admitted men - pc admitted women
scalar ate = total_admit_men/total_men - total_admit_women/total_women
display ate 

*******************************
*d) 
*******************************

preserve 
********ATE 

*Reshape the data 
reshape wide admit deny total pc_admit_field, i(major) j(male)

*Generate treatment effect as the difference in percentage admitted
g effect_raw = pc_admit_field1-pc_admit_field0

*Generate ATE wights as number in field/total in the sample 
egen total_major = rowtotal(total0 total1)
egen total = sum(total_major)
g atewt = (total_major)/total

*Create a variable which is the product of raw effect and ATE weights
g effect_atewt = effect_raw*atewt

* Identify ATE
egen ate_d = sum(effect_atewt)

********ATT
*Generate ATT wights as number of men in the field/total of men 
egen total_men = sum(total1)
g attwt = total1/total_men

*Create a variable which is the product of raw effect and ATE weights
g effect_attwt = effect_raw*attwt

* Identify ATT
egen att_d = sum(effect_attwt)

restore 

*******************************
*f) 
*******************************
expand 2
g n= _n 
g accept =1
replace accept = 0 if n>12

*create sample size 
g sample = admit 
replace sample = deny if accept==0

reg accept male i.major [fw=sample]
eststo olsb

esttab olsb using "2b.tex", ///
cells(b(star fmt(3)) se(fmt(3) par)) ///
starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
title(Parameter estimates from 2b \label{tab:2d}) ///
alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace

***************************************************************
*                   Problem 6.2 
***************************************************************
use "datarest.dta", clear 

tab disabwrk, nolabel
tab disabtrn, nolabel

*Dummy that takes 0 if no disability and 1 if any disability 
g disab = cond(disabwrk==1 & disabtrn==1,0,1)
tab disab

*data cleaning 
keep if birthyear >= 1930 & birthyear <=1939 
keep if race ==1
drop if bpl >= 90
drop if educrec ==.
drop if disab ==.

*generating dummies 
tab metro, nolabel
tab metro

g SMSA = cond(metro==2,1,0)
tab SMSA

tab marst
g married = cond(marst==1,1,0)
tab married


******************************
*g) 
*******************************
reg disab educrec 
estimates store g1

reg disab educrec SMSA married b42.region 
estimates store g2 

reg disab educrec SMSA married b42.region i.birthyear
estimates store g3


******************************
*h) 
*******************************

ivregress 2sls disab (educrec = b4.birthqtr), first 
estimates store h1

ivregress 2sls disab SMSA married b42.region i.birthyear  /// 
(educrec = b4.birthqtr SMSA married b42.region i.birthyear ), first 
estimates store h2

ivregress 2sls disab SMSA married b42.region i.birthyear ///
(educrec = b4.birthqtr##i.birthyear SMSA married b42.region), first
estimates store h3

ivregress 2sls disab SMSA married b42.region i.birthyear b56.bpl ///
(educrec = b4.birthqtr##b56.bpl SMSA married i.birthyear), first
estimates store h4

esttab g1 g2 g3 h1 h2 h3 h4 using 2g.tex, ///
cells(b(star fmt(3)) se(fmt(3) par)) ///
starlevels( ^{*} 0.10 ^{**} 0.05 ^{***} 0.010) ///
indicate("birthyear dum = *birthyear" "region dum = *region" ///
 "state dumm = *bpl") ///
title(OLS for question 2g and 2h \label{tab:2g}) ///
alignment(@{}l*{8}{D{.}{.}{3}}@{}) booktabs replace ///
addnotes("Notes: (1) -(3) are OLS, (4)-(6) are the second stage from a 2sls") ///
star(*0.1 **0.05 ***0.01)
