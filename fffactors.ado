*! Date     : 2017-09-14
*! version  : 0.4
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get Fama-French factors from French Data Library

/* 
2017-09-14 v0.4 added momentum factor, simplified code
2017-08-17 v0.3 more consistent date names
2017-08-04 v0.2 fixed date label, display summary statistics
2016-09-02 v0.1 first upload to GitHub
*/

program define fffactors

    version 13.1
	syntax , clear
    
    /* {{{ 3-factor file */

	/* get 3-factor file */
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_CSV.zip"
	copy "`cloud'" "F-F_Research_Data_Factors_CSV.zip", replace
	unzipfile "F-F_Research_Data_Factors_CSV.zip", replace

	/* read 3-factor file */
	import delimited using "F-F_Research_Data_Factors.CSV" ///
        , `clear' varnames(3) case(preserve) numericcols(_all)
	drop if missing(v1) | (v1 < 190000)

    /* }}} */

    /* {{{ momentum file */
    preserve

	/* get momentum file */
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Momentum_Factor_CSV.zip"
	copy "`cloud'" "F-F_Momentum_Factor_CSV.zip", replace
	unzipfile "F-F_Momentum_Factor_CSV.zip", replace

	/* read momentum file */
	import delimited using "F-F_Momentum_Factor.CSV" ///
        , `clear' varnames(13) case(preserve) numericcols(_all)
	drop if missing(v1) | (v1 < 190000)
    
    /* save momentum to tempfile */
    tempfile Momentum
    save "`Momentum'"
    restore

    /* }}} */

    /* {{{ combine 3 and momentum factors and groom */

    merge 1:1 v1 using "`Momentum'", nogenerate

	/* fix date */
	generate int Date = ym(floor(v1/100), mod(v1, 100)) 
	format Date %tm
    label variable Date "Date"
	drop v1
    order Date

	/* fix labels */
    ds, not(varlabel)
    foreach v in `r(varlist)' {
        label variable `v' "`v'"
	}

    /* }}} */
    
end
