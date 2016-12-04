*! Date     : 2016-12-04 
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! makes eststo-able Wilcoxon rank-sum command

/* 

2016-12-04 v0.1 first upload to GitHub

*/

program define Wilcoxon2, eclass 
    version 13

    /* parse syntax */
    syntax varlist [if] [in], by(varname)
    marksample touse

    /* generate matrix of two-tailed p-values */
    local names
    capture matrix drop p
    foreach v of varlist `varlist' {
        ranksum `v' if `touse', by(`by')
        matrix p = nullmat(p), 2*normprob(-abs(r(z)))
        local names `names' "`v'"
    }
    matrix colnames p = `names'

    /* store results */ 
    count if `touse'
    ereturn post , obs(`= r(N)')
    ereturn matrix p = p

end
