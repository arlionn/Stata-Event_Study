# Stata

My Stata .ado files

## event_study

Converts WRDS event study output to CARs.

## fm

Given a first-stage specification, returns Fama-MacBeth (1973) time-series average coefficients with Newey-West (1987) standard errors. First-stage estimator can be OLS, logit, probit, or tobit, but is extensible to new estimators. Compatible with -estout-.

### Examples

TBD.

### Tasks

- [ ] help file
- [ ] examples
- [x] standard output, like -regress- 
- [x] all-in-one solution (takes 1st stage regression as a string)

## head

Head, as in R. Inspired by [this](https://codeandculture.wordpress.com/2010/08/25/heads-or-tails-of-your-dta/) blog post.

## log_transform

Stata .ado file to log transform variable with label and options

### Examples

TBD.

### Tasks

- [ ] examples
- [ ] help file

## peek

Peek at head and tail of not-in-memory data.

## rolling_beta

Quickly perform rolling capital asset pricing model (CAPM) betas.

### Examples

TBD.

### Tasks

- [ ] examples
- [ ] help file
- [x] options for minimum # of observations

## rolling_rho

Quickly perform rolling correlations.

### Examples

TBD.

### Tasks

- [ ] examples
- [ ] help file
- [x] options for minimum # of observations

## rolling_sigma

Quickly perform rolling standard deviations.

### Examples

TBD.

### Tasks

- [ ] examples
- [ ] help file
- [x] options for minimum # of observations

## tail

Tail, as in R.

## time_transform

Easy leads, lags, and differences with auto-labels.

## WRDS

Simple .ado file wrapper for simple .py script to download data from WRDS and save as either .dta or .csv file.

### Examples

TBD.

### Tasks

- [ ] 
