#include <stdio.h>
#include <stdlib.h>
#include <string>
#pragma warning(disable: 4996)

#define MY_PI 3.14159265358979323846

double sine(double x, long long N) {
    x = x - (long long)(x / 2 / MY_PI) * MY_PI * 2;

    double current = x, sum = x;

    for (long long i = 3; i < 2 * N; i += 2) {
        current = -current / i / (i - 1) * x * x;
        sum += current;
    }
    return sum;
}

int main(int argc, char** argv) {
    if (argc != 3)
        exit(0);
    long long n = atoll(argv[1]);
    double x = atof(argv[2]);

    /*long n;
    double x;
    scanf("%ld", &n);
    scanf("%lf", &x);*/

    printf("sin(%lf) = %lf\n", x, sine(x, n));
    return 0;
}