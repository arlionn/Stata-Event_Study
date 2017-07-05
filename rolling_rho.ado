*! Date     : 2016-07-22
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! fast rolling correlations

/* 
2016-07-22 v0.1 fork of rolling_beta
*/

program rolling_rho
    version 11.2

    syntax varlist(min=2 max=2 numeric) [ , short(integer 36)  long(integer 36) faster ]

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

        // rho
        generate rho = `covxy' / sqrt(`varx' * `vary')

        // labels
        label variable rho "Rolling rho"
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

        // rho
        generate rho = `covxy' / sqrt(`varx' * `vary')

        // labels
        label variable rho "Rolling rho"
        label variable obs "Observations used"
        label variable len "Window length"
    }

end
