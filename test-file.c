enum {
    WORD,
    WORLD
};

union ascii {
    int digit;
    char letter;
};

struct strct {
    int a;
};

int foo(int x);
int fo(int x, int y) {
    // int z = x ? -1 : 1;
    int z = x;

    if (y > 0) {
        z = y;
    } else {
        z = y;
    }

    if (y > 0) z = y; else z = y;

    switch (x)
    {
    case 1:
        return fo(y, z);
    
    default:
        break;
    }

    while (x = y + z) {
        z = y + x;
        x = y + z;
    }

    // for (int t = 0; t < 10; t++) {
    //     z = y + x;
    //     x = y + z;
    // }

    return 0;
}

int main () {
    int x = -- 5 * 9 - y + 3, z = 32, a;
}