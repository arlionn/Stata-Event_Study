// for testing rolling_beta
discard

timer clear

webuse grunfeld, clear
expand 100, generate(new)
bysort company time (new) : generate newsum = sum(new)
egen newcompany = group(newsum company)
xtset newcompany year

// preserve
// timer on 1
// rolling _b, clear window(5) nodots : regress mvalue kstock
// timer off 1
// list in 1/20
// restore

preserve
timer on 2
rolling_beta2 mvalue kstock, window(5)
timer off 2
list in 1/20
restore

preserve
timer on 3
rolling_beta mvalue kstock, long(5) short(5)
timer off 3
list in 1/20
restore

preserve
timer on 4
rolling_beta mvalue kstock, long(5) faster
timer off 4
list in 1/20
restore


timer list

// . timer list
//    1:   1094.44 /        1 =    1094.4420
//    2:      0.14 /        1 =       0.1410
//    3:      0.11 /        1 =       0.1130
//    4:      0.17 /        1 =       0.1730

