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

package com.ironmeld.doubleback;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public abstract class DoubleToStringTest {
  abstract String f(double f, RoundingMode roundingMode);

  private void assertD2sEquals(String expected, double f) {
    assertEquals(expected, f(f, RoundingMode.ROUND_EVEN));
    assertEquals(expected, f(f, RoundingMode.CONSERVATIVE));
  }

  private void assertD2sEquals(String expectedRoundEven, String expectedConservative, double f) {
    assertEquals(expectedRoundEven, f(f, RoundingMode.ROUND_EVEN));
    assertEquals(expectedConservative, f(f, RoundingMode.CONSERVATIVE));
  }

  @Test
  public void simpleCases() {
    assertD2sEquals("0", 0);
    assertD2sEquals("-0", Double.longBitsToDouble(0x8000000000000000L));
    assertD2sEquals("1", 1.0d);
    assertD2sEquals("-1", -1.0d);
    assertD2sEquals("NaN", Double.NaN);
    assertD2sEquals("Infinity", Double.POSITIVE_INFINITY);
    assertD2sEquals("-Infinity", Double.NEGATIVE_INFINITY);
  }

  @Test
  public void switchToSubnormal() {
    assertD2sEquals("2.2250738585072014E-308", Double.longBitsToDouble(0x0010000000000000L));
  }

  /**
   * Floating point values in the range 1.0E-3 <= x < 1.0E7 have to be printed
   * without exponent. This test checks the values at those boundaries.
   */
  @Test
  public void boundaryConditions() {
    // x = 1.0E7
    assertD2sEquals("1.0E7", 1.0E7d);
    // x < 1.0E7
    assertD2sEquals("9999999.999999998", 9999999.999999998d);
    // x = 1.0E-3
    assertD2sEquals("0.001", 0.001d);
    // x < 1.0E-3
    assertD2sEquals("9.999999999999998E-4", 0.0009999999999999998d);
  }

  @Test
  public void minAndMax() {
    assertD2sEquals("1.7976931348623157E308", Double.longBitsToDouble(0x7fefffffffffffffL));
    assertD2sEquals("4.9E-324", Double.longBitsToDouble(1));
  }

  @Test
  public void roundingModeEven() {
    assertD2sEquals("-2.109808898695963E16", "-2.1098088986959632E16", -2.109808898695963E16);
  }

  @Test
  public void regressionTest() {
    assertD2sEquals("4.940656E-318", 4.940656E-318d);
    assertD2sEquals("1.18575755E-316", 1.18575755E-316d);
    assertD2sEquals("2.989102097996E-312", 2.989102097996E-312d);
    assertD2sEquals("9.0608011534336E15", 9.0608011534336E15d);
    assertD2sEquals("4.708356024711512E18", 4.708356024711512E18);
    assertD2sEquals("9.409340012568248E18", 9.409340012568248E18);
    // This number naively requires 65 bit for the intermediate results if we reduce the lookup
    // table by half. This checks that we don't loose any information in that case.
    assertD2sEquals("1.8531501765868567E21", 1.8531501765868567E21);
    assertD2sEquals("-3.347727380279489E33", -3.347727380279489E33);
    // Discovered by Andriy Plokhotnyuk, see #29.
    assertD2sEquals("1.9430376160308388E16", 1.9430376160308388E16);
    assertD2sEquals("-6.9741824662760956E19", -6.9741824662760956E19);
    assertD2sEquals("4.3816050601147837E18", 4.3816050601147837E18);
  }
}
