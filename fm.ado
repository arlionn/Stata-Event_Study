*! Date     : 2017-06-30
*! version  : 0.8
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! takes coefficients from -statsby- and time/lags for Newey-West SEs

/* 
2017-06-30 v0.8 simplified and removed marginal effects
2017-06-30 v0.7 marginal effects use sample bhat
2017-06-29 v0.6 logit/probit models return exp(beta*x) marginal effects
2017-06-28 v0.5 marginal effect options (cross-sectional iqr and sd)
2016-12-11 v0.4 unique name for average R2
2016-07-21 v0.3 option to save first-stage results
2016-07-20 v0.2 more flexible, allows arbitrary first-stage regression
2016-07-18 v0.1 first upload to GitHub
 */

program define fm, eclass 
    version 13

    syntax varlist [if] [in] [ , estimator(string) options(string) lag(integer 0) ]
    marksample touse
    tempname beta VCV
    
    /* regress is default estimator */
    if "`estimator'" == "" local estimator "regress"

    /* add comma prefix to options */
    if "`options'" != "" local options ", `options'"

    /* check panel and get time variable */
    quietly xtset
    local time `r(timevar)'

    /* parse estimator, y, and X */
    tokenize `varlist'
    local y `1'
    macro shift 1
    local X `*'

    /* estimate first-stage (cross-sectional) coefficients */
    preserve
    if inlist("`estimator'", "regress", "areg") {
        quietly statsby _b e(N) e(r2) if `touse', ///
            by(`time') clear ///
            : `estimator' `y' `X' `options'

        /* standardize prefixes */
        rename _eq2_stat* _stat*
    }
    else if inlist("`estimator'", "probit", "logit", "logistic", "tobit") {
        quietly statsby _b e(N) e(r2_p) if `touse', ///
            by(`time') clear basepop(_n < 1000) ///
            : `estimator' `y' `X' `options'

        /* standardize prefixes */
        if inlist("`estimator'", "logit", "logistic") {
            rename `y'_b* _b*
            rename _eq2_stat* _stat*
        }
        else if inlist("`estimator'", "tobit") {
            rename model_b* _b*
            rename _eq3_stat* _stat*
        }
    }
    else {
        display as error "Estimator `estimator' not supported"
        exit 111
    }

    /* estimate time-series means and standard errors */
    /* first independent variables */
    quietly tsset `time'
    foreach x of local X {
        quietly newey _b_`x', lag(`lag')
        matrix `beta' = nullmat(`beta'), e(b)
        matrix `VCV' = nullmat(`VCV'), e(V)
        local names `names' `x'
    }

    /* then intercept */
    quietly newey _b_cons, lag(`lag')
    matrix `beta' = nullmat(`beta'), e(b)
    matrix `VCV' = nullmat(`VCV'), e(V)
    local names `names' _cons

    /* generate covariance matric from row vector */
    matrix `VCV' = diag(`VCV')

    /* assign matrix names */
    matrix colnames `beta' = `names'
    matrix colnames `VCV' = `names'
    matrix rownames `VCV' = `names'
    /* matrix list `beta' */
    /* matrix list `VCV' */

    /* number of observations and panels */
    summarize _stat_1, meanonly
    local N = r(sum)
    local T = r(N)
    local df_r = `T' - 1
    local df_m = colsof(`VCV')

    /* average R-squared */
    summarize _stat_2, meanonly
    local r2_avg = r(mean)

    /* post results */ 
    /* depname(`y') option requires y to be available */
    ereturn post `beta' `VCV', depname("`y'") obs(`N') 
    /* ereturn post `beta' `VCV', depname("`y'") obs(`N') esample(`touse') */
    ereturn scalar df_m = `df_m'
    ereturn scalar df_r = `df_r'
    ereturn scalar T = `T'
    ereturn scalar r2_avg = `r2_avg'
    ereturn local cmd "fm"
    ereturn local vce "Newey-West (1987) with `lag' lag"
    local title "Fama-Macbeth (1973) regression with Newey-West (1987) standard errors (`lag' lag)"
    ereturn local title `title'

    /* must be after posting other results */
    quietly test `X'
    ereturn scalar F = r(F)
    ereturn scalar p = fprob(e(df_m), e(df_r), e(F))

    /* display results */
    display as text "`title'"
    display _column(42) as text "First-stage estimator is `estimator'"
    display _column(42) as text "Number of observations"    _column(67) " = " as result %9.0gc e(N)
    display _column(42) as text "Number of panels"          _column(67) " = " as result %9.0gc e(T)
    display _column(42) as text "F(" %2.0f e(df_m) ", " %4.0f e(df_r) ")" _continue
    display                                                 _column(67) " = " as result %9.3gc e(F)
    display _column(42) as text "Prob > F"                  _column(67) " = " as result %9.3f fprob(e(df_m), e(df_r), e(F))
    display _column(42) as text "Average R-squared"         _column(67) " = " as result %9.3f e(r2_avg)
    ereturn display

end
