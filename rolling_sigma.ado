*! Date     : 2016-07-22
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! fast rolling standard deviations

/* 
2016-07-22 v0.1 fork of my rolling_beta Github repository
 */

program rolling_sigma
    version 11.2

    syntax varname(numeric) [, long(integer 36) short(integer 36) faster]

    // dependent and indpendent vars from varlist
    tempvar x 
    tokenize `varlist'
    generate `x' = `1' 

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
    tempvar xs x2s
    
    // cumulative sums
    generate `xs' = sum(`x')
    generate `x2s' = sum(`x' * `x')

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
        generate `ms' = sum(missing(`x'))
        generate obs = len - (`ms' - `ms'[`idl'])

        // sigma
        generate sigma = sqrt((`x2s' - `x2s'[`idl'])/(obs - 1) - ((`xs' - `xs'[`idl'])/obs)*((`xs' - `xs'[`idl'])/obs)*obs/(obs - 1))

        // labels
        label variable sigma "Rolling sigma"
        label variable obs "Observations used"
        label variable len "Window length"

        // return to original state
        drop if missing(`flag')
    }
    else {
        // FAST -- requires constant window

        // observations used
        tempvar ms
        generate `ms' = sum(missing(`x'))
        generate obs = `w' - s`w'.`ms'
        generate len = `w'

        // sigma
        generate sigma = sqrt(s`w'.`x2s'/(obs - 1) - (s`w'.`xs'/obs)*(s`w'.`xs'/obs)*obs/(obs - 1))

        // labels
        label variable sigma "Rolling sigma"
        label variable obs "Observations used"
        label variable len "Window length"
    }

end
