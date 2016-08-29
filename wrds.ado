*! Date     : 2016-07-20
*! version  : 0.1
*! Author   : Richard Herron
*! Email    : richard.c.herron@gmail.com

*! uses Python script to query WRDS database.

/* 
2016-07018 v0.1 first upload to GitHub
2016-07-20 v0.2 added simple error handling, choice of dta or csv
 */

program define wrds
	version 13
	syntax, Query(string) File(string) [ Csv Interactive ]

	// add -i flag if interactive
	if ("`interactive'" != "") local flag "-i"
	local script "C:/Users/rherron1/Documents/GitHub/WRDS/wrds2.py" 
	!python `flag' `script' "`query'" "`file'" "`csv'"

end
