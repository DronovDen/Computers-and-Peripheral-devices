#include <iostream>
#include <intrin.h>
#include <limits>
#include <stdint.h>

using namespace std;
#define L1_cache 65536  // 64 KB
#define L2_cache 524288 // 512 KB

double count(size_t *arr, size_t size)
{
    double curMin = numeric_limits<double>::max();
    size_t k = 0;

    uint64_t start = __rdtsc();
    for (size_t i = 0; i < 20 * size; ++i)
    {
        k = arr[k];
    }
    uint64_t finish = __rdtsc();
    double sub = finish - start;
    curMin = min(curMin, sub / 20);

    if (k == 1)
        cout << "Boom" << endl;
    return curMin / size;
}

void setArr(size_t *arr, size_t n, size_t size)
{
    for (size_t i = 0; i != size; ++i)
    {
        for (size_t j = 0; j < n - 1; ++j)
        {
            arr[j * size + i] = (j + 1) * size + i;
        }
        arr[(n - 1) * size + i] = (i + 1) % size;
    }
}

void cacheSlippage(size_t n, size_t const size, string output)
{
    size_t full_size = n * size;
    size_t *arr = new size_t[full_size];

    setArr(arr, n, size);
    cout << count(arr, full_size) << output << endl;

    delete[] arr;
}

int main(int argc, char *argv[])
{
    for (size_t n = 1; n < 33; n++)
    {
        cout << n << endl; //
        cacheSlippage(n, (L2_cache) / 4, "");
        //  cout <<  endl;
    }

    return 0;
}
