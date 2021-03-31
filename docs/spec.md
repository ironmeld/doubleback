# Doubleback Specification

## Valid Input Format

```
whole -> [+-] ( '0' | [1-9] [0-9]{0,16} )
fraction -> '.' [0-9]{0,16}
exponentt -> [Ee] [+-]? [0-9]{1,3}

double -> ( whole fraction? | fraction ) exponent?
```

* No more than 17 total significant digits in the whole and fraction, excluding leading zeros

## Standard Output Format

* No plus signs
* No leading zeros on exponent
* Shortest decimal to equivalent binary value
* No more than 17 significant digits, excluding leading zeros
* Infinity is "Infinity"
* Not a Number is "NaN"
* No negative NaNs
* use scientific notation only if exponent <= -5 or exponent >= 16
