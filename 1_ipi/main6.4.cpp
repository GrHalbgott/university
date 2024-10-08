#include <iostream>
#include <string.h> // F�r strlen, L�nge eines C-Strings


// Stack und mitlaufender Index der obersten Zahl
int stack[20];
int top = 0;
bool block_of_digits = false;

// Zahl auf den Stack legen
void push(int i) {
    stack[top] = i;
    top += 1;
}

// Oberste Zahl vom Stack nehmen
int pop() {
    top -= 1;
    return stack[top];
}


int main(int argc, char* argv[])
{
     //Anzahl Zeichen in der Eingabe bestimmen und in char-Array kopieren
    int input_length = strlen(argv[1]);
    const int max_length = 100;

    if (input_length > max_length) { printf("Eingabe zu lang!\n"); return 0; }
     //weiter Fehlerbehandlungen sind nicht verlangt

    char input[max_length];

    for (int i = 0; i < input_length; i++) {
        input[i] = argv[1][i];
    }

    // Zuletzt im Aufbau befindliche Zahl
    int running_number = 0;

    // Schleife, die die Zeichen aus der Eingabe der Reihe nach abarbeitet
    for (int i = 0; i < input_length; i++)
    {
        // Aktuelle gelesenes Zeichen
        char current = input[i];

        // Falls das ASCII-Zeichen eine Ziffer ist: Zahl weiter aufbauen
        if ((current >= 48) && (current <= 57)) {
            block_of_digits = true;
            running_number = 10 * running_number + (current - 48);
        }
        else if (current == '+') {
            push(pop() + pop());
        }
        else if (current == '-') {
            int first = pop();
            int second = pop();
            push(second - first);
        }
        else if (current == '*') {
            push(pop() * pop());
        }
        else if (current == '/') {
            int first = pop();
            int second = pop();
            push(second / first);
        }

        // Am Ende eines Ziffernblocks wird die
        // zugeh�rige Zahl auf den Stack gelegt
        if (block_of_digits && (current == ' ' || i == input_length - 1))
        {
            push(running_number);
            running_number = 0;
            block_of_digits = false;
        }
    }
    std::cout << pop() << std::endl;
}
