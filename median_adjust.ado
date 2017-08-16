*! Date     : 2017-08-11
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! median adjust by groups

/* 
2017-08-11 v0.1 
*/

program define median_adjust
    version 13.1
    syntax varlist(numeric), Groups(varlist) [ Prefix(string) Suffix(string) ]
    
    foreach v of local varlist {

        /* adjust */
        bysort `groups' : egen med`v' = median(`v')
        generate adj`v' = `v' - med`v'
        drop med`v'

        /* labels */
        local label : variable label `v'
        if ("`prefix'" != "") | ("`suffix'" != "") {
            label variable adj`v' "`prefix'`label'`suffix'"
        }
        else {
            label variable adj`v' "Adjusted `label'"
        }
    }

end
