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

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

class DfmtEcho {
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        String nextValue;
        while ((nextValue = br.readLine()) != null) {
            try {
                double f = Doubleback.dparse(nextValue);
                System.out.println(Doubleback.dfmt(f));
            }
            catch (IllegalArgumentException e) {
                System.out.println("ERROR");
            }
        }
    }
}
