#include "fcpp.hh"
#include <math.h>
#include <iostream>



// Datentyp für komplexe Zahlen
typedef struct cdouble {
  double real;
  double imag;
  cdouble operator+ (cdouble z);
  cdouble operator* (cdouble z);
} cdouble;

// a) Komplexe Addititon
cdouble cdouble::operator+ (cdouble z){
    cdouble w;
    w.real = real + z.real;
    w.imag = imag + z.imag;
    return w;
}
// a) Komplexe Multiplikation

cdouble cdouble::operator* (cdouble z){
    cdouble w;
    w.real = real*z.real - imag*z.imag;
    w.imag = real*z.imag + imag*z.real;
    return w;
}

// a) Betrag einer komplexen Zahl
double magnitude(const cdouble& c) {
  double x = c.imag*c.imag + c.real*c.real;
  return x;
}
// Komplexe Zahl auf Konsole ausgeben, z.B. mit print(c);
std::ostream& operator<< (std::ostream& out, const cdouble& c) {
  out << c.real << ((c.imag >= 0 ) ? " +" : " ") << c.imag << "i";
  return out;
}



// Klasse für Mandelbrot-Fraktal
// template< > erlaubt uns, der Klasse beim Benutzen bestimmte Konstanten mitzugeben, siehe unten in main()
template <const int WIDTH, const int HEIGHT>
class Mandelbrot {

  private:

    // Komplexe Zahlen für die Berechnungsformel
    // ** erzeugt Zeiger auf Zeiger, nützlich für 2D-Felder, siehe Konstruktor
    cdouble** z;
    cdouble** c;
    // Pixelwerte für das Bild
    int** v;
    // Randkoordinaten des Bildausschnitts
    double x_left, x_right, y_bottom, y_top;

  public:

    // Konstruktor
    Mandelbrot() {
      // Felder von Zeigern, jeder zeigt auf eine Spalte eines 2D-Felds
      z = new cdouble*[WIDTH];
      c = new cdouble*[WIDTH];
      v = new int*[WIDTH];
      for (int x=0; x < WIDTH; x++) {
        // Spalten sind Felder des eigentlichen Datentyps
        z[x] = new cdouble[HEIGHT];
        c[x] = new cdouble[HEIGHT];
        v[x] = new int[HEIGHT];
      }
      // Mit Startwerten füllen
      recenter();
      init();
    }

    // Destruktor
    ~Mandelbrot() {
      // Im Konstruktur reservierten Speicher in umgekehrter Reihenfolge freigeben
      for (int x=0; x < WIDTH; x++) {
        delete[] z[x];
        delete[] c[x];
        delete[] v[x];
      }
      delete[] z;
      delete[] c;
      delete[] v;
    }

    // Bildausschnitt anpassen
    // Mit direkten Werten
    void recenter(double x_left, double x_right, double y_bottom, double y_top) {
      print("Passe Bildauschnitt an...");
      this->x_left = x_left;
      this->x_right = x_right;
      this->y_bottom = y_bottom;
      this->y_top = y_top;
    }
    // c) Mit gegebenem Mittelpunkt und Breite
    void recenter(double x, double y, double width) {
      //
      // HIER EIGENEN CODE EINFÜGEN
      // ...
      //
    }
    // b) Mit fixen Standardwerten
    void recenter() {
      recenter(-2.5, 1.0, -1.1, 1.1);
    }

    // Initialiseren
    void init() {
      print("Initialisiere...");
      for (int x=0; x < WIDTH; x++)
        for (int y=0; y < HEIGHT; y++) {
          // Alle z starten mit Wert 0
          z[x][y] = { 0.0, 0.0 };
          // Alle c starten mit der jeweiligen Koordinate als komplexe Zahl
          c[x][y] = { x_left + (x_right - x_left)*((double) x/WIDTH), y_bottom + (y_top - y_bottom)*((double) y/HEIGHT)};
          // Pixelwerte starten bei 0
          v[x][y] = 0;
        }
    }

    // b) Iteration durchführen
    void iterate(int max_steps, double threshold) {
      print("Berechne...");

    }

    // Bild speichern
    void save_as_ppm() {
      print("Speichere Bild...");
      // Datei öffnen
      FILE *f = fopen("mandelbrot.ppm", "wb");
      // Header für .ppm-Format in die Datei schreiben
      fprintf(f, "P6\n%i %i 255\n", WIDTH, HEIGHT);
      // Der Reihe nach für jedes Pixel:
      for (int y=0; y < HEIGHT; y++) {
        for (int x=0; x < WIDTH; x++) {
          // Wert auf Basis von v bestimmen
          int v = this->v[x][y];
          if (v < 0) v = 0;
          if (v > 255) v = 255;
          // R, G und B jeweils als Byte in die Datei schreiben
          fputc((char) v, f);
          fputc((char) v, f);
          fputc((char) v, f);
        }
      }
      // Datei schließen
      fclose(f);
    }
};



int main() {
  // Mandelbrot-Instanz mit WIDTH=1280 und HEIGHT=800
  Mandelbrot<1280,800> m;
  // 512 Schritte iterieren mit Grenzwert 2,5
  m.iterate(512, 2.5);
  // Bild speichern
  m.save_as_ppm();

  print("Fertig :)");

  cdouble z;
  cdouble w;
  z.real = 1;
  z.imag = 0.5;
  w.real = -2;
  w.imag = -1;
  print (magnitude (z*w));

  return 0;
}
