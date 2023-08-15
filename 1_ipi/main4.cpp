#include <iostream>
#include "fcpp.hh"

// 1a)
float determinante_float(float a, float b, float c, float d)
{
	return a * d - b * c;
}
double determinante_double(double a, double b, double c, double d)
{
	return a * d - b * c;
}

// 2)
float zins(float z, int32_t n)
{
	return pow(1.0f + z / (float)n, n) - 1.0f;
}
double zins(double z, int32_t n)
{
	return pow(1.0 + z / (double)n, n) - 1.0;
}

// 3a)
bool prim(int32_t zahl)
{
	int32_t sqrtZahl = (int32_t)sqrt(zahl) + 1;
	for (int32_t i = 2; i <= sqrtZahl; ++i)
	{
		if (zahl % i == 0)
		{
			return false;
		}
	}
	return true;
}

int prim_anzahl_while(int32_t untere, int32_t obere)
{
	int32_t anzahl = 0;
	int32_t aktuelleZahl = untere;
	while (aktuelleZahl <= obere)
	{
		if (prim(aktuelleZahl))
		{
			anzahl++;
		}
		aktuelleZahl++;
	}
	return anzahl;
}

int prim_anzahl_for(int32_t untere, int32_t obere)
{
	int32_t anzahl = 0;
	for (int32_t aktuelleZahl = untere; aktuelleZahl <= obere; ++aktuelleZahl)
	{
		if (prim(aktuelleZahl))
		{
			anzahl++;
		}
	}
	return anzahl;
}

int prim_anzahl_goto(int32_t untere, int32_t obere)
{
	int32_t anzahl = 0;
	int32_t aktuelleZahl = untere;
	Loop:
	if (prim(aktuelleZahl))
	{
		anzahl++;
	}
	aktuelleZahl++;
	if (aktuelleZahl <= obere)
	{
		goto Loop;
	}
	return anzahl;
}


int main()
{
	// 1a)
	std::cout << "1a)\n";
	std::cout << "det(A) with float: " << determinante_float(100.0f, 0.01f, -0.01f, 100.0f)
			  << ", with double: " << determinante_double(100.0, 0.01, -0.01, 100.0) << std::endl;
	std::cout << "det(B) with float: " << determinante_float(1.0f, 1.0f, 0.9f, 1.9f)
			  << ", with double: " << determinante_double(1.0, 1.0, 0.9, 1.9) << std::endl;
	// Ergebnis: sowohl die float als auch die double Methode berechnet det(Mat2x2) exakt.

	// 1b)
	std::cout << "\n1b)\n";
	for (uint32_t n = 1; n <= 14; ++n)
	{
		float a = pow(10.0f, n);
		float b = -pow(10.0f, n);
		float c = pow(10.0f, -(int32_t)n);
		std::cout << "n = " << n << std::endl;
		std::cout << "\ta = 10^n, b = -10^n, c = 10^-n" << std::endl;
		std::cout << "\t(a + b) + c = " << (a + b) + c << std::endl;;
		std::cout << "\ta + (b + c) = " << a + (b + c) << std::endl << std::endl;

		a = pow(2.0f, n);
		b = -pow(2.0f, n);
		c = pow(2.0f, -(int32_t)n);
		std::cout << "\ta = 2^n, b = -2^n, c = 2^-n" << std::endl;
		std::cout << "\t(a + b) + c = " << (a + b) + c << std::endl;;
		std::cout << "\ta + (b + c) = " << a + (b + c) << std::endl;;
	}
	// Ergebnis: Ab n = 2 gilt keine Assoziativität mehr für die Zehnerpotenzen, da C++ die Werte intern in binär darstellt.
	// Dieser Basiswechsel sorgt dafür, dass manche Zahlen zwar in 10er Basis, aber nicht in 2er Basis abbildbar sind, z.B. 10^-1.

	// 2)
	std::cout << "\n2)\n";
	float zinsf = zins(0.06f, 1);
	float zinsd = zins(0.06, 1);

	std::cout << "n = 1:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf)  << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;

	zinsf = zins(0.06f, 12);
	zinsd = zins(0.06, 12);
	std::cout << "n = 12:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf) << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;

	zinsf = zins(0.06f, 365);
	zinsd = zins(0.06, 365);
	std::cout << "n = 365:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf) << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;

	zinsf = zins(0.06f, 365 * 24);
	zinsd = zins(0.06, 365 * 24);
	std::cout << "n = 365 * 24:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf) << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;

	zinsf = zins(0.06f, 365 * 24 * 60);
	zinsd = zins(0.06, 365 * 24 * 60);
	std::cout << "n = 365 * 24 * 60:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf) << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;

	zinsf = zins(0.06f, 365 * 24 * 60 * 60);
	zinsd = zins(0.06, 365 * 24 * 60 * 60);
	std::cout << "n = 365 * 24 * 60 * 60:\n";
	std::cout << "\tfloat: " << zinsf << std::endl;
	std::cout << "\tfloat diff zu exp: " << abs(exp(0.06f) - 1.0f - zinsf) << std::endl;
	std::cout << "\tdouble: " << zinsd << std::endl;
	std::cout << "\tdouble diff zu exp: " << abs(exp(0.06) - 1.0 - zinsd) << std::endl;
	// Ergebnis: Die tatsächlichen effektiven Zinssätze sind e^0.06 - 1, also ungefähr 0,06184.
	// Bei exakter Rechnung wäre float diff zu exp = 0 und double diff zu exp = 0 zu erwarten.
	// Die abweichung wird kleiner, je größer n wird, da zins(z, n) -> e^z - 1 konvergiert(n->inf).
	
	// 3)
	std::cout << "\n3)\n";
	std::cout << "prim(11) = " << prim(11) << " prim(12) = " << prim(12) << std::endl;
	std::cout << "prim_anzahl_while(11, 100) = " << prim_anzahl_while(11, 100) << std::endl;
	std::cout << "prim_anzahl_for(11, 100) = " << prim_anzahl_for(11, 100) << std::endl;
	std::cout << "prim_anzahl_goto(11, 100) = " << prim_anzahl_goto(11, 100) << std::endl;

	return EXIT_SUCCESS;
}