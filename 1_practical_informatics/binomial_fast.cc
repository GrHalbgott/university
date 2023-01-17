#include "fcpp.hh"


int prod (int n)
{
    return cond (n==0, 1, n*prod(n-1));
}

int mult_intervall (int a, int b)
{
    return cond(0<a<=b,cond (a==b, a, b*mult_intervall(a, b-1)) , 0);
}

int binomial (int n, int k)
{
    return mult_intervall(k+1, n)/prod(n-k);
    //return cond(n-k==0, mult_intervall(k+1, n), (k+1)*binomial(k+2, n)/(n-k));
}


int main (int argc, char** argv)
{
    return print (binomial(readarg_int (argc, argv, 1), readarg_int(argc, argv, 2)));
}
