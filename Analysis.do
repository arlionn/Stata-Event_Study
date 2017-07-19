/* TITLE */

/* {{{ comments */


/* }}} */

/* {{{ housekeeping */

clear all
cd "$DROPBOX"
do "Macros.do" // be sure to run macros!!!
/* pause on // pause on for WRDS lookups */
pause off

/* }}} */

/* {{{ data */

/* open log */
capture log close data
log using "Data.txt", replace text name(data)




/* save data */
compress
save "", replace

/* close log */
capture log close data

/* }}} */

/* {{{ analysis */

/* open log */
capture log close analysis
log using "Analysis.txt", replace text name(analysis)

/* load data, be sure to run macros */
use "", clear
do "Macros.do" 

/* {{{ tables */ 



/* }}} */

/* {{{ figures */



/* }}} */

/* open log */
capture log close analysis

/* }}} */
