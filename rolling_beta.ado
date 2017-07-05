*! Date     : 2017-07-05
*! version  : 0.6
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! fast rolling regressions (univariate)

/* 
2017-07-05 v0.6 renamed alfa to alpha, removed CAPM references
2016-07-22 v0.5 simplified code (fewer temporary variables)
2016-07-21 v0.4 add min/max with growing windows, count of observations used
2015-11-05 v0.3 
2011-10-15 v0.2 
2011-10-15 v0.1 
 */

program rolling_beta
    version 11.2

    syntax varlist(min=2 max=2 numeric) [ , short(integer 36) long(integer 36) faster ]

    // dependent and indpendent vars from varlist
    tempvar x y 
    tokenize `varlist'
    generate `y' = `1' 
    generate `x' = `2' 


    // faster version uses constant window and lag operators
    if ("`faster'" == "") {
        local l = `long'
        local s = `short'

        // check logical windows
        if (`s' > `l') display as error "long must be >= short" 
        
        // tsfill to use simple subscripting, flag will me missing for fill observations
        tempvar flag
        generate `flag' = 1
        tsfill
    }
    else {
        display "faster option: long window = short window = `long'"
        local w = `long'
    }

    // first round of temporary variables (more below)
    tempvar xs ys xys x2s y2s

    // cumulative sums
    generate `xs' = sum(`x')
    generate `ys' = sum(`y')
    generate `xys' = sum(`x' * `y')
    generate `x2s' = sum(`x' * `x')
    generate `y2s' = sum(`y' * `y')

    if ("`faster'" == "") {
        // SLOW -- allows growing window

        // index lags
        /* 
        ida is absolute id (row number)
        idf is first absolute id for each panel
        idr is relative id (or ida - idf)
        idl is absolute id of correct lag
        */
        tempvar ida idf idr idl
        generate `ida' = _n
        xtset
        bysort `r(panelvar)' (`r(timevar)') : generate `idf' = `ida'[1]
        generate `idr' = `ida' - `idf' + 1
        generate `idl' = cond(`idr' > `l', `ida' - `l', `idf') if (`idr' > `s')
        generate len = `ida' - `idl' 

        // observations used
        tempvar ms
        generate `ms' = sum(missing(`y', `x'))
        generate obs = len - (`ms' - `ms'[`idl'])

        // variances and covariances
        tempvar covxy varx vary
        generate `covxy' = (`xys' - `xys'[`idl'])/(obs - 1) - ((`xs' - `xs'[`idl'])/obs)*((`ys' - `ys'[`idl'])/obs)*obs/(obs - 1)
        generate `varx' = (`x2s' - `x2s'[`idl'])/(obs - 1) - ((`xs' - `xs'[`idl'])/obs)*((`xs' - `xs'[`idl'])/obs)*obs/(obs - 1)
        generate `vary' = (`y2s' - `y2s'[`idl'])/(obs - 1) - ((`ys' - `ys'[`idl'])/obs)*((`ys' - `ys'[`idl'])/obs)*obs/(obs - 1)

        // alpha, beta, r2, s2
        generate beta = `covxy'/`varx'
        generate alpha = ((`ys' - `ys'[`idl']) - beta*(`xs' - `xs'[`idl']))/obs
        generate r2 = `covxy'*`covxy'/`varx'/`vary'
        generate s2 = `vary'*(1 - r2)*(obs - 1)/(obs - 2)

        // labels
        label variable beta "Rolling beta"
        label variable alpha "Rolling alpha"
        label variable r2 "Rolling R2"
        label variable s2 "Rolling S2"
        label variable obs "Observations used"
        label variable len "Window length"

        // return to original state
        drop if missing(`flag')
    }
    else {
        // FAST -- requires constant window

        // observations used
        tempvar ms
        generate `ms' = sum(missing(`y', `x'))
        generate obs = `w' - s`w'.`ms'
        generate len = `w'

        // generate variances and covariances
        tempvar covxy varx vary
        generate `covxy' = s`w'.`xys'/(obs - 1) - (s`w'.`xs'/obs)*(s`w'.`ys'/obs)*obs/(obs - 1)
        generate `varx' = s`w'.`x2s'/(obs - 1) - (s`w'.`xs'/obs)*(s`w'.`xs'/obs)*obs/(obs - 1)
        generate `vary' = s`w'.`y2s'/(obs - 1) - (s`w'.`ys'/obs)*(s`w'.`ys'/obs)*obs/(obs - 1)

        // generate alpha, beta, r2, s2
        generate beta = `covxy'/`varx'
        generate alpha = (s`w'.`ys' - beta*s`w'.`xs')/obs
        generate r2 = `covxy'*`covxy'/`varx'/`vary'
        generate s2 = `vary'*(1 - r2)*(obs - 1)/(obs - 2)

        // labels
        label variable beta "Rolling beta"
        label variable alpha "Rolling alpha"
        label variable r2 "Rolling R2"
        label variable s2 "Rolling S2"
        label variable obs "Observations used"
        label variable len "Window length"
    }

end
