/* TITLE */

/* {{{ housekeeping */

clear all
cd "$DROPBOX"
do "Macros.do" // be sure to run macros!!!
/* pause on // pause on for WRDS lookups */
pause off

/* }}} */

/* {{{ data */

compress
save "", replace

/* }}} */

/* {{{ analysis */

use "", clear
do "Macros.do" // be sure to run macros!!!

/* {{{ tables */ 

/* }}} */

/* {{{ figures */

/* }}} */

/* }}} */

