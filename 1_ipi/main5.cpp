#include "fcpp.hh"

// 2)
constexpr uint32_t ggroesse = 10;
int32_t gfeld[ggroesse];

void feld_ausgeben(int anzahl)
{  // Gibt gfeld[0] bis gfeld[anzahl-1] in einer Zeile aus
    std::cout << "Die Liste im Feld gfeld sieht wie folgt aus: ";
    for (int i = 1; i <= anzahl; i = i+1)
           std::cout << gfeld[i-1] << " ";
    std::cout << std::endl;
}

void swap(int32_t& a, int32_t& b)
{
	int32_t temp = a;
	a = b;
	b = temp;
}

void feld_bubblesort(uint32_t size)
{
	for (uint32_t i = 0; i < size - 1; ++i)
	{
		for (uint32_t j = 0; j < size - 1 - i; ++j)
		{
			if (gfeld[j] > gfeld[j + 1])
			{
				swap(gfeld[j], gfeld[j + 1]);
			}
		}
	}
}

void feld_insertionsort(uint32_t anzahl)
{
	for (uint32_t i = 1; i < anzahl; ++i)
	{
		for (uint32_t j = i; j > 0; --j)
		{
			if (gfeld[j - 1] > gfeld[j])
				swap(gfeld[j - 1], gfeld[j]);
			else
				break;
		}
	}
}

// 3)
constexpr uint32_t gnmax = 10;
uint32_t g_BinomialCache[(gnmax + 1) * (gnmax + 2) / 2];

uint32_t BinomialCachePos(uint32_t n, uint32_t k)
{
	return n * (n + 1) / 2 + k;
}
void PrecomputeBinomialCache()
{
	for (uint32_t n = 0; n <= gnmax; ++n)
	{
		g_BinomialCache[BinomialCachePos(n, 0)] = 1;
		g_BinomialCache[BinomialCachePos(n, n)] = 1;
		for (uint32_t k = 1; k < n; ++k)
			g_BinomialCache[BinomialCachePos(n, k)] = g_BinomialCache[BinomialCachePos(n - 1, k)] + g_BinomialCache[BinomialCachePos(n - 1, k - 1)];
	}
}
uint32_t BinomialKoeffizent(uint32_t n, uint32_t k)
{
	return g_BinomialCache[BinomialCachePos(n, k)];
}

int main(int32_t argc, char* argv[])
{
	std::cout << "2)" << std::endl;

	// 2)
	uint32_t anzahl = (uint32_t)argc - 1;
	if (anzahl <= ggroesse)
	{
		for (uint32_t i = 0; i < anzahl; ++i)
			gfeld[i] = std::atoi(argv[i + 1]);
		feld_ausgeben(anzahl);
		//feld_bubblesort(anzahl);
		feld_insertionsort(anzahl);
	}
	else 
		std::cout << "Bitte nicht mehr als " << ggroesse << " Werte." << std::endl;

	std::cout << "Nach Sortierung sieht sie so aus: ";
	for (uint32_t i = 0; i < anzahl; ++i)
		std::cout << gfeld[i] << " ";
	std::cout << std::endl;

	// 3)
	int32_t a, b;
	std::cout << "3)" << std::endl;
	std::cout << "Berechnung des Binomialkoeffizienten zweier Zahlen bis " << gnmax << "." << std::endl;
	std::cout << "Input Zahl 1: ";
	std::cin >> a;
	std::cout << "Input Zahl 2: ";
	std::cin >> b;
	PrecomputeBinomialCache();
	std::cout << "Binomialkoeffizient von " << a << " & " << b << " = " << BinomialKoeffizent(a, b) << std::endl;
}