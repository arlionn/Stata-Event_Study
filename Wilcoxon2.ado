*! Date     : 2016-12-02
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! makes eststo-able Wilcoxon rank-sum command

/* 

2016-07-18 v0.1 first upload to GitHub

*/

program define Wilcoxon2, eclass 
    version 13

    syntax varlist [if] [in], by(varname)
    marksample touse

    local names
    foreach v of varlist `varlist' {
        ranksum `v' if `touse', by(`by')
        matrix p = nullmat(p), 2*normprob(-abs(r(z)))
        local names `names' "`v'"
    }
    matrix colnames p = `names'
    /* matrix b = p */

    // store results 
    ereturn post 
    ereturn matrix p

end
