program peek
	version 13.1
	syntax, FILEname(string) [VARiables(namelist)]

	// use built-in error codes
	confirm file "`filename'"
	preserve
	use "`filename'", clear

	// depends on my -head- and -tail- .ado files
	describe `variables'
	head `variables'
	tail `variables'

	restore
end
