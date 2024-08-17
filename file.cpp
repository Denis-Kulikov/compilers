int main() {
    int d = 42;
    int o = 052;
    int x = 0x2a;
    int X = 0X2A;
    int b = 0b101010;

    unsigned long long l1 = 18446744073709550592ull;
    unsigned long long l2 = 18'446'744'073'709'550'592llu;
    unsigned long long l3 = 1844'6744'0737'0955'0592uLL;
    unsigned long long l4 = 184467'440737'0'95505'92LLU;

    float f1 = 3.14f;
    double d1 = 3.14;
    long double ld1 = 3.14L;

    char c = 'a';
    char newline = '\n';
    const char* str = "Hello, World!";

    bool flag = true;
    float pi = 3.1415;
    int counter = 0;
    enum Color { RED, GREEN, BLUE };
    switch (counter) {
        case 0:
            flag = false;
            break;
        default:
            flag = true;
    }

    int sum = d + x;
    int difference = d - x;
    int product = d * x;
    int quotient = d / x;
    int remainder = d % x;
    d += 10;
    d -= 5;
    bool comparison = (d == x);
    bool inequality = (d != x);

    // This is a single-line comment.
    /* This is a multi-line comment.
       It spans multiple lines. */
    
    // Preprocessor directive (for completeness)
    #define MAX 100

    return 0;
}
