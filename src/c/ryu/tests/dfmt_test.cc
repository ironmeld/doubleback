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

#include <math.h>

#include "ryu/ryu.h"
#include "third_party/gtest/gtest.h"

static double int64Bits2Double(uint64_t bits) {
  double f;
  memcpy(&f, &bits, sizeof(double));
  return f;
}

static double ieeeParts2Double(const bool sign, const uint32_t ieeeExponent, const uint64_t ieeeMantissa) {
  assert(ieeeExponent <= 2047);
  assert(ieeeMantissa <= ((uint64_t)1 << 53) - 1);
  return int64Bits2Double(((uint64_t)sign << 63) | ((uint64_t)ieeeExponent << 52) | ieeeMantissa);
}

#define ASSERT_DFMT(a, b) { char result[32]; dfmt(b, result); ASSERT_STREQ(a, result); } while (0);

TEST(DFmtTest, Basic) {
  ASSERT_DFMT("0.0", 0.0);
  ASSERT_DFMT("-0.0", -0.0);
  ASSERT_DFMT("1.0", 1.0);
  ASSERT_DFMT("-1.0", -1.0);
  ASSERT_DFMT("NaN", NAN);
  ASSERT_DFMT("Infinity", INFINITY);
  ASSERT_DFMT("-Infinity", -INFINITY);
}

TEST(DFmtTest, SwitchToSubnormal) {
  ASSERT_DFMT("2.2250738585072014e-308", 2.2250738585072014e-308);
}

TEST(DFmtTest, MinAndMax) {
  ASSERT_DFMT("1.7976931348623157e308", int64Bits2Double(0x7fefffffffffffff));
  ASSERT_DFMT("5e-324", int64Bits2Double(1));
}

TEST(DFmtTest, LotsOfTrailingZeros) {
  ASSERT_DFMT("2.9802322387695312e-8", 2.98023223876953125e-8);
}

TEST(DFmtTest, Regression) {
  ASSERT_DFMT("-21098088986959630.0", -2.109808898695963e16);
  ASSERT_DFMT("4.940656e-318", 4.940656e-318);
  ASSERT_DFMT("1.18575755e-316", 1.18575755e-316);
  ASSERT_DFMT("2.989102097996e-312", 2.989102097996e-312);
  ASSERT_DFMT("9060801153433600.0", 9.0608011534336e15);
  ASSERT_DFMT("4.708356024711512e18", 4.708356024711512e18);
  ASSERT_DFMT("9.409340012568248e18", 9.409340012568248e18);
  ASSERT_DFMT("1.2345678", 1.2345678);
}

TEST(DFmtTest, LooksLikePow5) {
  // These numbers have a mantissa that is a multiple of the largest power of 5 that fits,
  // and an exponent that causes the computation for q to result in 22, which is a corner
  // case for Ryu.
  ASSERT_DFMT("5.764607523034235e39", int64Bits2Double(0x4830F0CF064DD592));
  ASSERT_DFMT("1.152921504606847e40", int64Bits2Double(0x4840F0CF064DD592));
  ASSERT_DFMT("2.305843009213694e40", int64Bits2Double(0x4850F0CF064DD592));
}

TEST(DFmtTest, OutputLength) {
  ASSERT_DFMT("1.0", 1); // already tested in Basic
  ASSERT_DFMT("1.2", 1.2);
  ASSERT_DFMT("1.23", 1.23);
  ASSERT_DFMT("1.234", 1.234);
  ASSERT_DFMT("1.2345", 1.2345);
  ASSERT_DFMT("1.23456", 1.23456);
  ASSERT_DFMT("1.234567", 1.234567);
  ASSERT_DFMT("1.2345678", 1.2345678); // already tested in Regression
  ASSERT_DFMT("1.23456789", 1.23456789);
  ASSERT_DFMT("1.234567895", 1.234567895); // 1.234567890 would be trimmed
  ASSERT_DFMT("1.2345678901", 1.2345678901);
  ASSERT_DFMT("1.23456789012", 1.23456789012);
  ASSERT_DFMT("1.234567890123", 1.234567890123);
  ASSERT_DFMT("1.2345678901234", 1.2345678901234);
  ASSERT_DFMT("1.23456789012345", 1.23456789012345);
  ASSERT_DFMT("1.234567890123456", 1.234567890123456);
  ASSERT_DFMT("1.2345678901234567", 1.2345678901234567);

  // Test 32-bit chunking
  ASSERT_DFMT("4.294967294", 4.294967294); // 2^32 - 2
  ASSERT_DFMT("4.294967295", 4.294967295); // 2^32 - 1
  ASSERT_DFMT("4.294967296", 4.294967296); // 2^32
  ASSERT_DFMT("4.294967297", 4.294967297); // 2^32 + 1
  ASSERT_DFMT("4.294967298", 4.294967298); // 2^32 + 2
}

