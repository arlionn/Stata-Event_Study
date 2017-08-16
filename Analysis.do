/* TITLE */

/* {{{ comments ==============================================================

}}} */

/* {{{ housekeeping ======================================================= */
clear all
cd "$DROPBOX"
do "Macros.do" // run macros!!!
/* pause on // pause on for WRDS lookups */
pause off
/* }}} */

/* {{{ data =============================================================== */

/* {{{ open log */
capture log close data
log using "Data.txt", replace text name(data)
/* }}} */

/* {{{ data files */

/* }}} */

/* {{{ merge data files */

/* }}} */

/* {{{ generate variables */

/* }}} */

/* {{{ save data */
compress
save "", replace
/* }}} */

/* {{{ close log */
capture log close data
/* }}} */

/* }}} */

/* {{{ analysis =========================================================== */

/* {{{ open log */
capture log close analysis
log using "Analysis.txt", replace text name(analysis)
/* }}} */

/* {{{ load data, run macros */
use "", clear
do "Macros.do" 
/* }}} */

/* {{{ tables ------------------------------------------------------------- */



/* }}} */

/* {{{ figures ------------------------------------------------------------ */



/* }}} */

/* {{{ close log */
capture log close analysis
/* }}} */
