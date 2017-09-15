*! Date     : 2017-09-15
*! version  : 0.4
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! get breakpoints from French Data Library

/* 
2017-09-15 v0.4 keep option, error handling
2017-08-17 v0.3 consistent date name
2016-09-06 v0.2 added B/M breakpoints
2016-09-02 v0.1 first 
 */

program define ffbkpts

	version 13.1
	syntax , clear [ me beme KEEPfiles ]
    
    /* either ME or BE/ME */
    if (("`me'"=="")&("`beme'"=="")) | (("`me'"!="")&("`beme'"!="")) {
        display as error "specify ME or BE/ME breakpoints (i.e., option me or beme)"
        exit 197
    }

    /* ME breakpoints */
	if ("`me'" == "me") {

		/* get file */
		local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/ME_Breakpoints_CSV.zip"
		copy "`cloud'" "ME_Breakpoints_CSV.zip", replace
		unzipfile "ME_Breakpoints_CSV.zip", replace

		/* read */
		import delimited using "ME_Breakpoints.CSV" ///
            , `clear' rowrange(2) numericcols(_all) delimiters(",")
		drop if missing(v1)

		/* rename */
		rename v1 date
		rename v2 n
		local i = 5
		foreach v of varlist v* {
			rename `v' me`i'
			local i = `i' + 5
		}

        /* fix date */
        rename date date0
        generate int date = ym(floor(date0/100), mod(date0, 100))
        format date %tm
        drop date0
        order date

        /* by default, remove files */
        if ("`keepfiles'" == "") {
            rm "ME_Breakpoints.CSV"
            rm "ME_Breakpoints_CSV.zip"
        }

	}


    /* BE/ME breakpoints */
	if ("`beme'" == "beme") {

		/* get file */
		local cloud "http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/BE-ME_Breakpoints_CSV.zip"
		copy "`cloud'" "BE_ME_Breakpoints_CSV.zip", replace
		unzipfile "BE_ME_Breakpoints_CSV.zip", replace

		/* read */
		import delimited using "BE-ME_Breakpoints.CSV" ///
            , `clear' rowrange(4) numericcols(_all) delimiters(",")
		drop if missing(v1)

		/* rename */
		rename v1 year
		rename v2 nonpos
		rename v3 pos
		local i = 5
		foreach v of varlist v* {
			rename `v' beme`i'
			local i = `i' + 5
		}

        /* by default, remove files */
        if ("`keepfiles'" == "") {
            rm "BE_ME_Breakpoints.CSV"
            rm "BE_ME_Breakpoints_CSV.zip" 
        }

	}


    /* return */
    compress

end
