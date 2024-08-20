%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>

void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

std::map<std::string, int> symbol_table;
int result;
%}

%union {
    int num;
    char* id;
}

%token <id> IDENTIFIER
%token <num> NUMBER
%token OPERATOR_PLUS OPERATOR_MINUS OPERATOR_MULTIPLY OPERATOR_DIVIDE
%token OPERATOR_MODULO OPERATOR_AND OPERATOR_OR OPERATOR_XOR
%token OPERATOR_NOT OPERATOR_TILDE

%token ASSIGN ASSIGNMENT_ADDITION ASSIGNMENT_SUBTRACTION ASSIGNMENT_MULTIPLICATION ASSIGNMENT_DIVISION ASSIGNMENT_REMAINDER ASSIGNMENT_BITWISE_AND ASSIGNMENT_BITWISE_OR ASSIGNMENT_BITWISE_XOR ASSIGNMENT_LSHIFT ASSIGNMENT_RSHIFT

%type <num> statement expression term factor

%%

program:
    program statement ';'   { /* пустое тело */ }
    |
    ;

statement:
    IDENTIFIER ASSIGN expression {
        symbol_table[$1] = $3;
        std::cout << "Variable " << $1 << " assigned value: " << $3 << std::endl;
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_ADDITION expression {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] += $3;
            std::cout << "Variable " << $1 << " incremented by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_SUBTRACTION expression {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] -= $3;
            std::cout << "Variable " << $1 << " decremented by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_MULTIPLICATION expression {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] *= $3;
            std::cout << "Variable " << $1 << " multiplied by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_DIVISION expression {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] /= $3;
            std::cout << "Variable " << $1 << " divided by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    expression {
        result = $1;
    }
    ;

expression:
    expression OPERATOR_PLUS term         { $$ = $1 + $3; }
  | expression OPERATOR_MINUS term        { $$ = $1 - $3; }
  | expression OPERATOR_AND term          { $$ = $1 & $3; }
  | expression OPERATOR_OR term           { $$ = $1 | $3; }
  | expression OPERATOR_XOR term          { $$ = $1 ^ $3; }
  | term                                  { $$ = $1; }
  ;

term:
    term OPERATOR_MULTIPLY factor         { $$ = $1 * $3; }
  | term OPERATOR_DIVIDE factor           { $$ = $1 / $3; }
  | term OPERATOR_MODULO factor           { $$ = $1 % $3; }
  | factor                                { $$ = $1; }
  ;

factor:
    OPERATOR_NOT factor                   { $$ = !$2; }
  | OPERATOR_TILDE factor                 { $$ = ~$2; }
  | NUMBER                                { $$ = $1; }
  | IDENTIFIER                            {
        if (symbol_table.find($1) != symbol_table.end()) {
            $$ = symbol_table[$1];
        } else {
            yyerror("Undeclared variable");
            $$ = 0;
        }
        free($1);
    }
  ;

%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
}

void run_test(const char* test, const int real)
{
    yy_scan_string(test);
    yyparse();
    std::cout << "Result: " << (result == real ? "\033[32m" : "\033[31m") << result << " | " << real << "\033[0m" << std::endl;
}

int main(void) {
    run_test("2 + 3 * 2 - 5 % 3;", 6);
    run_test("4 + 5;", 9);
    run_test("9 - 6;", 3);
    run_test("3 * 3;", 9);
    run_test("10 / 2;", 5);
    run_test("10 % 3;", 1);
    run_test("6 & 3;", 2);
    run_test("4 | 1;", 5);
    run_test("5 ^ 3;", 6);
    run_test("!0;", 1);
    run_test("~5;", -6);

    // Пример теста с переменной
    yy_scan_string("x = 5 + 2 * 3; y = x - 4; x += 3;");
    yyparse();

    std::cout << "Final value of x: " << symbol_table["x"] << std::endl;
    std::cout << "Final value of y: " << symbol_table["y"] << std::endl;

    return 0;
}
