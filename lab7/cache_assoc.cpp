#include <cstdlib>
#include <iostream>
#include <intrin.h>

using namespace std;

#define L1_cache 131072  // 128 Kb - for 4 cores (32 Kb - on each core)
#define L2_cache 1048576 // 1 MB - for 4 cores (256 Kb - on each core)
#define L3_cache 8388608 // 8 MB

// L1 bank = 4096 bytes
// L2 bank = 65536 bytes
// L3 bank = 524288 bytes
// Sum of caches = 2392064 bytes???

#define L1_offset 8192    // 2 * L1 bank size
#define L2_offset 131072  // 2 * L2 bank size
#define L3_offset 8388608 // 16 * L3 bank size
// better to use L3_offset * 2

double count(int *arr, size_t offset)
{
    volatile size_t k = 0;
    double time = __rdtsc();
    for (volatile size_t i = 0; i < 10 * offset; ++i)
    {
        k = arr[k];
    }
    time = __rdtsc() - time;
    return time / (10 * offset); // average time
}

void FillArray(int *array, int const offset, int n)
{
    for (size_t i = 0; i < offset; ++i)
    {
        for (size_t j = 0; j < n - 1; ++j)
        {
            array[j * offset + i] = (j + 1) * offset + i;
        }
        array[(n - 1) * offset + i] = (i + 1) % offset; // next row
    }
}

int main()
{
    // programm works only with one core
    // L3 cache is common for all cores

    // for different cache levels - different parameters of offset
    // offset - size of cache (level)
    // offset можно брать кратынй размеру банка

    // 1) x[0]
    // 2) x[0 + sizeof(cache)]
    // 3) x[0 + 2 * sizeof(cache)]
    // 4) x[1]
    // 5) x[1 + sizeof(cache)]
    // 6) x[1 + 2 * sizeof(cache)]

    //если offset = НОК(L1, L2, L3) --> ловим все три ступени
    //размер фрагмента - не больше чем кэш строка

    //для L3 прыжок можно заметить невсегда

    // 8192 - for counting L1 - works good (1024 - also good)
    // 16384 - for counting L2 associativity (524288 better)
    // 8388608 - for L3???

    // const int offset = L3_cache;
    // const int offset = (L3_cache) / 2;

    // const int offset = 2359296;//bad
    const int offset = 131092;

    int *array = new int[32 * offset];
    for (int i = 1; i <= 32; ++i)
    {
        FillArray(array, offset, i);
        cout << count(array, offset * i) << endl;
    }
    delete[] array;
    return 0;
}
