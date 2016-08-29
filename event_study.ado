*! Date     : 2016-07-26
*! version  : 0.2
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! convert WRDS event study output to CARs

/* 
2016-07-27 v0.2 fixed typo in CAR labels
2016-07-26 v0.1 
 */

program define event_study
    version 13.1
    syntax, FILEname(string) [clear replace suffix(string)]

    // clear and replace are mutually exclusive options
    if (("`clear'" != "") & ("`replace'" != "")) {
    	display as error "clear and replace are mutually exclusive options"
    	exit
    }

    // assume a suffix is not given
    if (("`clear'" == "") & ("`suffix'" == "")) {
	    local suffix " as CARs"
    	display as text`"no output filename suffix provided, using "`suffix'" "'
    }

    // check output file
    local filename : subinstr local filename ".dta" ""
    local fileout "`filename'`suffix'"
	capture confirm file "`fileout'.dta"
	if (!_rc & ("`clear'" == "") & ("`replace'" == "")) {
		display as error "file `fileout' already exists, must use replace option"
		exit
	}

    // deliberate clear
    if ("`clear'" == "") {
    	preserve
	    use "`filename'", clear
    }
    else {
	    use "`filename'", clear
    }

    // reshape-able time variable
    // use "Event study", clear
    drop if missing(evttime)

    // easier than dealing with negative labels
    replace evttime = evttime + 10
    format evttime %02.0f
    
    // drop non-reshape-able variables
    drop date ret

    // reshape
    reshape wide abret, i(permno evtdate) j(evttime)
    order model permno evtdate

    foreach v of varlist abret* {
    	local time : subinstr local v "abret" ""
    	local time = `time' - 10
    	label variable `v' "Abnormal Return (Day `time')"
    }

    // CARs
    // market-adjusted models
    generate mar = (model == "Market-Adjusted Model")
    summarize mar, meanonly
    if (`r(sum)' > 0) {
		egen mar2 = rowtotal(abret9-abret10) if mar , missing
		egen mar3 = rowtotal(abret9-abret11) if mar, missing
		egen mar5 = rowtotal(abret8-abret12) if mar, missing
		egen mar7 = rowtotal(abret7-abret13) if mar, missing
		label variable mar2 "Market-Adjusted Return (-1, 0)"
		label variable mar3 "Market-Adjusted Return (-1, 1)"
		label variable mar5 "Market-Adjusted Return (-2, 2)"
		label variable mar7 "Market-Adjusted Return (-3, 3)"
    }
    drop mar

	generate mm = (model == "Market Model")
	summarize mm, meanonly
    if (`r(sum)' > 0) {
		egen mm2 = rowtotal(abret9-abret10) if mm, missing
		egen mm3 = rowtotal(abret9-abret11) if mm, missing
		egen mm5 = rowtotal(abret8-abret12) if mm, missing
		egen mm7 = rowtotal(abret7-abret13) if mm, missing
		label variable mm2 "Market Model (-1, 0)"
		label variable mm3 "Market Model (-1, 1)"
		label variable mm5 "Market Model (-2, 2)"
		label variable mm7 "Market Model (-3, 3)"
	}
    drop mm

    // save and restore, if no deliberate clear
    if ("`clear'" == "") {
    	save "`fileout'", replace
    	restore
    }
end
