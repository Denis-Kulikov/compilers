#include <iostream>
#include <fstream>
#include <FlexLexer.h>

using namespace std;

int main(int argc, char** argv) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <filename>" << endl;
        return 1;
    }

    ifstream inputFile(argv[1]);
    if (!inputFile.is_open()) {
        cerr << "Error: Could not open file " << argv[1] << endl;
        return 1;
    }

    yyFlexLexer lexer;
    lexer.switch_streams(&inputFile, nullptr);

    while (lexer.yylex() != 0) {}

    return 0;
}
