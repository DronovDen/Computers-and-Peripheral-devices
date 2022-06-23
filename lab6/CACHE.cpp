#include <iostream>
#include <intrin.h>
#include <cmath>
#include <set>
#include <ctime>
#include <vector>

void DirectFill(int *arr, int size)
{
    for (int i = 0; i < size - 1; ++i)
    {
        arr[i] = i + 1;
    }
    arr[size - 1] = 0;
}

void ReversedFill(int *arr, int size)
{
    for (int i = size - 1; i > 0; --i)
    {
        arr[i] = i - 1;
    }
    arr[0] = size - 1;
}

int RandFromRange(int min, int max)
{
    return (rand() % (max - min + 1) + min);
}

void RandomFill(int *array, size_t size)
{
    for (size_t i = 0; i < size; i++)
    {
        array[i] = i;
    }
    for (size_t i = size - 1; i >= 1; i--)
    {
        int j = RandFromRange(0, i - 1);
        std::swap(array[i], array[j]);
    }
    bool *used = new bool[size];
    for (size_t i = 0; i < size; i++)
    {
        used[i] = false;
    }
    bool is_permutation_found = false;
    int lastIdx = -1;
    while (!is_permutation_found)
    {
        int i = 0;
        while (i < size && used[i])
        {
            i++;
        }
        if (i == size)
        {
            array[lastIdx] = 0;
            is_permutation_found = true;
        }
        else
        {
            if (lastIdx != -1)
            {
                array[lastIdx] = i;
            }
            while (!used[i])
            {
                used[i] = true;
                lastIdx = i;
                i = array[i];
            }
        }
    }
    delete[] used;
}

/*void RandomFill(int *arr, int size)
{
    auto used_num = new bool[size]{false};
    size_t next;
    for (size_t f = 0, j = 0; j != size - 1; j++)
    {
        while (true)
        {
            //next = (rand() * rand()) % size;
            next = get_random_int_in_range(0, size - 1);
            if (!used_num[next])
            {
                used_num[next] = true;
                break;
            }
        }
        arr[f] = next;
        f = next;
    }
    arr[next] = 0;
    delete[] used_num;
}*/

/*void RandomFill(int *arr, const int N)
{
    DirectFill(arr, N);
    srand(time(NULL));
    for (int i = N - 1; i >= 1; --i)
    {
        int j = rand() % (i + 1);

        std::swap(arr[i], arr[j]);
    }
}*/

double CountTime(int *arr, int size)
{
    //CACHE PREHEAT
    int k = 0;
    for (int i = 0; i < size; ++i)
    {
        k = arr[k];
    }
    if (k == 585)
        std::cout << "WOOOW!" << std::endl;

    double time = UINT64_MAX;
    for (int j = 0; j < 100; ++j)
    {
        double start = __rdtsc();
        for (int i = 0, k = 0; i < size; ++i)
        {
            k = arr[k];
            if (k == (size + 1))
                std::cout << "WOOOW!" << std::endl;
        }

        double end = __rdtsc();
        if (end - start < time)
        {
            time = end - start;
        }
    }
    return (time / size);
}

int main()
{
    //srand(clock());
    //256 - 1Kb
    //8388608 - 32Mb
    int arr[10];
    RandomFill(arr, 10);

    for (int N = 256; N < 8388608; N *= 1.2)
    {
        std::cout << "Size: " << N << std::endl;
        int *arr = new int[N];

        DirectFill(arr, N);
        double time = CountTime(arr, N);
        std::cout << "Direct bypass: " << time << " tacts" << std::endl;

        ReversedFill(arr, N);
        time = CountTime(arr, N);

        std::cout << "Reverse bypass: " << time << " tacts" << std::endl;

        RandomFill(arr, N);
        time = CountTime(arr, N);
        std::cout << "Random bypass: " << time << " tacts" << std::endl;

        std::cout << std::endl
                  << std::endl;
        delete[] arr;
    }
    return 0;
}
