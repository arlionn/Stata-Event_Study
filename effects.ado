program effects

	version 13.1
	syntax, [linear | oddsratio]

	matrix b = e(b)

	if ("`linear'" == "linear") {
		local i = 1
		local colnames : colnames b
		foreach v of local colnames {
			if ("`v'" != "_cons") {

				display ""
				summarize `v' if e(sample), detail
				scalar beta = b[1, `i']
				scalar p75 = `r(p75)'
				scalar p25 = `r(p25)'
				scalar iqr = p75 - p25
				scalar effect = beta * iqr

				display ""
				display "the interequartile range is " ///
					"$\num{" p75 "} - \num{" p25 "} = \num{" iqr "}$"
				display "the effect of an interquartile rise is " ///
					"$\num{" beta " x " iqr "} = \num{" effect "}$"
				display ""
				display ""
				local ++i
			}
		}
	}
	

	if ("`oddsratio'" == "oddsratio") {
		local i = 1
		local colnames : colnames b
		foreach v of local colnames {
			if ("`v'" != "_cons") {

				display ""
				summarize `v' if e(sample), detail
				scalar beta = b[1, `i']
				scalar p75 = `r(p75)'
				scalar p25 = `r(p25)'
				scalar iqr = p75 - p25
				scalar effect = exp(beta * iqr)

				display ""
				display "the interquartile range is " ///
					"$\num{" p75 "} - \num{" p25 "} = \num{" iqr "}$"
				display "the odds ratio of an interquartile rise is " ///
					"$\exp( \num{" beta " x " iqr "}) = \num{" effect "}$"
				display ""
				display ""
				local ++i
			}
		}
	}


end
