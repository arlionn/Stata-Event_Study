program effects

	version 13.1
	syntax, [linear | oddsratio]

	matrix b = e(b)

	if ("`linear'" == "linear") {
		local i = 1
		local colnames : colnames b
		foreach v of local colnames {
			if ("`v'" == "_cons") | regexm("`v'", "^[0-9]") {
                display "Marginal effects are not logical for indicator variable `v'"
                continue
			}

            display ""
            summarize `v' if e(sample), detail
            scalar beta = b[1, `i']
            scalar p75 = `r(p75)'
            scalar p25 = `r(p25)'
            scalar iqr = p75 - p25
            scalar effect = beta * iqr
            local label : variable label `v'

            display ""
            display "the interequartile range of `label' is " ///
                "$\num{" p75 "} - \num{" p25 "} = \num{" iqr "}$"
            display "the effect of an interquartile rise in `label' is " ///
                "$\num{" beta " x " iqr "} = \num{" effect "}$"
            display ""
            display ""
            local ++i
		}
	}
	

	if ("`oddsratio'" == "oddsratio") {
		local i = 1
		local colnames : colnames b
		foreach v of local colnames {
			if ("`v'" == "_cons") | regexm("`v'", "^[0-9]") {
                display "Marginal effects are not logical for indicator variable `v'"
                continue
			}


            display ""
            summarize `v' if e(sample), detail
            scalar beta = b[1, `i']
            scalar p75 = `r(p75)'
            scalar p25 = `r(p25)'
            scalar iqr = p75 - p25
            scalar effect = exp(beta * iqr)
            local label : variable label `v'

            display ""
            display "the interquartile range of `label' is " ///
                "$\num{" p75 "} - \num{" p25 "} = \num{" iqr "}$"
            display "the odds ratio of an interquartile rise in `label' is " ///
                "$\exp( \num{" beta " x " iqr "}) = \num{" effect "}$"
            display ""
            display ""
            local ++i
		}
	}


end
