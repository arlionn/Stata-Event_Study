*! Date     : 2016-07-29
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! leads, lags, and differences with auto-labels

/* 
2016-07-29 v0.1
 */

program time_transform
	version 13.1
	syntax varlist, Operators(namelist) 

	foreach v of local varlist {
		foreach n of local operators {
			generate `n'`v' = `n'.`v'
			local label : variable label `v'
			label variable `n'`v' "`n'.`label'"
		}
	}
end
