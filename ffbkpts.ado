*! Date     : 2017-08-17
*! version  : 0.3
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get breakpoints from French Data Library

/* 
2017-08-17 v0.3 consistent date name
2016-09-06 v0.2 added B/M breakpoints
2016-09-02 v0.1 first 
 */

program define ffbkpts

	version 14.1
	syntax [, clear me beme ]

	if ("`me'" == "me") {
		// get file
		// http://blog.stata.com/2010/12/01/automating-web-downloads-and-file-unzipping/
		local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/ME_Breakpoints_CSV.zip"
		tempfile zip
		copy "`cloud'" "ME_Breakpoints_CSV.zip", replace
		unzipfile "ME_Breakpoints_CSV.zip", replace

		// read
		`clear'
		quietly import delimited using "ME_Breakpoints.CSV"
		keep if sum(substr(v1, 1, 6) == "192512")
		drop in `=`c(N)' - 2'/`c(N)'
		compress

		// rename
		rename v1 date
		rename v2 n
		local i = 5
		foreach v of varlist v* {
			rename `v' me`i'
			local i = `i' + 5
		}

		// fix date
		generate date_ym = mofd(date(date, "YM"))
		format date_ym %tm
		drop date
	}

	if ("`beme'" == "beme") {
		// get file
		// http://blog.stata.com/2010/12/01/automating-web-downloads-and-file-unzipping/
		local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/BE-ME_Breakpoints_CSV.zip"
		tempfile zip
		copy "`cloud'" "BE_ME_Breakpoints_CSV.zip", replace
		unzipfile "BE_ME_Breakpoints_CSV.zip", replace

		// read
		`clear'
		quietly import delimited using "BE-ME_Breakpoints.CSV"
		replace v1 = trim(v1)
		keep if sum(substr(v1, 1, 4) == "1926")
		drop in `c(N)'/`c(N)'
		compress

		// rename
		rename v1 year
		destring year, replace
		rename v2 nonpos
		destring nonpos, replace
		rename v3 pos
		destring pos, replace
		local i = 5
		foreach v of varlist v* {
			rename `v' beme`i'
			local i = `i' + 5
		}
	}

end
