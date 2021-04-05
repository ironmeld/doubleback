#include <stdio.h>
#include "doubleback/doubleback.h"
int main() {
    char buf[32] = "0.3";
    double d;
    dparse(buf, &d);
    printf("%s\n", dfmt(d, buf));
    return 0;
}
