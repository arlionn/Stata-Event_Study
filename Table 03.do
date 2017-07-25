/* simple regressions */

/* {{{ Comments


}}} */

/* {{{ regressions---linear */

eststo clear

regress y x, vce(robust)
eststo

/* }}} */

/* {{{ tables---linear */

/* macros for tables */
local screen label wrap
/* local depvar : variable label payer */
/* local groups /// */
/*   mgroups("`depvar'", /// */
/*     pattern(1 0 0 0 0 0 0 0) /// */
/*     prefix(\multicolumn{@span}{c}{) suffix(}) /// */
/*     span erepeat(\cmidrule(lr){@span})) */ 
local latex replace booktabs width(\hsize)

/* write to screen/file */ 
esttab, `screen'
esttab using "Table_03.tex", `screen' `groups' `latex' 

esttab, beta `screen'
esttab using "Table_03_beta.tex", beta `screen' `groups' `latex' 

/* }}} */

