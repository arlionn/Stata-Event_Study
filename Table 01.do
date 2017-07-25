/* summary statistics */

/* {{{ Comments 


}}} */

/* {{{ run tables once, then use macros to print several versions */

/* simple descriptives for key variables */
describe $MEANS
tabstat $MEANS, stat(iqr sd N) columns(statistics)
unique dateYM

eststo clear

/* full sample */
estpost summarize $MEANS, detail
eststo, title("Full Sample")

/* /1* payers *1/ */
/* estpost summarize $MEANS if payer, detail */
/* eststo, title("Dividend Payers") */

/* /1* payers *1/ */
/* estpost summarize $MEANS if !payer, detail */
/* eststo, title("Dividend Nonpayers") */

/* }}} */

/* {{{ combined tables */

/* macros for combined tables */
local screen ///
    wrap ///
    cell("count(fmt(%9.3g) label(Count)) mean(fmt(%9.3f) label(Mean)) p50(label(Median)) sd(label(Std. Dev.))") ///
    label nonumbers noobs
/* local groups /// */
/*     nomtitles /// */
/*     mgroups("Full Sample" "Dividend Payers" "Dividend Nonpayers", /// */
/*     pattern(1 1 1) /// */
/*     prefix(\multicolumn{@span}{c}{) suffix(}) /// */
/*     span erepeat(\cmidrule(lr){@span})) */  
local latex replace booktabs width(\hsize)

/* tables */
esttab, `screen'
esttab using "Table_01.tex", `screen' `groups' `latex'
/* esttab est2 est3 using "Table_01_small.tex", `screen' `groups' `latex' */

/* }}} */

/* /1* {{{ full tables *1/ */

/* /1* macros for full tables *1/ */
/* local screen /// */
/*     wrap /// */
/*     cell("count(fmt(%12.3gc) label(Obs.)) mean(fmt(%9.3f) label(Mean)) sd(fmt(%9.3f) label(Std. Dev.)) p5(fmt(%9.3f) label(5\%)) p25(fmt(%9.3f) label(25\%)) p50(fmt(%9.3f) label(Median)) p75(fmt(%9.3f) label(75\%)) p95(fmt(%9.3f) label(95\%))") /// */
/*     stats(N, fmt(%12.3gc) labels("Observations")) /// */
/*     label nonumbers */
/* local latex replace booktabs width(\hsize) */

/* /1* panel a (all) *1/ */
/* esttab est1, `screen' */
/* esttab est1 using "Table_01a.tex", `screen' `latex' */

/* /1* panel b (payers) *1/ */
/* esttab est2, `screen' */
/* esttab est2 using "Table_01b.tex", `screen' `latex' */

/* /1* panel c (nonpayers) *1/ */
/* esttab est3, `screen' */
/* esttab est3 using "Table_01c.tex", `screen' `latex' */

/* /1* }}} *1/ */

