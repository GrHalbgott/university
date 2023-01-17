#include <iostream>
#include "fcpp.hh"

using namespace std;

//a)
bool ungerade(int zahl)
{
    return zahl % 2 == 1;
    //Diese Zeile prüft mithilfe des Modulo-Operators, ob der Rest 1 entspricht, dadurch wäre zahl ungerade.
}
 
//d)
int multsignal(int a, int b)
{
    std::cout << "Weitere Multiplikation." << std::endl;
    return a * b;
}

//b)
int quadrat(int zahl)
{
    return multsignal(zahl, zahl);
    //Hier wird der Input für multsignal definiert: Multiplikation einer Zahl mit sich selbst ist gleich Quadrieren.
}

int exponentation(int basis, int exponent)
{
    return cond(
        exponent == 0, 1, //if-Abfrage: wenn Wert gleich 0, dann gib 1 aus
        cond( //"else" nach if-Abfrage
            exponent < 0, 0, //if-Abfrage: wenn Wert kleiner 0, dann gib 0 aus
            cond(ungerade(exponent), multsignal( //else mit erneuter if-Abfrage: wenn ungerade == true, führe multsignal aus mit 
                basis, exponentation(basis, exponent - 1)), //Inputs basis und dem return nach erneutem Ausführen von exponentation mit exponent - 1 (rekursiv (einmalige Ausführung))
            quadrat(exponentation(basis, exponent / 2)) //else: sobald exponent gerade wird, dann exponentation erneut ausführen mit den Inputs basis und exponent / 2 (rekursiv zurückquadrieren bis exponent == 1)
            )
        )
    );  
    //Dadurch wird die Basis erst durch wiederholtes quadrieren rekursiv exponentiert, wenn der Input positiv, ungleich 0 und gerade ist. 
}

//c)
/*  
    8: 8-4-2-1 -> insgesamt 4 Multiplikationen
    11: 11-10-5-4-2-1 -> insgesamt 6 Multiplikationen
    15: 15-14-7-6-3-2-1 -> insgesamt 7 Multiplikationen
*/

int main()
{
    std::cout << exponentation(3, 15);
    return 0;
}