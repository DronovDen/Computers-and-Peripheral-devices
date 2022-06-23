#include <iostream>
#include <ctime>
#include <cstdlib>

const int M = 10;
const int N = 2048;

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

void SubtractMatrix(float *M1, float *M2, float *M3, int N)
{
    for (size_t i = 0; i < N; i++) //selecting row
    {
        for (size_t j = 0; j < N; j++) //selecting column
        {
            M3[i * N + j] = M1[i * N + j] - M2[i * N + j];
        }
    }
}

float *MultiplicateMatrix(float *M1, float *M2, int N)
{
    float *M3 = new float[N * N];
    for (size_t i = 0; i < N * N; i++)
    {
        M3[i] = 0;
    }

    for (size_t i = 0; i < N; i++)
    {
        for (size_t k = 0; k < N; k++)
        {
            for (size_t j = 0; j < N; j++)
            {
                M3[i * N + j] += M1[i * N + k] * M2[k * N + j];
            }
        }
    }
    return M3;
}

void SumMatrix(float *M1, float *M2, float *result, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            result[i * N + j] = M1[i * N + j] + M2[i * N + j];
        }
    }
}

void GenerateMatrix(float *A, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            A[i * N + j] = (double)(rand() % 100);
        }
    }
}

float MaxLineCount(float *matrix, int N)
{
    float maximum = FLT_MIN;
    for (size_t i = 0; i < N; i++)
    {
        float temp = 0;
        for (size_t j = 0; j < N; j++)
        {
            temp += matrix[i * N + j];
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
    for (size_t i = 0; i < N; i++)
    {
        for (size_t j = 0; j < N; j++)
        {
            transpMatrix[i * N + j] = matrix[j * N + i];
        }
    }
}

void GenerateMatrixB(float *A, float *B, int N)
{
    //showMatrix(A, N);
    float *transposedA = new float[N * N];
    TransposeMatrix(transposedA, A, N);
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
}

void GenerateMatrixI(float *I, int N)
{
    for (size_t i = 0; i < N; i++)
    {
        float *matrix = I + i * N;
        for (size_t j = 0; j < N; j++)
        {
            if (i == j)
                matrix[j] = 1.0;
            else
                matrix[j] = 0.0;
        }
    }
}

void GenerateMatrixR(float *A, float *I, float *B, float *R, int N)
{
    float *multed = new float[N * N];
    multed = MultiplicateMatrix(B, A, N);
    SubtractMatrix(I, multed, R, N);
    delete[] multed;
}

float *GetInversedMatrix(float *A, int N, int M)
{
    float *I = new float[N * N];
    GenerateMatrixI(I, N);
    showMatrix(I, N);

    float *B = new float[N * N];
    GenerateMatrixB(A, B, N);
    showMatrix(B, N);

    float *R = new float[N * N];
    GenerateMatrixR(A, I, B, R, N);
    showMatrix(R, N);

    float *result = new float[N * N];
    result = I;
    showMatrix(result, N);

    float *Rn = R;
    showMatrix(Rn, N);

    for (size_t i = 0; i < M; i++)
    {
        SumMatrix(result, Rn, result, N);
        Rn = MultiplicateMatrix(Rn, R, N);
    }
    result = MultiplicateMatrix(result, B, N);

    delete[] I;
    delete[] B;
    delete[] R;
    delete[] Rn;
    return result;
}

int main()
{
    srand(time(0));
    //float *A = new float[N * N];
    //GenerateMatrix(A, N);
    /*float A[N * N] = {2, 4,
                      2, 3};*/

    /*float A[N * N] = { 2, 4, 2, 3,
                       2, 1, 5, 9,
                       1, 3, 5, 7,
                       8, 9, 2, 1};*/

    float A[N * N] = {2, 4, 2, 3, 2, 1, 5, 0,
                      8, 9, 2, 1, 1, 4, 6, 7,
                      1, 3, 5, 7, 8, 9, 2, 1,
                      7, 9, 2, 5, 1, 4, 6, 7,
                      1, 4, 6, 7, 1, 5, 5, 7,
                      2, 4, 2, 3, 2, 4, 2, 3,
                      1, 4, 6, 7, 1, 3, 5, 7,
                      0, 4, 2, 3, 2, 4, 2, 6};

    showMatrix(A, N);

    float *InversedA = GetInversedMatrix(A, N, M);

    showMatrix(InversedA, N);
    //delete[] A;
    delete[] InversedA;
    double total_time = clock() / CLOCKS_PER_SEC;
    cout << "Total time: " << total_time << " sec." << endl;
    return 0;
}