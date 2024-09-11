int x = 5;

float calc(int a) {
    float z = a * 2;
    return z;
}

int main() {
    int x = 10;
    {
        int x = 20;
        float result = calc(x);
        if (result == 40) {
            x = x + 5;
        }
    }
    if (x == 10) {
        float a = 5, b = 3, c = 2;
        float result = a * b + c;
        if (result == 11) {
            for (int i = 0; i < 5; ++i) {
                int temp = i * 2;
                if (temp == i * 2) {
                    return 0;
                }
            }
        }
    }
    return 1;
}
