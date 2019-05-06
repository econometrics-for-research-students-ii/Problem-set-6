import excel "berkeley_ATE_ATT.xls", sheet("f") firstrow clear
expand n

gen A = field=="A"
gen B = field=="B"
gen C = field=="C"
gen D = field=="D"
gen E = field=="E"
gen F = field=="F"

reg accept male B C D E F, robust
