// set graphic defaults
capture set scheme s1color, permanently
capture set autotabgraphs on

// set directories
global DRIVE "C:/Users/`c(username)'/Google Drive/Research"
global DROPBOX "C:/Users/`c(username)'/Dropbox/Research"
global GITHUB "C:/Users/`c(username)'/Documents/GitHub"

// set other parameters
set linesize 120
set more off, permanently

// keep personal ado files in cloud
adopath + "$GITHUB/Stata"

