/* correlation matrix */

/* {{{ Comments

}}} */

/* {{{ calculations */

/* generate column labels */
local first : word 1 of $CORRS
local blist "`first'" "(1) "
local wc : word count $CORRS
display "`wc'"
local labs "(1)"
forvalues i = 2/`wc' {
    local labs "`labs'" "(`i')"
    local next : word `i' of $CORRS
	local blist "`blist'" "`next'" "(`i') "
}
display "`labs'"
display "`blist'"

/* determine correlations */
eststo clear
estpost correlate $CORRS, matrix
eststo 

/* }}} */

/* {{{ tables */

/* macros for tables */
local screen ///
    wrap ///
    cells(b(fmt(%9.2f))) ///
    stats(N, fmt(%12.3gc) labels("Observations")) ///
    unstack not nostar compress ///
    label nonumbers nomtitles ///
    varlabels(, blist("`blist'")) ///
    eqlabels("`labs'") ///
    collabels(none)
local latex replace booktabs width(\hsize)

esttab , `screen' 
esttab using "Table_02.tex", `screen' `latex'

/* }}} */

/* /1* {{{ alternate table *1/ */

/* /1* include two variables only *1/ */
/* eststo clear */
/* estpost correlate $CORRS */
/* eststo */

/* local varscorr : subinstr global CORRS "$VARONE" "" */
/* estpost correlate `varscorr' */
/* eststo */

/* /1* macros for tables *1/ */
/* local screen /// */
/*     wrap /// */
/*     cells(rho(fmt(%9.2f))) /// */
/*     stats(N, fmt(%12.3gc) labels("Observations")) /// */
/*     unstack not nostar /// */
/*     label nonumbers nomtitles */
/* local latex replace booktabs width(\hsize) */

/* esttab, `screen' */ 
/* esttab using "Table_02_alt.tex", `screen' `latex' */

/* /1* }}} *1/ */

