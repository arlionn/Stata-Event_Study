*! 0.1 Richard Herron 2/11/2014

/* use to standardize country names across several data sources */

program fix_country_names
    version 11.2
    syntax varname(string) [, Suffix(string) ]
    
    tokenize `varlist'

    quietly {

        /* default suffix */
        if "`suffix'" == "" local suffix "_0"

        /* save original as new variable w/ suffix */
        rename `1' `1'`suffix'

        /* first standardize capitalization */
        generate `1' = proper(`1'`suffix')

        /* -if- picks up bad names from any source;
        i.e., write once, run everywhere */
        replace `1' = "Czech Republic" ///
            if inlist(`1', "Czech Rep.")
        replace `1' = "Hong Kong" ///
            if inlist(`1', "Hong Kong SAR, China")
        replace `1' = "Kazakhstan" ///
            if inlist(`1', "Kazahkstan")
        replace `1' = "Korea" ///
            if inlist(`1', "Korea (Rep.)",  "Korea, Rep.", "Korea (South)")
        replace `1' = "Russia" ///
            if inlist(`1', "Russian Federation")
        replace `1' = "Slovak Republic" ///
            if inlist(`1', "Slovak Rep.", "Slovakia")
        replace `1' = "United States" ///
            if inlist(`1', "USA", "Usa", "U.S.A.", "U.s.a.")        
        replace `1' = "Venezuela" ///
            if inlist(`1', "Venezuela, RB", "Venezuela, Rb")        
        replace `1' = "Virgin Islands (Brit)" ///
            if inlist(`1', "Virgin Islands(Brit)")

        /* fix labels */ 
        local name: variable label `1'`suffix'
        label variable `1' "`name'"
        label variable `1'`suffix' "`name' (orig)"

    }

    end
