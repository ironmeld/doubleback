[![Build Status](https://travis-ci.com/ironmeld/doubleback.svg?branch=main)](https://travis-ci.com/ironmeld/doubleback)

# Table of Contents
* [Doubleback](#doubleback)
* [What is Ryu?](#what-is-ryu)
* [Status](#status)
* [Roadmap for first release](#roadmap-for-first-release)
* [Getting Started](#getting-started)
* [The Problem with Printing Floating-Point Numbers](#the-problem-with-printing-floating-point-numbers)
* [What is printf %g formatting?](#what-is-g)
* [Background on Ryu Formats](#background-on-ryu-formats)
* [The Doubleback Rationale](#the-doubleback-rationale)
* [The Doubleback Format](#the-doubleback-format)
* [The Doubleback APIs](#the-doubleback-apis)
* [Why not DragonBox or other?](#why-not-dragonbox-or-other)
* [Acknowledgements](#acknowledgements)
* [Benchmarks](#benchmarks)

# Doubleback

Doubleback provides round-trip parsing and printing of 64-bit double-precision floating-point numbers using the Ryū algorithm implemented in multiple programming languages. Doubleback is biased towards "human-friendly" output which round-trips consistently between binary and decimal.

For example, look at the output of these functions:

libc:
```
printf("%.17g", 0.3);
0.29999999999999999
```

Ryū shortest:
```
char buf[32];
d2s_buffered(0.3, buf);
printf("%s", buf);
3E-1
```

Doubleback dfmt:
```
char buf[32];
printf("%s", dfmt(0.3, buf));
0.3
```

Doubleback's dfmt will consistently format 0.3 as "0.3". Many other libraries and programming languages will print something different depending on the options you specify.

Doubleback dfmt is basically `Ryū shortest` reformatted to be like `printf("%.17g")`. The Doubleback project provides consistent output across a number programming languages by forking and modifying existing Ryū projects on GitHub. See [Acknowledgements](#acknowledgements).

# What is Ryu?

Ryū is an algorithm [1][2] along with reference code [3] developed by Ulf Adams, Google Germany in 2018. Ryū supports consistent round-trip parsing and "shortest" printing of 64-bit floating-point numbers. To be clear, Ryū is the breakthrough technology that makes Doubleback possible.

There are many older and established algorithms for printing floats. However, Ryū is in a new class of recently developed algorithms that claim substantial improvements over previous efforts.

These algorithms:
* Produce a consistent round-trip representation for all 64-bit doubles
* Produce the shortest length string from equivalent choices in all cases
* Execute in a fraction of the time of previous efforts

Doubleback merges forks of existing Ryū projects and modifies and enhances them to expose a consistent API. Doubleback tests APIs against each other for consistency.

1. https://dl.acm.org/doi/10.1145/3296979.3192369
2. https://dl.acm.org/doi/pdf/10.1145/3360595
3. https://github.com/ulfjack/ryu  (There is a wealth of information about Ryū in the README here.)

# Status

Doubleback is in development and is NOT READY for use or contributions.

# Roadmap

* Consolidate validation and parsing for C and java
* Release C and Java
* Python 3
* TypeScript
* Go
* Rust
* PHP
* Swift
* Ruby
* C#

# Getting Started

Build all languages:
```
git clone https://github.com/ironmeld/doubleback
cd doubleback

# The following command currently runs src/install-deps.sh and you should feel
# free to examine that script to see what packages are being installed.
# It currently only works with Ubuntu, Centos 8, and recent Fedora.
# Note that this will run general updates and upgrades of your system packages.
sudo make install-deps

make && make test && make benchmark
```

Alternatively, you can use git sparse-checkout to checkout and build only a subset of languages. This is an example of building only java code:
```
# git 2.27+
git clone --filter=blob:none --sparse https://github.com/ironmeld/doubleback
cd doubleback
git sparse-checkout init --cone
git sparse-checkout add docs results src/java

# git 2.21+
git clone --filter=blob:none --no-checkout https://github.com/ironmeld/doubleback
cd doubleback
git sparse-checkout init --cone
git sparse-checkout set docs results src/java
```
Then:
```
sudo make install-deps
make && make test && make benchmark
```

# The Problem with Printing Floating-Point Numbers

## Rounding Errors

A big limitation of binary floating-point numbers is that some base 10 numbers like 0.1 cannot be precisely converted to binary [1]. If the number 0.1 is converted to a 64-bit number then it must be rounded to the nearest binary number. The resulting number in binary form is actually 0.1000000000000000055511151231257827021181583404541015625. [2]

Now, say you want to print that binary number. A 64-bit floating point number requires, at most, 17 digits in base 10 (decimal) to accurately represent the number sufficiently so that it will return the same binary number when parsed back into binary [3]. However, at seventeen digits, the binary number above rounds to 0.10000000000000001. So, technically that is the most accurate decimal representation of the binary number at 17 digits. But the critical point is that, due to the rounding error described in the previous paragraph, 0.1 will round-trip back to 0.1000000000000000055511151231257827021181583404541015625 in binary. This is the exact same binary value that 0.10000000000000001 ends up rounding to when parsed.

So if 0.1 and 0.10000000000000001 both preserve the information necessary to recover the exact same binary number, why not use the shorter one when printing it?  Well, an implementation may decide that the longer representation is preferred because it should try to honor the binary value as accurately as possible. From a mathematical point of view, it seems like the natural and correct thing to do.

## Conflicting Requirements

It should be clear at this point that there are conflicting requirements. The best strategy for printing a floating-point number likely depends on its origin. Did the number originated from a binary calculation inside the computer or was it was originally entered by a human being using base 10 decimal? If a human entered the number, an equivalent but shorter representation is more likely appropriate. If a scientist wrote code to calcuate the number, it may be that ".10000000000000001" is a more accurate representation of the real number calculated and it would be preferable to leave it that way in case it is later parsed with *higher precision*. (Although it won't parse any differently at 64-bit precision.)

A general printing algorithm does not know from which source the floating-point number originated. Moreover, it is reasonable to expect that determining the shortest representation in decimal that will recover the binary number will take more work than the alternative. In fact, there are some tricky issues that can lead to close-but-not-optimal solutions [4]. It should not be surprising then that many different algorithms have been implemented over the years and implementations continue to evolve as the research into new techniques also evolves.

1. https://www.exploringbinary.com/why-0-point-1-does-not-exist-in-floating-point/
2. https://www.exploringbinary.com/floating-point-converter/
3. https://en.wikipedia.org/wiki/Double-precision_floating-point_format
4. https://www.exploringbinary.com/the-shortest-decimal-string-that-round-trips-may-not-be-the-nearest/

# What is printf %g Formatting?  <a name="what-is-g"></a>

```
printf("%.17g\n", 0.5);
0.5
printf("%.17g\n", 113.166015625);
113.166015625
```

Let's say you want printf to print a double accurately, with up to 17 significant digits **and** to print *only* as many digits as necessary for accuracy. The number "0.5" will round-trip perfectly into binary so there is no need to print 17 digits. If those are your requirements, then %.17g is the only printf format that fulfills them. Both %.17e and %.17f will print 17 digits, with zeros if necessary.

```
printf("%.17f\n", 0.5);
0.50000000000000000
printf("%.17f\n", 113.166015625);
113.16601562500000000
```

## Dynamic Notation

Furthermore %g will render without exponents if the number is not too big or too small (while factoring in the requested precision) otherwise it will render with exponents.

Some of the details can be found here:
https://stackoverflow.com/questions/54162152/what-precisely-does-the-g-printf-specifier-mean

## Total Significant Digits

```
printf("%.3f", 54.5005)
54.501
printf("%.3g", 54.5005)
54.5
```

There is one more aspect of %g that should be highlighted. The precision number specified in the %g format means *total significant digits* including both whole number digits and fractional digits, while the number means *fractional digits only* for %e and %f.

The specification gives a formula by which %g can be converted to an equivalent %f which is P − (X + 1), where P is requested precision and X is the exponent of the value in scientific notation. The fact that %g precision is interpreted as total significant digits is documented in the printf man page under the description of precision but it is easy to overlook this detail.

### Insufficient Precision

```
printf("%.3g", 54.5005)
54.5
```

This "total significant digits" behavior can truncate some of the fractional digits if the number is large and the requested number of significant digits is not enough, because the significant digits may be used up by the whole number portion. This occurs if the number of significant digits left over after consumption by the whole number are *less than* necessary to accurately print the fractional part. The effect of this is to reduce the length of the string, for better or for worse. It would be bad if it unintentionally loses precision. To avoid that, one uses %.17g to make sure %g never truncates a digit necessary to accurately represent any 64-bit float. We can be sure that truncation is always throwing away useless digits. In the context of "%.17g", I think of this as "truncating digits that would otherwise overstate recoverable precision".

### Excess Precision

```
printf("%.17g", 0.5)
0.5
```

A potential downside of %.17g occurs when the number of significant digits left over for the fractional part are *more than*  necessary to display it accurately and the excess digits just end up as zeros. This brings in the second feature of %g - trailing fractional zeros are removed. Call this "truncating digits that are implied and therefore useless, even though they accurately reflect the recoverable precision".

So %.17g ends up "right-sizing" the precision when displayed without an exponent. It tries to display as many digits as necessary to be precise, but *no more*.

# Background on Ryu Formats

Adams provided implementations for %e, %f, and "shortest". Ryū "shortest" mode is similar to %g, but it is not the same. When first learning about Ryū, one could be forgiven for mixing up Ryū's "shortest" with %g. They both can result in "right sizing" the number of significant digits while supressing trailing zeros.

However, for the number "0.3" Ryū shortest outputs "3E-1" instead of "0.3". Ryū "shortest" always outputs exponential notation, which is different from %g. An explanation for this is found in this issue: https://github.com/ulfjack/ryu/issues/154.

I suspect there was an early intent to provide the equivalent %g functionality, as stated in the paper:
```
This paper describes the Ryū Printf algorithm, which generates printf-identical output
for the %f, %e, and %g formats with arbitrary runtime-provided precision parameters,
i.e., printf("%.<p>f",<f>), printf("%.<p>e",<f>), and printf("%.<p>g",<f>)
for any precision p and floating-point value f.
```

However, there is this statement further down:
```
We do not discuss the %g format in detail as it is merely a combination format:
depending on the provided value, the implementation decides whether to use %f or %e format.
```

Later, Adams demonstrates awareness that %g has additional complexity:

```
For the %g specifier, printf picks either %f or %e formatting, depending on the exponent,
and also omits trailing zeros from the result.
```

As described in the previous section, the implementation of %g is not so trivial as it seems upon first glance.

So additional work is required to implement %g formatting.

# The Doubleback Rationale

Doubleback is opinionated in a few ways.

The first opinion is that shorter representations of floating-point numbers are preferable over longer, perhaps more accurate representations, if they round-trip back to the exact same 64-bit binary number anyway. As explained in the previous section, there are users who prefer to represent binary values with extreme precision, and care less about poor ergonomics. But those users have other options. For example, they can reduce conversion error by using hexadecimal notation, binary storage, longer floating point types, or arbitrary precision libraries.

There is only so much accuracy one should expect when working with 64-bit binary numbers. Moreover, if you are converting to decimal notation then that is likely for human consumption. So ergonomics seems like a reasonable bias for that operation. Python recognized the pragmatic advantage of shorter representations many years ago [1]. Chasing down some illusory extra bit of precision that will provide hardly any real benefit to all but a small minority of users (who have better options) should not be the priority.

The second opinion is that %.17g is the most reasonable and familiar representation for human-entered 64-bit floating-point numbers that preserves the maximum amount of usable precision. As will be explain in the next section, there are also a few improvements that have been adopted as well. It should be easy to produce output in this style in many different programming languages.

The third opinion is that Ryū is the right algorithm at the right time for implementing this solution.

1. https://bugs.python.org/issue1580

# The Doubleback Format

Doubleback implements its own format which is similar to "%.17g" but it is NOT intended to be an exact drop-in replacement.

Doubleback dfmt is different from printf("%.17g") in these ways:
* It uses Ryū to pick the shortest representation
* It does not zero-pad small exponents
* It does not print a plus sign for positive exponents

# The Doubleback APIs

The API for Doubleback formatting in C notation is:

```
char *dfmt(const double input_value, char *output_buffer);
```

To avoid memory allocation and threading complications a small memory buffer must be passed to the API. The buffer pointer is returned back for convenience.

```
enum Status dparse(const char *input_buffer, double *output_value);
```

# Language Support

* C99
* Java 8

# Why not DragonBox or other?

The performance benefits of DragonBox [1] are compelling [2] and I was close to going all in on DragonBox instead of Ryū. However, at the time of this writing (Mar 13, 2021) DragonBox is around 6 months old and has not been peer reviewed or implemented in any language other than C++. Ryū, on the other hand, has received substantial investment in development and testing. There are implementations at various stages of development for over ten different programming languages. Microsoft developed an implementation and extensive tests for incorporation into libc++ that spans over 60,000 lines of code [3]. There is a similar effort for Go although it appears to have stalled [4].

I think it is likely that an algorithm different from Ryū, perhaps DragonBox, will ultimately be considered the state-of-the-art. That algorithm will likely be functionally equivalent and could be a compelling candidate to replace Ryū in the future. But for now, the next-gen floating-point boat has already departed and Ryū is on it.

1. https://github.com/jk-jeon/dragonbox
2. https://github.com/abolz/Drachennest/
3. https://reviews.llvm.org/D70631
4. https://github.com/golang/go/issues/15672

# Acknowledgements

Doubleback is derived from upstream projects.

| Language | Upstream Project |
|----------|------------------|
| C        | https://github.com/ulfjack/ryu |
| Java     | https://github.com/ulfjack/ryu |


# Benchmarks
 
The "ergonomic magic" of "0.3" instead of ".299999999..." is awesome, but at what performance cost compared to printf %g?

The benchmark Adams provided for Ryū "shortest" is against Google's double_conversion (Grisu3). We provide new benchmarks at the bottom of this page for Doubleback/Ryū dfmt vs snprintf %g vs Ryū shortest.

![Doubleback/Ryū prints 10 to 20 times faster than standard printf](results/c-double-shortest-bydigits-time.png "Doubleback/Ryū ranges from 10 to 20 times faster than standard printf")

![Doubleback/Ryū output is 30% to 96% the length of standard printf](results/c-double-shortest-bydigits-length.png "Doubleback/Ryū output is 30% to 96% the length of standard printf")

![Doubleback/Ryū parses approx. 3 to 7 times faster than standard strtod](results/c-double-shortest-bydigits-parse.png "Doubleback/Ryū ranges from approx. 3 to 7 times faster than standard strtod")
