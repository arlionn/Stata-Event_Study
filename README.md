# Stata

My Stata .ado files (and templates for starting a new Stata project).

## event_study

Converts WRDS event study output to CARs.

## fm

Returns Fama-MacBeth (1973) time-series average coefficients with Newey-West (1987) standard errors based.
First-stage estimator can be `regress`, `logit`, `logistic`, `probit`, or `tobit`,
but the code is easily modifiable to new estimators.
Compatible with [`estout`](http://repec.sowi.unibe.ch/stata/estout/).

### Examples

    fm y x1 x2, lag(4)

    fm d x1 x2, estimator(logit)

    fm y x1 x2, estimator(tobit) options(ll(0) ul(1))

### Tasks

- [ ] help file
- [x] examples
- [x] standard output, like `regress` 
- [x] all-in-one solution (takes 1st stage regression as a string)

## log_transform

Log transform variable with variable label.
Option to add arbitrary constant.

### Examples

    sysuse auto, clear
    log_transform price
    log_transform weight, add(1)

### Tasks

- [ ] help file
- [x] examples

## peek

Peek at head and tail of not-in-memory data.

### Examples

    sysuse auto, clear
    save auto, replace
    peek using auto
    peek price weight using auto

### Tasks

- [ ] help file
- [x] examples

## rolling_beta

Quickly calculate rolling univariate regressions.

### Examples

    webuse grunfeld, clear
    rolling_beta mvalue kstock, short(3) long(5)

### Tasks

- [ ] help file
- [x] examples
- [x] options for minimum # of observations

## rolling_rho

Quickly perform rolling correlations.

### Examples

    webuse grunfeld, clear
    rolling_rho mvalue kstock, short(3) long(5)

### Tasks

- [ ] help file
- [x] examples
- [x] options for minimum # of observations

## rolling_sigma

Quickly perform rolling standard deviations.

### Examples

    webuse grunfeld, clear
    rolling_sigma mvalue kstock, short(3) long(5)

### Tasks

- [ ] help file
- [x] examples
- [x] options for minimum # of observations

## time_transform

Easy leads, lags, and differences with variable labels.

### Examples

    webuse grunfeld, clear
    time_transform mvalue kstock, operators("S1" "L1" "L2")
    time_transform invest, o("L2")

### Tasks

- [ ] help file
- [x] examples
- [x] options for minimum # of observations

## WRDS

Simple .ado file wrapper for simple .py script to download data from WRDS.
Save data as either .dta or .csv file.
See <https://github.com/wharton/wrds> for more information on .py script.

### Examples

TBD.

### Tasks

- [ ] help file
- [ ] examples

