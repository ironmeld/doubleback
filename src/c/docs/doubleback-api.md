# Doubleback API for the C Language


## dparse

### Function Signature

```
int dparse_delim(char *input_string, double * output_value, *optional_deliminators);
```

### Return Values

A value greater than 0 is the number of chars included in the parse
A value less than 0 is 
-1: Invalid Format

### Example

#include <stdio.h>
#include "doubleback/doubleback.h"
int main(char **argc, int argv) {
    double buf[32] = "0.3";
    double d;
    dparse(buf, &d);
    printf("%s", dfmt(d, buf));
    return 0;
}

## dfmt

### Function Signature

```
char * dfmt(double input_value, char *output_string);
```

### Example

#include <stdio.h>
#include "doubleback/doubleback.h"
int main(char **argc, int argv) {
    double d = 0.3;
    double buf[32];
    printf("%s", dfmt(d, buf));
    return 0;
}
