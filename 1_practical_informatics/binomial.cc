#include "fcpp.hh"

int bin (int n, int k)
{
    return cond(n==k, 1, cond(k==0, 1, bin(n-1, k-1) + bin(n-1, k)));
}

int main (int argc, char** argv)
{
    return print (bin (readarg_int(argc, argv, 1), readarg_int(argc, argv, 2)));
}
