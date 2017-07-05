program peek
	version 13.1
	syntax [namelist] using [, n(int 5) ]

	preserve
	use `myuse' `using', clear
	list `namelist' in F/`n'
	list `namelist' in -`n'/L
	describe `namelist'

end
