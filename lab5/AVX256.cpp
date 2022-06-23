#include <iostream>
#include <ctime>
#include <cstdlib>
#include <float.h>
#include <immintrin.h>
#include <xmmintrin.h>

using namespace std;

void showMatrix(float *matrix, size_t size)
{
    size_t i, j;
    for (i = 0; i < size; ++i)
    {
        for (j = 0; j < size; ++j)
        {
            cout << matrix[i * size + j] << " ";
        }
        cout << endl;
    }
    cout << "\n"
         << "\n"
         << "\n";
}

void SubtractMatrix(float *M1, float *M2, float *result, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j += 16)
        {
            _mm256_storeu_ps(result + i * N + j, _mm256_sub_ps(_mm256_loadu_ps(M1 + i * N + j), _mm256_loadu_ps(M2 + i * N + j)));
            _mm256_storeu_ps(result + i * N + j + 8, _mm256_sub_ps(_mm256_loadu_ps(M1 + i * N + j + 8), _mm256_loadu_ps(M2 + i * N + j + 8)));
        }
    }
}

float *MultiplicateMatrix(float *M1, float *M2, int N)
{
    float *M3 = (float *)_mm_malloc(N * N * sizeof(float), 32);
    for (int i = 0; i < N; ++i)
    {
        float *m3 = M3 + i * N;
        for (size_t j = 0; j < N; j += 8)
            _mm256_storeu_ps(m3 + j, _mm256_setzero_ps());
        for (size_t k = 0; k < N; ++k)
        {
            float *m2 = M2 + k * N;
            __m256 m1 = _mm256_set1_ps(M1[i * N + k]);
            for (size_t j = 0; j < N; j += 16)
            {
                _mm256_storeu_ps(m3 + j, _mm256_fmadd_ps(m1, _mm256_loadu_ps(m2 + j), _mm256_loadu_ps(m3 + j)));
                _mm256_storeu_ps(m3 + j + 8, _mm256_fmadd_ps(m1, _mm256_loadu_ps(m2 + j + 8), _mm256_loadu_ps(m3 + j + 8)));
            }
        }
    }
    return M3;
}

void SumMatrix(float *M1, float *M2, float *result, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j += 16)
        {
            _mm256_storeu_ps(result + i * N + j, _mm256_add_ps(_mm256_loadu_ps(M1 + i * N + j), _mm256_loadu_ps(M2 + i * N + j)));
            _mm256_storeu_ps(result + i * N + j + 8, _mm256_add_ps(_mm256_loadu_ps(M1 + i * N + j + 8), _mm256_loadu_ps(M2 + i * N + j + 8)));
        }
    }
}

void GenerateMatrix(float *A, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            A[i * N + j] = (float)(rand() % 5);
        }
    }
}

float MaxLineCount(float *matrix, int N)
{
    float maximum = FLT_MIN;
    for (size_t i = 0; i < N; i++)
    {
        float temp = 0;
        int row = i * N;
        for (size_t j = 0; j < N; j++)
        {
            temp += matrix[row + j];
        }

        if (temp > maximum)
        {
            maximum = temp;
        }
    }
    return maximum;
}

void TransposeMatrix(float *transpMatrix, float *matrix, int N)
{
    for (int i = 0; i < N; i += 4)
    {
        for (int j = 0; j < N; j += 4)
        {
            __m128 row0 = _mm_load_ps(&matrix[i * N + j]);
            __m128 row1 = _mm_load_ps(&matrix[(i + 1) * N + j]);
            __m128 row2 = _mm_load_ps(&matrix[(i + 2) * N + j]);
            __m128 row3 = _mm_load_ps(&matrix[(i + 3) * N + j]);

            _MM_TRANSPOSE4_PS(row0, row1, row2, row3);

            _mm_store_ps(&transpMatrix[j * N + i], row0);
            _mm_store_ps(&transpMatrix[(j + 1) * N + i], row1);
            _mm_store_ps(&transpMatrix[(j + 2) * N + i], row2);
            _mm_store_ps(&transpMatrix[(j + 3) * N + i], row3);
        }
    }
}

void GenerateMatrixB(float *A, float *B, int N)
{
    //showMatrix(A, N);
    float *transposedA = (float *)_mm_malloc(N * N * sizeof(float), 16);
    TransposeMatrix(transposedA, A, N);
    //showMatrix(transposedA, N);
    float maxRowCount = MaxLineCount(A, N);
    float maxColumnCount = MaxLineCount(transposedA, N);
    float divider = 1 / (maxRowCount * maxColumnCount);

    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            B[i * N + j] = transposedA[i * N + j] * divider;
        }
    }
    /*__m256* mB = (__m256*)B;
    __m256* mTransposedA = (__m256*)transposedA;
    __m256 mdivider = _mm256_load_ps(&divider);
    for (size_t j = 0; j < N; j++)
    {
        mB[j] = _mm256_mul_ps(mTransposedA[j], mdivider);
    }*/
    _mm_free(transposedA);
}

