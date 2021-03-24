#include <stdlib.h>
#include <stdio.h>

/* Generate 1 million random doubles in various formats */
int main(int argc, char **argv) {

    for (int i=1; i <= 1000000; i++) {
        long type = random() % 8;
        long neg = random() % 2;
        long small1 = random() % 100;
        long small2 = random() % 100;
        long med1 = random() % 10000;
        long med2 = random() % 10000;
        long large1 = random() % 1000000000;
        long large2 = random() % 100000000;
        long big1 = random();
        long big2 = random();
        long lead_digit = (random() % 9) + 1; // 1 to 9
        long exponent = (random() % 1000) - 500;

        switch (type) {
           // small.small 
           case 0:
               printf("%s%ld.%ld\n", neg ? "-" : "", small1, small2);
               break;
           // small.small w/exponent
           case 1:
               printf("%s%ld.%lde%ld\n", neg ? "-" : "", small1, small2, exponent);
               break;
           // med.med w/exponent
           case 2:
               printf("%s%ld.%ld\n", neg ? "-" : "", med1, med2);
               break;
           // med.med w/exponent
           case 3:
               printf("%s%ld.%lde%ld\n", neg ? "-" : "", med1, med2, exponent);
               break;
           // large.large
           case 4:
               printf("%s%ld.%ld\n", neg ? "-" : "", large1, large2);
               break;
           // large.large w/exponent
           case 5:
               printf("%s%ld.%lde%ld\n", neg ? "-" : "", large1, large2, exponent);
               break;
           // big.big
           case 6:
               printf("%s%ld.%ld\n", neg ? "-" : "", big1, big2);
               break;
           // big.big w/exponent
           case 7:
               printf("%s%ld.%lde%ld\n", neg ? "-" : "", big1, big2, exponent);
               break;
        }
        
    }
}
