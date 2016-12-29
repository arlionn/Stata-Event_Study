*! Date     : 2016-12-11
*! version  : 0.4
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! takes coefficients from -statsby- and time/lags for Newey-West SEs

/* 
2016-12-11 v0.4 unique name for average R2
2016-07-21 v0.3 option to save first-stage results
2016-07-20 v0.2 more flexible, allows arbitrary first-stage regression
2016-07-18 v0.1 first upload to GitHub
 */

program define fm, eclass 
    version 13

    syntax [if] [in], first(string) [lags(integer 0) file(string) replace]
    marksample touse
    tempname beta VCV

    // statsby clears data
    preserve

    // check panel and get time variable
    quietly xtset
    if ("`r(timevar)'" == "") {
        display as error "index variable not found"
        exit 111
    }
    local time "`r(timevar)'" 

    // parse estimator, y, and X
    local estimator : word 1 of `first'
    local varlist : subinstr local first "`estimator'" "", word
    local y : word 1 of `varlist'
    local X0 : subinstr local varlist "`y'" "", word
    local comma = strpos("`X0'", ",")
    if (`comma' == 0) {
        local X "`X0'"
    }
    else {
        local X = substr("`X0'", 1, `comma'-1)
    }

    // run first-stage regressions
    if inlist("`estimator'", "probit", "logit", "logistic") {
        quietly statsby _b e(N) e(r2_p) if `touse', clear by(`time') ///
            basepop(_n < 1000) : `first'
        rename `y'* *
    }
    else if inlist("`estimator'", "tobit") {
        quietly statsby _b e(N) e(r2_p) if `touse', clear by(`time') ///
            basepop(_n < 1000) : `first'
        rename model* *
        rename _eq3* _eq2*
    }
    else if inlist("`estimator'", "regress") {
        quietly statsby _b e(N) e(r2) if `touse', clear by(`time') : `first'
    }
    else {
        display as error "estimator `estimator' not recognized"
        exit 111
    }

    // save first-stage results to file
    if ("`file'" != "") {
    	display "saving first-stage results"
	    save "`file'", `replace'
    }

    // always use Newey-West SEs 
    // (same as regress if lags is default of zero)
    quietly tsset `time'
    foreach v of varlist _b* {
        quietly newey `v', lag(`lags')
        matrix `beta' = nullmat(`beta'), e(b)
        matrix `VCV' = nullmat(`VCV'), e(V)
    }
    matrix `VCV' = diag(`VCV')

    // other descriptives
    summarize _eq2_stat_1, meanonly
    local N = r(sum)
    local T = r(N)
    local df_r = `T' - 1
    local df_m : word count `X'
    summarize _eq2_stat_2, meanonly
    local r2_avg = r(mean)

    // fix matrix names
    local names = "`X' _cons"
    matrix colnames `beta' = `names'
    matrix rownames `beta' = `y'
    matrix colnames `VCV' = `names'
    matrix rownames `VCV' = `names'

    // preserved before statsby call
    restore

    // store results 
    ereturn post `beta' `VCV', depname(`y') obs(`N') esample(`touse')
    ereturn scalar df_m = `df_m'
    ereturn scalar df_r = `df_r'
    ereturn local T = `T'
    ereturn scalar r2_avg = `r2_avg'
    ereturn local cmd "fm"
    ereturn local vce "Newey-West (1987) with `lags' lags"
    local title "Fama-Macbeth (1973) regression with Newey-West (1987) standard errors (`lags' lags)"
    ereturn local title `title'
    ereturn local first "`first'"

    // must be after posting other results
    quietly test `X'
    ereturn scalar F = r(F)
    ereturn scalar p = fprob(e(df_m), e(df_r), e(F))

    // display results
    display _newline
    display "`title'"
    display _column(42) "First-stage estimator is `estimator'"
    display _column(42) "Number of observations"    _column(67) " = " %9.0fc e(N)
    display _column(42) "Number of panels"          _column(67) " = " %9.0fc e(T)
    display _column(42) "F(" %2.0f e(df_m) ", " %4.0f e(df_r) ")" ///
                                                    _column(67) " = " %9.3fc e(F)
    display _column(42) "Prob > F"                  _column(67) " = " %9.3fc fprob(e(df_m), e(df_r), e(F))
    display _column(42) "Average R-squared"         _column(67) " = " %9.3fc e(r2_avg)
    ereturn display

end
