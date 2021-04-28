// Copyright 2018 Ulf Adams
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.ironmeld.doubleback.benchmark;

import org.yuanheng.cookjson.DoubleUtils;

import info.adams.random.MersenneTwister;
import com.ironmeld.doubleback.Doubleback;

public class BenchmarkMain {
  public static void main(String[] args) {
    int samples = 1000;
    int iterations = 1000;
    boolean bydigits = false;
    boolean csv = false;
    for (String s : args) {
      if (s.equals("-bydigits")) {
        bydigits = true;
      } else if (s.equals("-csv")) {
        csv = true;
      } else if (s.startsWith("-samples=")) {
        samples = Integer.parseInt(s.substring(9));
      } else if (s.startsWith("-iterations=")) {
        iterations = Integer.parseInt(s.substring(12));
      }
    }

    if (csv) {
      System.out.println("float_bits_as_int,jdk_out,jdk_time,jdk_len,jaffer_out,jaffer_time,jaffer_len,ryu_out,ryu_time,ryu_len,dfmt_out,dfmt_time,dfmt_len");
    } else {
      if (bydigits) {
          System.out.printf("%7s %7s %7s %5s %5s %7s %7s %5s %5s %7s %7s %5s %5s %7s %7s %5s %5s %7s %7s %7s %7s\n", "digits",
                        "jdk ns", "stddev", "len", "stdev",
                        "jaff.ns", "stddev", "len", "stdev",
                        "ryu", "stddev", "len", "stdev",
                        "dfmt", "stddev", "len", "stdev",
                        "jdk par", "stddev", "dparse", "stddev");
      }
    }
    int throwaway = 0;
    throwaway += bench64(samples, iterations, bydigits, csv);
    if (args.length == 1000) {
      // Prevent the compiler from optimizing the code away. Technically, the
      // JIT could see that args.length != 1000, but it seems unlikely.
      System.err.println(throwaway);
    }
  }

  private static int bench64(int samples, int iterations, boolean bydigits, boolean csv) {
    MersenneTwister twister = new MersenneTwister(12345);
    // Warm up the JIT.
    MeanAndVariance warmUp = new MeanAndVariance();
    // We track some value computed from the result of the conversion to make sure that the
    // compiler does not eliminate the conversion due to the result being otherwise unused.
    int throwaway = 0;
    double throwaway_f = 0;
    for (int i = 0; i < 1000; i++) {
      System.gc();
      System.gc();
      long r = twister.nextLong();
      double f = Double.longBitsToDouble(r);
      long start = System.nanoTime();
      for (int j = 0; j < 100; j++) {
        throwaway += Doubleback.doubleToString(f).length();
      }
      for (int j = 0; j < 100; j++) {
        throwaway += Double.toString(f).length();
      }
      for (int j = 0; j < 100; j++) {
        throwaway += DoubleUtils.toString(f).length();
      }
      long stop = System.nanoTime();
      warmUp.update((stop - start) / 100.0);
    }

    MeanAndVariance jdk_parse_time_mv = new MeanAndVariance();
    MeanAndVariance s2d_parse_time_mv = new MeanAndVariance();
   
    MeanAndVariance d2s_time_mv = new MeanAndVariance();
    MeanAndVariance d2s_len_mv = new MeanAndVariance();
    MeanAndVariance jdk_time_mv = new MeanAndVariance();
    MeanAndVariance jdk_len_mv = new MeanAndVariance();
    MeanAndVariance jaffer_time_mv = new MeanAndVariance();
    MeanAndVariance jaffer_len_mv = new MeanAndVariance();
    MeanAndVariance dfmt_time_mv = new MeanAndVariance();
    MeanAndVariance dfmt_len_mv = new MeanAndVariance();
    twister.setSeed(12345);
    for (int precision = 1; precision <= 17; precision++) {
      jdk_parse_time_mv = new MeanAndVariance();
      s2d_parse_time_mv = new MeanAndVariance();
   
      d2s_time_mv = new MeanAndVariance();
      d2s_len_mv = new MeanAndVariance();
      jdk_time_mv = new MeanAndVariance();
      jdk_len_mv = new MeanAndVariance();
      jaffer_time_mv = new MeanAndVariance();
      jaffer_len_mv = new MeanAndVariance();
      dfmt_time_mv = new MeanAndVariance();
      dfmt_len_mv = new MeanAndVariance();

      for (int i = 0; i < samples; i++) {

        System.gc();
        System.gc();

        // next random value to test
        long r = twister.nextLong();
        double f = Double.longBitsToDouble(r);

        // set precision
        String fmt = String.format("%%.%dg", precision);
        String input = String.format(fmt, f);
        //System.out.print(input + ", ");

        // parse native
        System.gc();
        System.gc();
        long start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          f = Double.parseDouble(input);
          throwaway_f += f;
        }
        long stop = System.nanoTime();
        double jdk_parse_time = (stop - start) / (double) iterations;
        jdk_parse_time_mv.update(jdk_parse_time);

        // parse ryu
        System.gc();
        System.gc();
        start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          f = Doubleback.dparse(input);
          throwaway_f += f;
        }
        stop = System.nanoTime();
        double s2d_parse_time = (stop - start) / (double) iterations;
        s2d_parse_time_mv.update(s2d_parse_time);

        // DoubleUtils.toString
        System.gc();
        System.gc();
        start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          throwaway += DoubleUtils.toString(f).length();
        }
        stop = System.nanoTime();
        double jaffer_time = (stop - start) / (double) iterations;
        jaffer_time_mv.update(jaffer_time);
        jaffer_len_mv.update(DoubleUtils.toString(f).length());

