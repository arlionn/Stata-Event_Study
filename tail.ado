program tail  
	version 8.2 
	syntax [varlist(default=none)]  
	if c(N) == 0 error 2000 
	else { 
		local start = min(10, c(N)) 
		list `varlist' in -`start'/L  
	}
end
