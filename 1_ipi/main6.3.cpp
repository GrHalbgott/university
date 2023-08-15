#include <iostream>
#include <string>

// Fixe Größe der Matrizen
constexpr size_t SIZE = 3;

// Datentyp für Matrizen dieser Größe
struct matrix {
    int vals[SIZE][SIZE];
};

// a)
matrix matrix_zero() {
    matrix out;
    memset(out.vals, 0, sizeof(int) * SIZE * SIZE);
    return out;
}

matrix matrix_id() {
    matrix out = matrix_zero();
    for (size_t i = 0; i < SIZE; ++i)
        out.vals[i][i] = 1;
    return out;
}

// b)
matrix matrix_add(matrix left, matrix right) {
    matrix out = left;
    for (size_t row = 0; row < SIZE; ++row)
        for (size_t col = 0; col < SIZE; ++col)
            out.vals[row][col] += right.vals[row][col];
    return out;
}

// c)
matrix matrix_mult(matrix left, matrix right) {
    matrix out = matrix_zero();
    for (size_t row = 0; row < SIZE; ++row)
        for (size_t col = 0; col < SIZE; ++col)
            for (size_t i = 0; i < SIZE; ++i)
                out.vals[row][col] += left.vals[row][i] * right.vals[i][col];
    return out;
}

// Konstruktion eines mehrzeiligen Strings, der die Einträge einer Matrix darstellt
std::string to_string(matrix m) {
    std::string str = "";
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            str += std::to_string(m.vals[i][j]) + "  ";
        }
        str += "\n";
    }
    return str;
}

// d)
int main(int argc, char* argv[]) {
    // Initialisiere Matrizen
    matrix A = {
      {
        {2, 5, 4},
        {3, 2, 4},
        {1, 1, 9}
      }
    };
    matrix B = {
      {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
      }
    };
    std::cout << "add:\n" << to_string(matrix_add(A, B)) << std::endl;
    std::cout << "mult:\n" << to_string(matrix_mult(A, B)) << std::endl;
    return 1;
}
