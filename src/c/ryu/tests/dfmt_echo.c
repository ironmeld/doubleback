// Copyright 2018 Ulf Adams
//
// The contents of this file may be used under the terms of the Apache License,
// Version 2.0.
//
//    (See accompanying file LICENSE-Apache or copy at
//     http://www.apache.org/licenses/LICENSE-2.0)
//
// Alternatively, the contents of this file may be used under the terms of
// the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE-Boost or copy at
//     https://www.boost.org/LICENSE_1_0.txt)
//
// Unless required by applicable law or agreed to in writing, this software
// is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.

#if defined(__linux__)
#define _GNU_SOURCE
#endif

#include <stdbool.h>
#include <inttypes.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(__linux__)
#include <sys/types.h>
#include <unistd.h>
#endif

#include "ryu/ryu.h"
#include "ryu/ryu_parse.h"

int main (int argc, char **argv) {
    char buffer[1024];
    double d;
    while (fgets(buffer, 1024, stdin) != NULL) {
        buffer[strcspn(buffer,"\n")] = 0;
        if (dparse(buffer, &d) == SUCCESS) {
            dfmt(d, buffer);
            puts(buffer);
        } else {
            puts("ERROR");
        }
    }
}

