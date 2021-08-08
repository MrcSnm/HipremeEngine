module util.data_structures;

struct Pair(A, B)
{
    A first;
    B second;

    alias a = first;
    alias b = second;
}