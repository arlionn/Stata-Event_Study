*! Date     : 2017-05-05 
*! version  : 0.2
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get Fama-French industry data, keep in memory

/* 
2017-05-05 v0.2 refactor, adds 12-industry download
2016-08-12 v0.1 original
 */

program ffind
	version 13.1

	syntax [, level(integer 48) clear noremove noexpand]

	// get file
	// http://blog.stata.com/2010/12/01/automating-web-downloads-and-file-unzipping/
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/Siccodes`level'.zip"
	tempfile zip
	copy "`cloud'" "Siccodes`level'.zip", replace
	unzipfile "Siccodes`level'.zip", replace

	// read
	infix ///
            int indNumber 1-2 ///
            str indShort 4-9 ///
            str indLong 11-120 ///
            using "Siccodes`level'.txt", `clear'
    drop if missing(indNumber) & missing(indShort) & missing(indLong)

	// put long name and SIC range in separate columns
    generate hasSic = regexm(indLong, "^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]")
    generate sicRange = substr(indLong, 1, 9) if hasSic
    generate sicName = substr(indLong, 10, .) if hasSic

	// by default expand to merge-able data
    // OTHER industry may need range
	if ("`expand'" == "") {
        replace sicRange = "0000-9999" if (_n == _N) & !hasSic
    }
    drop hasSic

	// carryforward
    replace indNum = indNum[_n - 1] if missing(indNum)
    replace indShort = indShort[_n - 1] if missing(indShort)
    bysort indNum : replace indLong = indLong[1] if (_n > 1)

	// expand
    drop if missing(sicRange)
	generate sicLow = substr(sicRange, 1, 4)
	generate sicHigh = substr(sicRange, 6, 4)
	destring sicLow sicHigh, replace

	// by default expand to merge-able data
	if ("`expand'" == "") {
        /* create row for every SIC code */
		generate N = (sicHigh - sicLow) + 1
		expand N
		bysort indNumber sicLow : generate sic = sicLow + (_n - 1)
        
        /* code duplicates every industry into "other" */
        sort sic indNum
        duplicates drop sic, force
        sort indNum sic
	}
    
	// clean up
    drop sicLow sicHigh N
	ds, has(type string)
	foreach v of varlist `r(varlist)' {
        replace `v' = stritrim(`v')
	}
	compress

	// by default remove files
	if ("`remove'" == "") {
		rm "Siccodes`level'.txt"
		rm "Siccodes`level'.zip"
	}

end
