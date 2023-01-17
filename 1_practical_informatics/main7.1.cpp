#include "fcpp.hh"
#include <string>

// Anzahl Knoten im Graph = Seitenlänge der Adjazenzmatrix
const short SIZE = 10;

// Datentyp für Matrizen dieser Größe
struct matrix {
        // 2-dimensionales Feld (Vektor von Vektoren) der Größe SIZE x SIZE
        int vals[SIZE][SIZE];
};

// Konstruktion eines mehrzeiligen Strings, der die Einträge der Matrix darstellt
std::string to_string(const matrix& M) {
        std::string str = "";
        for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                        str += std::to_string(M.vals[i][j]) + "  ";
                }
                str += "\n";
        }
        return str;
}

// Kontruktion einer leeren Matrix, i.e. alle Einträge sind 0
matrix matrix_zero() {
        matrix zero;
        for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                        zero.vals[i][j] = 0;
                }
        }
        return zero;
}

// Berechnung der Einheitsmatrix
matrix matrix_id () {
        matrix id;
        for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                        if (i==j) {
                                id.vals[i][j] = 1;
                        }
                        else {
                                id.vals[i][j] = 0;
                        }
                }
        }
        return id;
}

// Matrix-Addition
matrix matrix_add(const matrix& left, const matrix& right) {
        matrix result;
        // Gehe jeden Eintrag i,j durch
        for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                        // Eintrag ist die Summe der gleichen Positionen in den Matrizen "left" und "right"
                        result.vals[i][j] = left.vals[i][j] + right.vals[i][j];
                }
        }
        return result;
}

// Matrix-Multiplikation
matrix matrix_mult(const matrix& left, const matrix& right) {
        // Initialisiere alle Einträge auf 0
        matrix result = matrix_zero();
        // Gehe jeden Eintrag i,j durch
        for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                        // Summiere die Produkte der jeweiligen Einträge der Matrizen "left" und "right" auf
                        for (int k = 0; k < SIZE; k++) {
                                result.vals[i][j] += left.vals[i][k] * right.vals[k][j];
                        }
                }
        }
        // Gib das Ergebnis zurück
        return result;
}

matrix matrix_hoch(const matrix& A, int l){
    if (l==0){return matrix_id();}
    if (l==1){return A;}
    else {return matrix_mult(matrix_hoch(A, l-1), A);}
}

matrix matrix_erreich(const matrix& A, int l){
    if (l==0){return matrix_id();}
    else {return matrix_add(matrix_erreich(A, l-1), matrix_hoch(A, l));}
}

// a)
// Transponierte einer Matrix
void matrix_transpose(matrix& M) {
    for (int i=0; i<SIZE; i++)
    {
        for (int j=0; j<i; j++)
        {
            int temp = M.vals[i][j];
            M.vals[i][j]=M.vals[j][i];
            M.vals[j][i]=temp;
        }
    }
}



// b)
// Bestimme Anzahl an Pfaden der Länge l, die von Knoten "start" zu Knoten "end" führen
int paths(const matrix& graph, int l, int start, int end) {
    matrix temp = matrix_hoch(graph, l);
    int a = temp.vals[start][end];
    return a;
}


// c)
// Gib alle Knoten aus, die in maximal l Schritten von "start" aus erreicht werden können
void reach(const matrix& graph, int l, int start) {
    matrix temp = matrix_erreich(graph, l);
    for (int i=0; i<SIZE; i++){
        if (temp.vals[start][i]>0){print(i);}
    }
}

int main(int argc, char *argv[]) {
        // Initialisiere die Adjazenzmatrix aus der Aufgabenstellung
        matrix graph = {
                        {
                                        {0,1,0,0,1,0,0,0,0,1},
                                        {1,0,0,0,0,0,0,0,1,0},
                                        {0,1,0,0,0,0,1,0,0,0},
                                        {0,0,0,0,1,0,0,0,0,1},
                                        {0,0,0,0,0,0,0,1,0,0},
                                        {0,0,0,0,0,0,1,0,0,0},
                                        {1,0,1,0,0,1,0,0,0,0},
                                        {0,0,0,1,0,0,1,0,0,0},
                                        {0,0,1,0,0,0,0,1,0,0},
                                        {0,0,0,0,0,1,0,0,1,0}
                        }
        };

  // a) Berechnung der Transponierten der Adjazenzmatrix und der zweifach Transponierten
  print("Graph");
        print(to_string(graph));
        matrix_transpose(graph);
  print("Transponierte");
        print(to_string(graph));
        matrix_transpose(graph);
  print("zweifach Transponierte (= Ausgangsgraph)");
        print(to_string(graph));

  // b)
        print(paths(graph, 4, 3, 1));
        print(paths(graph, 6, 3, 1));
        print(paths(graph, 8, 3, 1));
        print(paths(graph, 9, 3, 1));
        print("");
  // c)
  reach(graph, 2, 5);
  print("");
        reach(graph, 3, 5);
        print("");
        reach(graph, 4, 5);

        return 0;
}