// Test min, max shift values in shiftright128
TEST(DFmtTest, MinMaxShift) {
  const uint64_t maxMantissa = ((uint64_t)1 << 53) - 1;

  // 32-bit opt-size=0:  49 <= dist <= 50
  // 32-bit opt-size=1:  30 <= dist <= 50
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  30 <= dist <= 50
  ASSERT_DFMT("1.7800590868057611e-307", ieeeParts2Double(false, 4, 0));
  // 32-bit opt-size=0:  49 <= dist <= 49
  // 32-bit opt-size=1:  28 <= dist <= 49
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  28 <= dist <= 50
  ASSERT_DFMT("2.8480945388892175e-306", ieeeParts2Double(false, 6, maxMantissa));
  // 32-bit opt-size=0:  52 <= dist <= 53
  // 32-bit opt-size=1:   2 <= dist <= 53
  // 64-bit opt-size=0:  53 <= dist <= 53
  // 64-bit opt-size=1:   2 <= dist <= 53
  ASSERT_DFMT("2.446494580089078e-296", ieeeParts2Double(false, 41, 0));
  // 32-bit opt-size=0:  52 <= dist <= 52
  // 32-bit opt-size=1:   2 <= dist <= 52
  // 64-bit opt-size=0:  53 <= dist <= 53
  // 64-bit opt-size=1:   2 <= dist <= 53
  ASSERT_DFMT("4.8929891601781557e-296", ieeeParts2Double(false, 40, maxMantissa));

  // 32-bit opt-size=0:  57 <= dist <= 58
  // 32-bit opt-size=1:  57 <= dist <= 58
  // 64-bit opt-size=0:  58 <= dist <= 58
  // 64-bit opt-size=1:  58 <= dist <= 58
  ASSERT_DFMT("18014398509481984.0", ieeeParts2Double(false, 1077, 0));
  // 32-bit opt-size=0:  57 <= dist <= 57
  // 32-bit opt-size=1:  57 <= dist <= 57
  // 64-bit opt-size=0:  58 <= dist <= 58
  // 64-bit opt-size=1:  58 <= dist <= 58
  ASSERT_DFMT("36028797018963964.0", ieeeParts2Double(false, 1076, maxMantissa));
  // 32-bit opt-size=0:  51 <= dist <= 52
  // 32-bit opt-size=1:  51 <= dist <= 59
  // 64-bit opt-size=0:  52 <= dist <= 52
  // 64-bit opt-size=1:  52 <= dist <= 59
  ASSERT_DFMT("2.900835519859558e-216", ieeeParts2Double(false, 307, 0));
  // 32-bit opt-size=0:  51 <= dist <= 51
  // 32-bit opt-size=1:  51 <= dist <= 59
  // 64-bit opt-size=0:  52 <= dist <= 52
  // 64-bit opt-size=1:  52 <= dist <= 59
  ASSERT_DFMT("5.801671039719115e-216", ieeeParts2Double(false, 306, maxMantissa));

  // https://github.com/ulfjack/ryu/commit/19e44d16d80236f5de25800f56d82606d1be00b9#commitcomment-30146483
  // 32-bit opt-size=0:  49 <= dist <= 49
  // 32-bit opt-size=1:  44 <= dist <= 49
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  44 <= dist <= 50
  ASSERT_DFMT("3.196104012172126e-27", ieeeParts2Double(false, 934, 0x000FA7161A4D6E0Cu));
}

