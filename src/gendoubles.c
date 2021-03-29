#include <stdlib.h>
#include <stdio.h>
#include <time.h>

/* Generate 1 million random doubles in various formats */
int main(int argc, char **argv) {
    int seed = time(NULL);
    fprintf(stderr, "rand seed is %d\n", seed);
    srand(seed);

    for (int i=1; i <= 1000000; i++) {
        int type = rand() % 9;
        int neg = rand() % 2;
        int small1 = rand() % 100;
        int small2 = rand() % 100;
        int med1 = rand() % 10000;
        int med2 = rand() % 10000;
        int large1 = rand() % 1000000000;
        int large2 = rand() % 100000000;
        int big1 = rand();
        int big2 = rand();
        int exponent = (rand() % 1000) - 500;

        switch (type) {
           // small.small 
           case 0:
               printf("%s%d.%d\n", neg ? "-" : "", small1, small2);
               break;
           // small.small w/exponent
           case 1:
               printf("%s%d.%de%d\n", neg ? "-" : "", small1, small2, exponent);
               break;
           // med.med w/exponent
           case 2:
               printf("%s%d.%d\n", neg ? "-" : "", med1, med2);
               break;
           // med.med w/exponent
           case 3:
               printf("%s%d.%de%d\n", neg ? "-" : "", med1, med2, exponent);
               break;
           // large.large
           case 4:
               printf("%s%d.%d\n", neg ? "-" : "", large1, large2);
               break;
           // large.large w/exponent
           case 5:
               printf("%s%d.%de%d\n", neg ? "-" : "", large1, large2, exponent);
               break;
           // big.big
           case 6:
               printf("%s%d.%d\n", neg ? "-" : "", big1, big2);
               break;
           // big.big w/exponent
           case 7:
               printf("%s%d.%de%d\n", neg ? "-" : "", big1, big2, exponent);
               break;

           // 0.0..0XYZ..
           case 8:
               printf("%s0.%019d%d\n", neg ? "-" : "", big1, big2);
               break;
        }
        
    }
}
