*! Date     : 2017-08-11
*! version  : 0.2
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! log transform with options

/* 
2017-08-11 v0.2 added "same label" option to not add "log(.)" to label
2016-07-22 v0.1 
*/

program define log_transform
    version 13.1
    syntax varlist(numeric) [ , add(real 0) samelabel ]
    
    foreach v of local varlist {

        /* transform */
        generate log`v' = log(`add' + `v')

        /* labels */
        local name : variable label `v'

        if ("`name'" != "") & ("`samelabel'" == "") {
            if (`add' > 0) local name "`add' + `name'"
            label variable log`v' "log(`name')" 
        }

        if ("`samelabel'" != "") {
            if ("`name'" == "") local name `v'
            label variable log`v' "`name'"

            if (`add' > 0) local name "`add' + `name'"
            notes log`v' : "log`v' is log of `name'" 
        }
    }

end
