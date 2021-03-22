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

package info.adams.ryu;

import java.util.Scanner;

class DfmtEcho {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        while (input.hasNextLine()) {
            String nextValue = input.nextLine();
            if (RyuDouble.isValid(nextValue)) {
                double f = Double.parseDouble(nextValue);
                System.out.println(RyuDouble.dfmt(f));
            } else {
                System.out.println("ERROR");
            }
        }
    }
}
