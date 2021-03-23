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
#include "ryu/ryu_parse.h"
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

static int bench64_general(const uint32_t samples, const uint32_t iterations, const bool data, const bool csv) {
  char input[BUFFER_SIZE];
  char buffer_d2s[BUFFER_SIZE];
  char buffer_dfmt[BUFFER_SIZE];
  char buffer_snprintf[BUFFER_SIZE];
  int precision = 0;
  char fmt[100];
  int throwaway = 0;
  float throwaway_f = 0.0;

  RandomInit(12345);
  for (precision=1; precision <= 17; precision++) {

    mean_and_variance d2s_time_mv;
    init(&d2s_time_mv);
    mean_and_variance d2s_len_mv;
    init(&d2s_len_mv);
    mean_and_variance snp_time_mv;
    init(&snp_time_mv);
    mean_and_variance snp_len_mv;
    init(&snp_len_mv);
    mean_and_variance dfmt_time_mv;
    init(&dfmt_time_mv);
    mean_and_variance dfmt_len_mv;
    init(&dfmt_len_mv);
    mean_and_variance strtod_time_mv;
    init(&strtod_time_mv);
    mean_and_variance s2d_time_mv;
    init(&s2d_time_mv);

    for (int i = 0; i < samples; ++i) {
      uint64_t r = 0;
      double f = generate_double(&r);

      // convert to a double with the specified precision
      snprintf(fmt, 100, "%%.%dg", precision);
      snprintf(input, BUFFER_SIZE, fmt, f);

      // test strtod
      clock_t t1 = clock();
      for (int j = 0; j < iterations; ++j) {
          f = strtod(input, NULL);
          throwaway_f += f;
      }
      clock_t t2 = clock();
      double strtod_time = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&strtod_time_mv, strtod_time);

      // test s2d
      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
          s2d(input, &f);
          throwaway_f += f;
      }
      t2 = clock();
      double s2d_time = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&s2d_time_mv, s2d_time);

      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        d2s_buffered(f, buffer_d2s);
        throwaway += buffer_d2s[2];
      }
      t2 = clock();
      double d2s_time = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&d2s_time_mv, d2s_time);
      update(&d2s_len_mv, (double) strlen(buffer_d2s));

      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        snprintf(buffer_snprintf, BUFFER_SIZE, "%.17g", f);
        throwaway += buffer_snprintf[2];
      }
      t2 = clock();
      double snp_time = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&snp_time_mv, snp_time);
      update(&snp_len_mv, (double) strlen(buffer_snprintf));

      t1 = clock();
      for (int j = 0; j < iterations; ++j) {
        dfmt(f, buffer_dfmt);
        throwaway += buffer_dfmt[2];
      }
      t2 = clock();
      double dfmt_time = ((t2 - t1) * 1000000000.0) / ((double) iterations) / ((double) CLOCKS_PER_SEC);
      update(&dfmt_time_mv, dfmt_time);
      update(&dfmt_len_mv, (double) strlen(buffer_dfmt));

      // data implies csv
      if (data) {
        printf("%" PRIu64 ",%s,%f,%f,%s,%f,%f,%s,%f,%f,%f,%f\n", r,
            buffer_snprintf, snp_time, (double) strlen(buffer_snprintf),
            buffer_d2s, d2s_time, (double) strlen(buffer_d2s),
            buffer_dfmt, dfmt_time, (double) strlen(buffer_dfmt),
            strtod_time, s2d_time);
      }
    }
    // summary stats by digits of precision
    if (!data) {
        if (csv) {
          printf("%d,", precision);
          printf("%.3f,%.3f,", snp_time_mv.mean, stddev(&snp_time_mv));
          printf("%.3f,%.3f,", snp_len_mv.mean, stddev(&snp_len_mv));
          printf("%.3f,%.3f,", d2s_time_mv.mean, stddev(&d2s_time_mv));
          printf("%.3f,%.3f,", d2s_len_mv.mean, stddev(&d2s_len_mv));
          printf("%.3f,%.3f,", dfmt_time_mv.mean, stddev(&dfmt_time_mv));
          printf("%.3f,%.3f,", dfmt_len_mv.mean, stddev(&dfmt_len_mv));
          printf("%.3f,%.3f,", strtod_time_mv.mean, stddev(&strtod_time_mv));
          printf("%.3f,%.3f", s2d_time_mv.mean, stddev(&s2d_time_mv));
        } else {
          printf("%d", precision);
          printf(" %8.3f %8.3f", snp_time_mv.mean, stddev(&snp_time_mv));
          printf(" %8.3f %8.3f", snp_len_mv.mean, stddev(&snp_len_mv));
          printf(" %8.3f %8.3f", d2s_time_mv.mean, stddev(&d2s_time_mv));
          printf(" %8.3f %8.3f", d2s_len_mv.mean, stddev(&d2s_len_mv));
          printf(" %8.3f %8.3f", dfmt_time_mv.mean, stddev(&dfmt_time_mv));
          printf(" %8.3f %8.3f", dfmt_len_mv.mean, stddev(&dfmt_len_mv));
          printf(" %8.3f %8.3f", strtod_time_mv.mean, stddev(&strtod_time_mv));
          printf(" %8.3f %8.3f", s2d_time_mv.mean, stddev(&s2d_time_mv));
        }
        printf("\n");
    }
  }
  return throwaway + (int) throwaway_f;
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
  bool csv = false;
  bool data = false;
  for (int i = 1; i < argc; i++) {
    char* arg = argv[i];
    if (strcmp(arg, "-data") == 0) {
      data = true;
    } else if (strncmp(arg, "-samples=", 9) == 0) {
      sscanf(arg, "-samples=%i", &samples);
    } else if (strncmp(arg, "-iterations=", 12) == 0) {
      sscanf(arg, "-iterations=%i", &iterations);
    } else if (strcmp(arg, "-csv") == 0) {
      csv = true;
    }
  }

  setbuf(stdout, NULL);

  if (data) {
    printf("intval,snprintf,snp_time,snp_length,d2s,d2s_time,d2s_len,dfmt_time,dfmt_len,strtod_time,d2s_time\n");
  } else {
    if (csv) {
      printf("digits," \
             "snp_time_avg,snp_time_stdev,snp_len_avg,snp_len_stddev," \
             "d2s_time_avg,d2s_time_stddev,d2s_len_avg,d2s_len_stddev," \
             "dfmt_time_avg,dfmt_time_stddev,dfmt_len_avg,dfmt_len_stddev," \
             "strtod_time_avg,strtod_time_stddev,s2d_time,s2d_time_stddev\n");
    } else {
      printf("digits snprintf timeavg stddev d2s timeavg stddev dfmt timeavg stddev strtod_timeavg strtod_stddev s2d_timeavg s2d_stddev\n");
    }
  }

  int throwaway = 0;
  throwaway += bench64_general(samples, iterations, data, csv);
  if (argc == 1000) {
    // Prevent the compiler from optimizing the code away.
    printf("%d\n", throwaway);
  }
  return 0;
}
