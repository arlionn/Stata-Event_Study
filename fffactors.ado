*! Date     : 2017-08-17
*! version  : 0.3
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get Fama-French factors from French Data Library

/* 
2017-08-17 v0.3 more consistent date names
2017-08-04 v0.2 fixed date label, display summary statistics
2016-09-02 v0.1 first upload to GitHub
*/

program define fffactors

	version 14.1
	syntax [, clear ]

	// get file
	// http://blog.stata.com/2010/12/01/automating-web-downloads-and-file-unzipping/
	local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_CSV.zip"
	tempfile zip
	copy "`cloud'" "F-F_Research_Data_Factors_CSV.zip", replace
	unzipfile "F-F_Research_Data_Factors_CSV.zip", replace

	// read
	quietly import delimited using "F-F_Research_Data_Factors.CSV", `clear' varnames(3)
	generate date = trim(v1)
	drop if sum(substr(date, 1, 3) == "Ann")
	drop v1
	compress

	// fix date
	generate date_ym = mofd(date(date, "YM"))
	format date_ym %tm
    label variable date_ym "Date"
	drop date

	// fix returns
	foreach v of varlist mktrf smb hml rf {
		destring `v', replace
	}

    /* summary statistics */
    compress
    summarize

    /* first and last date */
    sort date_ym
    display "First date:"
    list date_ym in 1

    display "Last date:"
    list date_ym in L
    
end