TEST(DfmtTest, SmallIntegers) {
  ASSERT_DFMT("9007199254740991.0", 9007199254740991.0); // 2^53-1
  ASSERT_DFMT("9007199254740992.0", 9007199254740992.0); // 2^53

  ASSERT_DFMT("1.0", 1.0e0);
  ASSERT_DFMT("12.0", 1.2e1);
  ASSERT_DFMT("123.0", 1.23e2);
  ASSERT_DFMT("1234.0", 1.234e3);
  ASSERT_DFMT("12345.0", 1.2345e4);
  ASSERT_DFMT("123456.0", 1.23456e5);
  ASSERT_DFMT("1234567.0", 1.234567e6);
  ASSERT_DFMT("12345678.0", 1.2345678e7);
  ASSERT_DFMT("123456789.0", 1.23456789e8);
  ASSERT_DFMT("1234567890.0", 1.23456789e9);
  ASSERT_DFMT("1234567895.0", 1.234567895e9);
  ASSERT_DFMT("12345678901.0", 1.2345678901e10);
  ASSERT_DFMT("123456789012.0", 1.23456789012e11);
  ASSERT_DFMT("1234567890123.0", 1.234567890123e12);
  ASSERT_DFMT("12345678901234.0", 1.2345678901234e13);
  ASSERT_DFMT("123456789012345.0", 1.23456789012345e14);
  ASSERT_DFMT("1234567890123456.0", 1.234567890123456e15);

  // 10^i
  ASSERT_DFMT("1.0", 1.0e+0);
  ASSERT_DFMT("10.0", 1.0e+1);
  ASSERT_DFMT("100.0", 1.0e+2);
  ASSERT_DFMT("1000.0", 1.0e+3);
  ASSERT_DFMT("10000.0", 1.0e+4);
  ASSERT_DFMT("100000.0", 1.0e+5);
  ASSERT_DFMT("1000000.0", 1.0e+6);
  ASSERT_DFMT("10000000.0", 1.0e+7);
  ASSERT_DFMT("100000000.0", 1.0e+8);
  ASSERT_DFMT("1000000000.0", 1.0e+9);
  ASSERT_DFMT("10000000000.0", 1.0e+10);
  ASSERT_DFMT("100000000000.0", 1.0e+11);
  ASSERT_DFMT("1000000000000.0", 1.0e+12);
  ASSERT_DFMT("10000000000000.0", 1.0e+13);
  ASSERT_DFMT("100000000000000.0", 1.0e+14);
  ASSERT_DFMT("1000000000000000.0", 1.0e+15);

  // 10^15 + 10^i
  ASSERT_DFMT("1000000000000001.0", 1.0e+15 + 1.0e+0);
  ASSERT_DFMT("1000000000000010.0", 1.0e+15 + 1.0e+1);
  ASSERT_DFMT("1000000000000100.0", 1.0e+15 + 1.0e+2);
  ASSERT_DFMT("1000000000001000.0", 1.0e+15 + 1.0e+3);
  ASSERT_DFMT("1000000000010000.0", 1.0e+15 + 1.0e+4);
  ASSERT_DFMT("1000000000100000.0", 1.0e+15 + 1.0e+5);
  ASSERT_DFMT("1000000001000000.0", 1.0e+15 + 1.0e+6);
  ASSERT_DFMT("1000000010000000.0", 1.0e+15 + 1.0e+7);
  ASSERT_DFMT("1000000100000000.0", 1.0e+15 + 1.0e+8);
  ASSERT_DFMT("1000001000000000.0", 1.0e+15 + 1.0e+9);
  ASSERT_DFMT("1000010000000000.0", 1.0e+15 + 1.0e+10);
  ASSERT_DFMT("1000100000000000.0", 1.0e+15 + 1.0e+11);
  ASSERT_DFMT("1001000000000000.0", 1.0e+15 + 1.0e+12);
  ASSERT_DFMT("1010000000000000.0", 1.0e+15 + 1.0e+13);
  ASSERT_DFMT("1100000000000000.0", 1.0e+15 + 1.0e+14);

  // Largest power of 2 <= 10^(i+1)
  ASSERT_DFMT("8.0", 8.0);
  ASSERT_DFMT("64.0", 64.0);
  ASSERT_DFMT("512.0", 512.0);
  ASSERT_DFMT("8192.0", 8192.0);
  ASSERT_DFMT("65536.0", 65536.0);
  ASSERT_DFMT("524288.0", 524288.0);
  ASSERT_DFMT("8388608.0", 8388608.0);
  ASSERT_DFMT("67108864.0", 67108864.0);
  ASSERT_DFMT("536870912.0", 536870912.0);
  ASSERT_DFMT("8589934592.0", 8589934592.0);
  ASSERT_DFMT("68719476736.0", 68719476736.0);
  ASSERT_DFMT("549755813888.0", 549755813888.0);
  ASSERT_DFMT("8796093022208.0", 8796093022208.0);
  ASSERT_DFMT("70368744177664.0", 70368744177664.0);
  ASSERT_DFMT("562949953421312.0", 562949953421312.0);
  ASSERT_DFMT("9007199254740992.0", 9007199254740992.0);

  // 1000 * (Largest power of 2 <= 10^(i+1))
  ASSERT_DFMT("8000.0", 8.0e+3);
  ASSERT_DFMT("64000.0", 64.0e+3);
  ASSERT_DFMT("512000.0", 512.0e+3);
  ASSERT_DFMT("8192000.0", 8192.0e+3);
  ASSERT_DFMT("65536000.0", 65536.0e+3);
  ASSERT_DFMT("524288000.0", 524288.0e+3);
  ASSERT_DFMT("8388608000.0", 8388608.0e+3);
  ASSERT_DFMT("67108864000.0", 67108864.0e+3);
  ASSERT_DFMT("536870912000.0", 536870912.0e+3);
  ASSERT_DFMT("8589934592000.0", 8589934592.0e+3);
  ASSERT_DFMT("68719476736000.0", 68719476736.0e+3);
  ASSERT_DFMT("549755813888000.0", 549755813888.0e+3);
  ASSERT_DFMT("8796093022208000.0", 8796093022208.0e+3);
}
