clear all
cd  "/Users/luigi/Library/Mobile Documents/com~apple~CloudDocs/Econometrics 2/Part 2/Problem set/PS6"

import excel "berkeley.xls",clear


drop if _n==7
rename(A B C D E F)(department gender admit deny total per_admitted)


	tab department, gen(field)
	g male=gender=="Men"
	
	gen n=_n
	expand 2, gen(accept)

	sort n accept
	forvalues i= 1(2)23 {
	expand deny in `i'
	
	}
	
	forvalues i= 2(2)24 {
	expand admit in `i'
	
	}
	
	disp _N // 4527
	
	*f
	
	reg accept male field1-field6, cluster(department)

	*coefficinet is -0.018
	
	
************************************************************************+
*Q2

use 	"datarest.dta", clear

	tabl disabtrn
	tabl disabwrk
	gen dis=1 //generating health variable
	replace dis=0 if disabtrn==1 | disabwrk==1
	
	tabl educrec
	gen edy=0 if educrec==1
	replace edy=4 if educrec==2
	replace edy=8 if educrec==3
	replace edy=9 if educrec==4
	replace edy=10 if educrec==5
	replace edy=11 if educrec==6
	replace edy=12 if educrec==7
	replace edy=15 if educrec==8
	replace edy=16 if educrec==9


	*Dummy for married
	tabl marst
	gen mar=0
	replace mar=1 if marst==1
	
	drop if region==42
	
	tab region, gen(regio)
	
	*not clear what to do w unidentifiable metropolitan status-i exlude people w it
	drop if metro==0
	gen SMSA=metro==2
	
	keep if birthyear>1929 & birthyear<1940
	keep if race==1 // keeping whites
	drop if bpl>=90 //keeping people born in one of 50 states
	tab birthyear, gen(dob)
	
************************************	
*h OLS regression	
************************************
	eststo clear
	reg dis i.educrec, r
	eststo ols1
	
	reg dis i.educrec SMSA mar i.region,r
	eststo ols2
	
	reg dis i.educrec SMSA mar i.region dob*,r
	eststo ols3

	esttab * 

	
	eststo clear
	reg dis educrec, r
	eststo ols1
	
	reg dis educrec SMSA mar i.region,r
	eststo ols2
	
	reg dis educrec SMSA mar i.region dob*,r
	eststo ols3

	esttab * 

************************************	
*j 2sLS regression	
************************************	
	
	*no covariates
	xi:ivregress 2sls dis  (educrec=i.birthqtr), r
	eststo iv1 
estat firststage	
	*year of birth covariates
	xi:ivregress 2sls dis i.birthyear (educrec=i.birthq i.birthyear),r
	eststo iv2
estat firststage	
	*interaction instrument
	xi:ivregress 2sls dis i.birthyear (educrec=i.birthq*i.birthyear i.birthyear),r
	
	eststo iv3
estat firststage	

	*interaction bpl //doesn't work
	
	*xi:ivregress 2sls dis i.birthyear i.bpl (educrec=i.bpl*i.birthyear),r
	*eststo iv4

	*table
	esttab ols* iv*, keep (educrec)
