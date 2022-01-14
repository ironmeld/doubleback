# Doubleback Specification

## Valid Input Format

```
whole -> [+-]? ( '0' | [1-9] [0-9]+ )
fraction -> '.' [0-9]
exponent -> [Ee] [+-]? [0-9]{1,3}

double -> ( whole fraction? | fraction ) exponent?
double -> [+-]? Infinity
double -> [+-]? [Nn][Aa][Nn]
```

* No more than 17 total digits for the whole and fraction together,
  exluding the whole portion if it is equal to '0'


## Standard Output Format

* No plus signs
* No leading zeros on exponent
* Shortest decimal to equivalent binary value
* No more than 17 digits total, excluding the whole portion if it is equal to '0'
* Uses scientific notation only if exponent <= -5 or exponent >= 16

* Infinity outputs as "Infinity"
* NaN outputs as "NaN"
* -NaN outputs as "NaN"
* -0 outputs as "-0"
