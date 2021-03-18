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

#include <math.h>
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
#include <sched.h>
#endif

#include "ryu/ryu.h"
#include "third_party/mersenne/random.h"

#define BUFFER_SIZE 2000

static double int64Bits2Double(uint64_t bits) {
  double f;
  memcpy(&f, &bits, sizeof(double));
  return f;
}

struct mean_and_variance {
  int64_t n;
  double mean;
  double m2;
};

typedef struct mean_and_variance mean_and_variance;

  void init(mean_and_variance* mv) {
    mv->n = 0;
    mv->mean = 0;
    mv->m2 = 0;
  }

  void update(mean_and_variance* mv, double x) {
    ++mv->n;
    double d = x - mv->mean;
    mv->mean += d / mv->n;
    double d2 = x - mv->mean;
    mv->m2 += d * d2;
  }

  double variance(mean_and_variance* mv) {
    return mv->m2 / (mv->n - 1);
  }

  double stddev(mean_and_variance* mv) {
    return sqrt(variance(mv));
  }

double generate_double(uint64_t* r) {
  *r = RandomU64();
  double f = int64Bits2Double(*r);
  return f;
}

static int bench64_general(const uint32_t samples, const uint32_t iterations, int alt, const bool parse, const bool csv, const bool verbose, const bool length) {
  char input[BUFFER_SIZE];
  char buffer_d2s[BUFFER_SIZE];
  char buffer_dfmt[BUFFER_SIZE];
  char buffer_snprintf[BUFFER_SIZE];
  int precision = 0;
  char fmt[100];
  int throwaway = 0;

  RandomInit(12345);
  for (precision=1; precision <= 17; precision++) {

    mean_and_variance mv1;
    init(&mv1);
    mean_and_variance mv2;
    init(&mv2);
    mean_and_variance mv3;
    init(&mv3);
    mean_and_variance mv4;
    init(&mv4);
    mean_and_variance mv5;
    init(&mv5);
    mean_and_variance mv6;
    init(&mv6);
    for (int i = 0; i < samples; ++i) {
      uint64_t r = 0;
      double f = generate_double(&r);

      // convert to a double with the specified precision
      snprintf(fmt, 100, "%%.%dg", precision);
      snprintf(input, BUFFER_SIZE, fmt, f);
      f = strtod(input, NULL);

      clock_t t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        d2s_buffered(f, buffer_d2s);
        throwaway += buffer_d2s[2];
      }
      clock_t t2 = clock();
      double delta1 = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&mv1, delta1);
      update(&mv2, (double) strlen(buffer_d2s));

      double delta2 = 0.0;
      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        snprintf(buffer_snprintf, BUFFER_SIZE, "%.17g", f);
        throwaway += buffer_snprintf[2];
      }
      t2 = clock();
      delta2 = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&mv3, delta2);
      update(&mv4, (double) strlen(buffer_snprintf));

      double delta3 = 0.0;
      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        dfmt(f, buffer_dfmt);
        throwaway += buffer_dfmt[2];
      }
      t2 = clock();
      delta3 = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&mv5, delta3);
      update(&mv6, (double) strlen(buffer_dfmt));

      // verbose implies csv
      if (verbose) {
        if (length) {
            printf("%s,%" PRIu64 ",%f,%f,%f,%s,%s\n", buffer_d2s, r, (double) strlen(buffer_d2s), (double) strlen(buffer_snprintf), (double) strlen(buffer_dfmt), buffer_snprintf, buffer_dfmt);
        } else {
            printf("%s,%" PRIu64 ",%f,%f,%f,%s,%s\n", buffer_d2s, r, delta1, delta2, delta3, buffer_snprintf, buffer_dfmt);
        }
      }
    }
    if (!verbose) {
      if (length) {
        if (csv) {
          printf("%d,", precision);
          printf("%.3f,%.3f,", mv2.mean, stddev(&mv2));
          printf("%.3f,%.3f,", mv4.mean, stddev(&mv4));
          printf("%.3f,%.3f", mv6.mean, stddev(&mv6));
        } else {
          printf("%d", precision);
          printf("%8.3f %8.3f", mv2.mean, stddev(&mv2));
          printf("     %8.3f %8.3f", mv4.mean, stddev(&mv4));
          printf("     %8.3f %8.3f", mv6.mean, stddev(&mv6));
        }
      } else {
        if (csv) {
          printf("%d,", precision);
          printf("%.3f,%.3f,", mv1.mean, stddev(&mv1));
          printf("%.3f,%.3f,", mv3.mean, stddev(&mv3));
          printf("%.3f,%.3f", mv5.mean, stddev(&mv5));
        } else {
          printf("%d %8.3f %8.3f", precision, mv1.mean, stddev(&mv1));
          printf("     %8.3f %8.3f", mv3.mean, stddev(&mv3));
          printf("     %8.3f %8.3f", mv5.mean, stddev(&mv5));
        }
      }
      printf("\n");
    }
  }
  return throwaway;
}


int main(int argc, char** argv) {
#if defined(__linux__)
  // Also disable hyperthreading with something like this:
  // cat /sys/devices/system/cpu/cpu*/topology/core_id
  // sudo /bin/bash -c "echo 0 > /sys/devices/system/cpu/cpu6/online"
  cpu_set_t my_set;
  CPU_ZERO(&my_set);
  CPU_SET(2, &my_set);
  sched_setaffinity(getpid(), sizeof(cpu_set_t), &my_set);
#endif

  int32_t samples = 10000;
  int32_t iterations = 1000;
  bool parse = false;
  bool csv = false;
  int alt = 0; // test the alternative
  bool verbose = false;
  bool length = false;
  for (int i = 1; i < argc; i++) {
    char* arg = argv[i];
    if (strcmp(arg, "-v") == 0) {
      verbose = true;
    } else if (strncmp(arg, "-samples=", 9) == 0) {
      sscanf(arg, "-samples=%i", &samples);
    } else if (strncmp(arg, "-iterations=", 12) == 0) {
      sscanf(arg, "-iterations=%i", &iterations);
    } else if (strcmp(arg, "-parse") == 0) {
      parse = true;
    } else if (strcmp(arg, "-alt") == 0) {
      alt++;
    } else if (strcmp(arg, "-csv") == 0) {
      csv = true;
    } else if (strcmp(arg, "-length") == 0) {
      length = true;
    }
  }

  setbuf(stdout, NULL);

  if (verbose) {
    printf("ryu_output,intval,delta1,delta2\n");
  } else {
    if (csv) {
      printf("digits,time1,stdev1,time2,stddev2\n");
    } else {
      printf("P  Average & Stddev %s\n", alt ?  "snprintf" : "ryu");
    }
  }

  int throwaway = 0;
  throwaway += bench64_general(samples, iterations, alt, parse, csv, verbose, length);
  if (argc == 1000) {
    // Prevent the compiler from optimizing the code away.
    printf("%d\n", throwaway);
  }
  return 0;
}
