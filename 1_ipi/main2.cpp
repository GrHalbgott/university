#include <iostream>
#include "fcpp.hh"

// a)
int teiler(int teiler, int zahl)
{
  return (zahl % teiler) == 0; //Modulo-Operator: gib true zurück, wenn zahl durch teiler ohne Rest teilbar ist (echter Teiler)
}

// b)
int teileranzahl(int index, int anzahl, int zahl) //gleicher Aufbau wie teilersumme, allerdings wird anzahl parallel zum index inkrementiert, au0er es ist kein echter Teiler in teiler (teiler == False))  
{
  return cond(index == zahl, anzahl, 
    cond(teiler(index, zahl), teileranzahl(index + 1, anzahl + 1, zahl), 
      teileranzahl(index + 1, anzahl, zahl)
    )
  );
}

// c)
int teilersumme(int index, int summe, int zahl) //bekommt Werte von vollkommen (1, 0, zahl)
{
  return cond(index == zahl, summe, //wenn index == zahl, gib summe aus (in vollkommen wird dann ebenfalls true ausgegeben). Falls nicht, weitere if-Abfrage:
    cond(teiler(index, zahl), teilersumme(index + 1, summe + index, zahl), //überprüfe teiler, wenn true rechne nochmal teilersumme mit index+1 und summe+index (rekursiv)
      teilersumme(index + 1, summe, zahl) //wenn teiler nicht echt (mit Rest), dann rechne nochmal teilersummme nur mit index+1 und summe & zahl gleich
    )
  );
}

// (d)
bool vollkommen(int zahl)
{
  return teilersumme(1, 0, zahl) == zahl; //Abfrage, ob summe aus teilersumme == zahl ist
}

// (e)
int suchevollkommen(int zahl)
{
  return cond(vollkommen(zahl), zahl, suchevollkommen(zahl + 1)); //wenn zahl in teilersumme == summe, dann gib zahl aus, ansonsten gib zahl + 1 rein (nächste vollkommene Zahl)
}

//Es wird rekursiv überprüft, ob index (index++) ein Teiler von Zahl ist, bis index so groß ist wie zahl. Summe wird mit Index verrechnet, wenn ein echter Teiler vorliegt. Wenn index == zahl erreicht wird, wird überprüft, ob summe == zahl, dann handelt es sich um eine vollkommene Zahl. Wenn nicht, wird das Programm mit der nächsten ganzen Zahl ausgeführt.

// f)
int main()
{
  std::cout << "Zu überprüfende Startzahl ist 28.\nGib 28 aus wenn sie vollkommen ist:  " << suchevollkommen(28) << std::endl;
  std::cout << "Die nächsten beiden vollkommenen Zahlen nach 28 sind: " << suchevollkommen(28 + 1) << " & " << suchevollkommen(suchevollkommen(zahl + 1) + 1) << std::endl; 
  return EXIT_SUCCESS; //https://stackoverflow.com/questions/8867871/should-i-return-exit-success-or-0-from-main
}