void GenerateMatrixI(float *I, int N)
{
    for (size_t i = 0; i < N; ++i)
    {
        float *result = I + i * N;
        for (size_t j = 0; j < N; j += 8)
            _mm256_storeu_ps(result + j, _mm256_setzero_ps());
    }
    for (size_t i = 0; i < N; i++)
        I[i * N + i] = 1;
}

void GenerateMatrixR(float *A, float *I, float *B, float *R, int N)
{
    float *multed = (float *)_mm_malloc(N * N * sizeof(float), 32);
    multed = MultiplicateMatrix(B, A, N);
    SubtractMatrix(I, multed, R, N);
    _mm_free(multed);
}

void CopyMatrix(float *dest, float *src, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            dest[i * N + j] = src[i * N + j];
        }
    }
}

float *GetInversedMatrix(float *A, int N, int M)
{
    float *I = (float *)_mm_malloc(N * N * sizeof(float), 32);
    GenerateMatrixI(I, N);
    //showMatrix(I, N);

    float *B = (float *)_mm_malloc(N * N * sizeof(float), 32);
    GenerateMatrixB(A, B, N);
    //showMatrix(B, N);

    float *R = (float *)_mm_malloc(N * N * sizeof(float), 32);
    GenerateMatrixR(A, I, B, R, N);
    //showMatrix(R, N);

    //float* result = I;
    //float* result = (float*)_mm_malloc(N * N * sizeof(float), 32);
    //CopyMatrix(I, result, N);
    //showMatrix(result, N);

    float *Rn = R;
    //float* Rn = (float*)_mm_malloc(N * N * sizeof(float), 32);
    //CopyMatrix(R, Rn, N);
    //showMatrix(Rn, N);
    SumMatrix(I, Rn, I, N);
    for (size_t i = 0; i < M - 1; i++)
    {
        Rn = MultiplicateMatrix(Rn, R, N);
        SumMatrix(I, Rn, I, N);
    }
    I = MultiplicateMatrix(I, B, N);

    _mm_free(B);
    _mm_free(R);
    return I;
}

int main()
{
    int M = 10;
    int N = 2048;

    srand(time(0));
    clock_t a = clock();
    float *A = (float *)_mm_malloc(N * N * sizeof(float), 32);
    GenerateMatrix(A, N);

    /*float A[N * N] = { 2, 4, 2, 3, 2, 1, 5, 9, 2, 4, 2, 3, 2, 1, 5, 9,
                       1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7,
                       8, 9, 2, 1, 1, 4, 6, 7, 2, 4, 2, 3, 2, 4, 2, 3,
                       1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7,
                       8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1,
                       1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7, 
                       2, 4, 2, 3, 2, 4, 2, 3, 1, 3, 5, 7, 8, 9, 2, 1,
                       1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7,
                       2, 4, 2, 3, 2, 1, 5, 9, 2, 4, 2, 3, 2, 1, 5, 9,
                       1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7,
                       8, 9, 2, 1, 1, 4, 6, 7, 2, 4, 2, 3, 2, 4, 2, 3,
                       1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7,
                       8, 9, 2, 1, 1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1,
                       1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7,
                       2, 4, 2, 3, 2, 4, 2, 3, 1, 3, 5, 7, 8, 9, 2, 1,
                       1, 4, 6 ,7, 1, 3, 5, 7, 8, 9, 2, 1, 1, 4, 6 ,7 };*/

    /*float A[N * N] = { 2, 4, 2, 3, 2, 1, 5, 0,
                           8, 9, 2, 1, 1, 4, 6, 7,
                           1, 3, 5, 7, 8, 9, 2, 1,
                           7, 9, 2, 5, 1, 4, 6, 7,
                           1, 4, 6, 7, 1, 5, 5, 7,
                           2, 4, 2, 3, 2, 4, 2, 3,
                           1, 4, 6, 7, 1, 3, 5, 7,
                           0, 4, 2, 3, 2, 4, 2, 6 }; */

    //showMatrix(A, N);
    float *InversedA = GetInversedMatrix(A, N, M);

    //showMatrix(InversedA, N);
    double total_time = (clock() - a) / CLOCKS_PER_SEC;
    cout << "Total time: " << total_time << " sec." << endl;
    //_mm_free(A);
    _mm_free(InversedA);
    return 0;
}
