*! Date     : 2016-08-12
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get Fama-French industry data, keep in memory

/* 
2016-08-12 v0.1
 */

program ffind
	version 13.1

	syntax [, clear noremove noexpand]

	// get file
	// http://blog.stata.com/2010/12/01/automating-web-downloads-and-file-unzipping/
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/Siccodes48.zip"
	tempfile zip
	copy "`cloud'" "Siccodes48.zip", replace
	unzipfile "Siccodes48.zip", replace

	// read
	quietly import delimited using "Siccodes48.txt", ///
		delimiter(" ", collapse) `clear'
	quietly tostring v1, replace

	// put file in consistent format
	tempvar oneDigit
	quietly generate `oneDigit' = (v1 == ".") & (strlen(v2) <= 1)
	forvalues i = 2/4 {
		local j = `i' - 1
		quietly replace v`j' = v`i' if `oneDigit'
		quietly replace v`i' = "" if `oneDigit'
	}

	// pick off industry number and short/long names
	tempvar ff48
	quietly destring v1, generate(ff48) ignore(".")
	quietly generate `ff48' = !missing(ff48)
	quietly generate ff48Short = v2 if `ff48'
	quietly egen ff48Long = concat(v3-v11) if `ff48', punct(" ")

	// carryforward
	foreach v of varlist ff48 ff48Short ff48Long {
		quietly replace `v' = `v'[_n - 1] if !`ff48'
	}
	quietly drop if `ff48'

	// expand
	quietly generate sicLo = substr(v2, 1, 4)
	quietly generate sicHi = substr(v2, 6, 4)
	quietly destring sicLo sicHi, replace
	quietly egen sicName = concat(v3-v11), punct(" ")

	// order and sort
	quietly drop v*
	local vars ff48 ff48Short ff48Long sicLo sicHi sicName
	order `vars'
	sort ff48

	// by default expand to merge-able data
	if ("`expand'" == "") {
		tempvar count
		quietly generate `count' = (sicHi - sicLo) - 1
		quietly expand `count'
		quietly bysort ff48 sicLo : generate sic = sicLo - 1 + _n
		sort ff48 sic
		order sic, before(sicLo)
	}

	// clean up
	quietly ds, has(type string)
	foreach v of varlist `r(varlist)' {
		quietly replace `v' = stritrim(`v')
	}
	quietly compress

	// by default remove files
	if ("`remove'" == "") {
		rm "Siccodes48.txt"
		rm "Siccodes48.zip"
	}

end
