*! Date     : 2017-06-30
*! version  : 0.7
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! takes coefficients from -statsby- and time/lags for Newey-West SEs

/* 
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

    syntax varlist [if] [in] [ , estimator(string) options(string) lag(integer 0) iqr sd ]
    marksample touse
    tempname beta VCV
    tempfile coefs
    
    /* use regress as default estimator */
    if "`estimator'" == "" local estimator "regress"

    /* add comma prefix to options */
    if "`options'" != "" local options ", `options'"

    /* for simplicity, optional marginal effects based on either IQR or SD, not both */
    if ("`iqr'" != "") & ("`sd'" != "") {
        display as error "Select either IQR or SD, not both"
    }    
    local dX `iqr' `sd'

    /* check panel and get time variable */
    quietly xtset
    local time `r(timevar)'

    /* parse estimator, y, and X */
    tokenize `varlist'
    local y `1'
    macro shift 1
    local X `*'
    local Xcons `X' cons

    /* run first-stage (cross-sectional) regressions */
    preserve
    if inlist("`estimator'", "regress", "areg") {
        quietly statsby _b e(N) e(r2) if `touse', ///
            by(`time') clear ///
            : `estimator' `y' `X' `options'

        rename _eq2_stat* _stat*
    }
    else if inlist("`estimator'", "probit", "logit", "logistic", "tobit") {
        quietly statsby _b e(N) e(r2_p) if `touse', ///
            by(`time') clear basepop(_n < 1000) ///
            : `estimator' `y' `X' `options'

        /* standardize prefixes */
        if inlist("`estimator'", "logit") {
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

    /* newey is same as regress if lag() is default of zero */
    quietly tsset `time'
    foreach x of local Xcons {
        quietly newey _b_`x', lag(`lag')
        matrix `beta' = nullmat(`beta'), e(b)
        matrix `VCV' = nullmat(`VCV'), e(V)
        if ("`x'" == "cons") local x _cons
        if ("`dX'" == "") {
            local names `names' `x'
        }
        else {
            local names `names' main:`x'
        }
    }

    /* assign optional marginal effects to same matrix */
    /* Example 5 at http://www.stata.com/manuals13/pereturn.pdf */
    if ("`dX'" != "") {
        /* store coefficients, Ns, and R2s to temporary file */
        save "`coefs'"

        /* restore main data, but immediately re-preserve */
        restore, preserve

        /* find cross-sectional IQR or SD */
        collapse (`dX') `X', by(`time')

        /* calculate b hat*IQR (or b hat*SD) for each cross-section */
        local i = 1
        foreach x of local X {
            /* if binary choice model, then return odds ratio exp(beta*x) */
            if inlist("`estimator'", "probit", "logit", "logistic") {
                local bhat = `beta'[1, `i']
                generate _bhat_`x' = exp(`bhat' * `x')
                local note "Note: `dX' model presents mean of cross-sectional exp(b hat*`dX')"
                local ++i
            }
            else {
                matrix list `beta'
                display "`x'"
                local bhat = `beta'[1, `i']
                generate _bhat_`x' = `bhat' * `x'
                local note "Note: `dX' model presents mean of cross-sectional (b hat*`dX')"
                local ++i
            }

            quietly tsset `time'
            quietly newey _bhat_`x', lag(`lag')
            matrix `beta' = nullmat(`beta'), e(b)
            matrix `VCV' = nullmat(`VCV'), e(V)
            if ("`x'" == "cons") local x _cons
            local names `names' `dX':`x'
        }
        
        /* bring back coefficients, Ns, and R2s to temporary file */
        use "`coefs'", clear
    }

    /* to this point VCV is row vector of variances */
    matrix `VCV' = diag(`VCV')

    /* fix matrix names */
    matrix colnames `beta' = `names'
    matrix colnames `VCV' = `names'
    matrix rownames `VCV' = `names'
    /* matrix list `beta' */
    /* matrix list `VCV' */

    /* other descriptives */
    summarize _stat_1, meanonly
    local N = r(sum)
    local T = r(N)
    local df_r = `T' - 1
    local df_m : word count `X'

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
    ereturn local first "`first'"

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
    display as text "`note'"

    /* restores by default */
end
