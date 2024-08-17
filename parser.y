%{
#include <iostream>
#include <fstream>
#include <FlexLexer.h>

extern int yylex();  
void yyerror(const char* msg);

using namespace std;
%}

/* Определяем объединение типов данных для токенов */
%union {
    int ival;
    double fval;
}

/* Определяем токены и указываем их типы */
%token <ival> INTEGER
%token <fval> FLOAT
%token PLUS MINUS MULTIPLY DIVIDE

/* Устанавливаем приоритеты и ассоциативность для операторов */
%left PLUS MINUS     // Сложение и вычитание имеют одинаковый приоритет и левую ассоциативность
%left MULTIPLY DIVIDE  // Умножение и деление также имеют одинаковый приоритет, выше чем у сложения и вычитания

%type <ival> expression

%%
program:
    | program statement
;

statement:
    expression ';' { std::cout << "Parsed expression: " << $1 << std::endl; }
;

expression:
    INTEGER { $$ = $1; }
    | FLOAT { $$ = (int)$1; }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MULTIPLY expression { $$ = $1 * $3; }
    | expression DIVIDE expression { $$ = $1 / $3; }
;

%%

void yyerror(const char* msg) {
    std::cerr << "Error: " << msg << std::endl;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <filename>" << std::endl;
        return 1;
    }

    std::ifstream inputFile(argv[1]);
    if (!inputFile.is_open()) {
        std::cerr << "Error: Could not open file " << argv[1] << std::endl;
        return 1;
    }

    yyFlexLexer lexer;
    lexer.switch_streams(&inputFile, nullptr);

    yyparse();
    return 0;
}
