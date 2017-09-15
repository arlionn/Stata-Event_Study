*! Date     : 2017-09-15
*! version  : 0.3
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get Fama-French industry data, keep in memory

/* 
2017-09-15 v0.3 smarter industries, simpler keep option, error handling
2017-05-05 v0.2 refactor, adds 12-industry download
2016-08-12 v0.1 original
 */

program ffindustries
	version 13.1

	syntax , clear [ Level(integer 48) KEEPfiles ]

    /* test if industry level is valid */
    if !inlist(`level', 5, 10, 12, 17, 30, 38, 48, 49) {
        display as error ///
            "industry levels are 5, 10, 12, 17, 30, 38, 48, and 49"
        exit 197
    }

    /* /1* T/S *1/ */
    /* local clear clear */
    /* local level 48 */

	/* get file */
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/Siccodes`level'.zip"
	copy "`cloud'" "Siccodes`level'.zip", replace
	unzipfile "Siccodes`level'.zip", replace

	/* read */
	infix ///
            int indNumber 1-2 ///
            str indShort 4-9 ///
            str indLong 11-120 ///
            using "Siccodes`level'.txt", `clear'
    drop if missing(indNumber) & missing(indShort) & missing(indLong)

	/* put long name and SIC range in separate columns */
    generate hasSic = regexm(indLong, "^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]")
    generate sicRange = substr(indLong, 1, 9) if hasSic
    generate sicName = substr(indLong, 10, .) if hasSic

	/* carryforward */
    replace indNum = indNum[_n - 1] if missing(indNum)
    replace indShort = indShort[_n - 1] if missing(indShort)
    bysort indNum : replace indLong = indLong[1] if (_n > 1)

	/* expand */
    drop if missing(sicRange)
	generate sicLow = substr(sicRange, 1, 4)
	generate sicHigh = substr(sicRange, 6, 4)
	destring sicLow sicHigh, replace

    /* create row for every SIC code */
    generate N = (sicHigh - sicLow) + 1
    expand N
    bysort indNumber sicLow : generate sic = sicLow + (_n - 1)
    
    /* code duplicates every industry into "other" */
    sort sic indNum
    duplicates drop sic, force
    sort indNum sic
    
	/* clean up */
    drop hasSic sicLow sicHigh N
	quietly ds, has(type string)
	foreach v of varlist `r(varlist)' {
        replace `v' = strtrim( stritrim( `v' ) )
	}
    format sic %04.0f
	compress

	/* by default, remove files */
	if ("`keepfiles'" == "") {
		rm "Siccodes`level'.txt"
		rm "Siccodes`level'.zip"
	}

end
