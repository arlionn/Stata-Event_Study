*! Date     : 2015-09-14
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! log transform with options

/* 
2016-07-22 v0.1 
 */

program define log_transform
    version 13.1
    syntax varlist(numeric) [, add(real 0)]
    
    foreach v of local varlist {
        // transform
        generate log`v' = log(`add' + `v')

        // labels
        local name : variable label `v'
        if ("`name'" != "") {
            if (`add' > 0) local name "`add' + `name'"
            local name "log(`name')"
            label variable log`v' "`name'" 
        }
    }

end
