# https://wrds-web.wharton.upenn.edu/wrds/support/Accessing%20and%20Manipulating%20the%20Data/_004Python%20Programming/_001Using%20Python%20with%20WRDS.cfmimport wrds
# https://github.com/wharton/wrds
import pandas
import sys
import time
import wrds

# parse arguments
query = sys.argv[1]
froot = sys.argv[2]
csv = sys.argv[3]

# execute query       
print "Query: %s" % query
print "Output file root: %s" % froot
print "Querying..."
t0 = time.time()
result = wrds.sql(call=query, connection=wrds.CONN)
t1 = time.time()
print "Time to execute query: %s" % format(t1-t0, '.1f')
print "\n"

# preview output 
print "Output preview:"
print(result.head())
print "\n"

# write to file
if (csv != ""): 
	print "Saving as %s.csv" % froot
	result.to_csv(froot+".csv", index=False)
	print "Saved as %s.csv" % froot
else:	
	print "Trying to save as %s.dta" % froot
	try:
		result.to_stata(froot+".dta", write_index=False)
		print "Saved as %s.dta" % froot
	except:
		print "Error saving as %s.dta, falling back to %s.csv" % (froot, froot)
		result.to_csv(froot+".csv", index=False)
		print "Saved as %s.csv" % froot

# pause before closing window
print "\n"
raw_input("Press enter to return to Stata")