        // Doubleback.doubleToString
        double d2s_len = 0.0;
        System.gc();
        System.gc();
        start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          throwaway += Doubleback.doubleToString(f).length();
        }
        stop = System.nanoTime();
        double d2s_time = (stop - start) / (double) iterations;
        d2s_time_mv.update(d2s_time);
        d2s_len_mv.update(Doubleback.doubleToString(f).length());

        // Doubleback.dfmt
        System.gc();
        System.gc();
        start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          throwaway += Doubleback.dfmt(f).length();
        }
        stop = System.nanoTime();
        double dfmt_time = (stop - start) / (double) iterations;
        dfmt_time_mv.update(dfmt_time - 30);
        dfmt_len_mv.update(Doubleback.dfmt(f).length());

        // Double.toString
        System.gc();
        System.gc();
        start = System.nanoTime();
        for (int j = 0; j < iterations; j++) {
          throwaway += Double.toString(f).length();
        }
        stop = System.nanoTime();
        double jdk_time = (stop - start) / (double) iterations;
        jdk_time_mv.update(jdk_time);
        jdk_len_mv.update(Double.toString(f).length());

        if (!bydigits && csv) {
          System.out.printf("%s,%s,%s,%s,",
              Long.toUnsignedString(r),
              Double.toString(f),
              Double.valueOf(jdk_time),
              Double.valueOf(Double.toString(f).length()));

          System.out.printf("%s,%s,%s,",
              DoubleUtils.toString(f),
              Double.valueOf(jaffer_time),
              Double.valueOf(DoubleUtils.toString(f).length()));

          System.out.printf("%s,%s,%s,",
              Doubleback.doubleToString(f),
              Double.valueOf(d2s_time),
              Double.valueOf(Doubleback.doubleToString(f).length()));

          System.out.printf("%s,%s,%s,",
              Doubleback.doubleToString(f),
              Double.valueOf(dfmt_time),
              Double.valueOf(Doubleback.dfmt(f).length()));

          System.out.printf("\n");
        }
      }
      if (bydigits) {
        if (csv) {
          System.out.printf("%d,", precision);
          System.out.printf("%.3f,%.3f,",
            Double.valueOf(jdk_time_mv.mean()), Double.valueOf(jdk_time_mv.stddev()));
          System.out.printf("%.3f,%.3f,",
            Double.valueOf(jdk_len_mv.mean()), Double.valueOf(jdk_len_mv.stddev()));

          System.out.printf("%.3f,%.3f,",
            Double.valueOf(jaffer_time_mv.mean()), Double.valueOf(jaffer_time_mv.stddev()));
          System.out.printf("%.3f,%.3f,",
            Double.valueOf(jaffer_len_mv.mean()), Double.valueOf(jaffer_len_mv.stddev()));

          System.out.printf("%.3f,%.3f,",
            Double.valueOf(d2s_time_mv.mean()), Double.valueOf(d2s_time_mv.stddev()));
          System.out.printf("%.3f,%.3f,",
            Double.valueOf(d2s_len_mv.mean()), Double.valueOf(d2s_len_mv.stddev()));

          System.out.printf("%.3f,%.3f,",
            Double.valueOf(dfmt_time_mv.mean()), Double.valueOf(dfmt_time_mv.stddev()));
          System.out.printf("%.3f,%.3f,",
            Double.valueOf(dfmt_len_mv.mean()), Double.valueOf(dfmt_len_mv.stddev()));

          System.out.printf("%.3f,%.3f,",
            Double.valueOf(jdk_parse_time_mv.mean()), Double.valueOf(jdk_parse_time_mv.stddev()));

          System.out.printf("%.3f,%.3f",
            Double.valueOf(s2d_parse_time_mv.mean()), Double.valueOf(s2d_parse_time_mv.stddev()));

          System.out.printf("\n");
        } else {
          System.out.printf("%-7d ", precision);
          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(jdk_time_mv.mean()), Double.valueOf(jdk_time_mv.stddev()));
          System.out.printf("%5.1f ±%-5.1f",
            Double.valueOf(jdk_len_mv.mean()), Double.valueOf(jdk_len_mv.stddev()));

          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(jaffer_time_mv.mean()), Double.valueOf(jaffer_time_mv.stddev()));
          System.out.printf("%5.1f ±%-5.1f",
            Double.valueOf(jaffer_len_mv.mean()), Double.valueOf(jaffer_len_mv.stddev()));

          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(d2s_time_mv.mean()), Double.valueOf(d2s_time_mv.stddev()));
          System.out.printf("%5.1f ±%-5.1f",
            Double.valueOf(d2s_len_mv.mean()), Double.valueOf(d2s_len_mv.stddev()));

          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(dfmt_time_mv.mean()), Double.valueOf(dfmt_time_mv.stddev()));
          System.out.printf("%5.1f ±%-5.1f",
            Double.valueOf(dfmt_len_mv.mean()), Double.valueOf(dfmt_len_mv.stddev()));

          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(jdk_parse_time_mv.mean()), Double.valueOf(jdk_parse_time_mv.stddev()));

          System.out.printf("%7.1f ±%-7.1f",
            Double.valueOf(s2d_parse_time_mv.mean()), Double.valueOf(s2d_parse_time_mv.stddev()));

          System.out.printf("\n");
        }
      }
    }
    if (!bydigits && !csv) {
      System.out.printf("Print Time in ns:\n");
      System.out.printf(" %-20s: %7.2f ±%-7.2f\n", "jdk Double.toString",
                        Double.valueOf(jdk_time_mv.mean()), Double.valueOf(jdk_time_mv.stddev()));
      System.out.printf(" %-20s: %7.2f ±%-7.2f\n", "Doubleback dfmt",
                        Double.valueOf(dfmt_time_mv.mean()), Double.valueOf(dfmt_time_mv.stddev()));
  
      System.out.printf("\nLength in characters:\n");
      System.out.printf(" %-20s: %7.2f ±%-7.2f\n", "jdk Double.toString",
                        Double.valueOf(jdk_len_mv.mean()), Double.valueOf(jdk_len_mv.stddev()));
      System.out.printf(" %-20s: %7.2f ±%-7.2f\n", "Doubleback dfmt",
                        Double.valueOf(dfmt_len_mv.mean()), Double.valueOf(dfmt_len_mv.stddev()));
  
      System.out.printf("\ndfmt prints %.3f TIMES FASTER than Double.toString!\n", Double.valueOf(jdk_time_mv.mean()) / Double.valueOf(dfmt_time_mv.mean()));
  
      System.out.printf("\nParse Time in ns: \n");
      System.out.printf(" %7s: %7.2f ±%-7.2f\n", "jdk parse",
                        Double.valueOf(jdk_parse_time_mv.mean()), Double.valueOf(jdk_parse_time_mv.stddev()));
      System.out.printf(" %7s: %7.2f ±%-7.2f\n", "dparse",
                        Double.valueOf(s2d_parse_time_mv.mean()), Double.valueOf(s2d_parse_time_mv.stddev()));
  
      System.out.printf("\ndparse parses %.3f TIMES FASTER than strtod!\n",
                        Double.valueOf(jdk_parse_time_mv.mean()) / Double.valueOf(s2d_parse_time_mv.mean()));
    }

    return throwaway + (int) throwaway_f;
  }
}
