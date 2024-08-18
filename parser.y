%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

int result;
%}

%union {
    int num;
}

%token <num> NUMBER
%token OPERATOR_PLUS OPERATOR_MINUS OPERATOR_MULTIPLY OPERATOR_DIVIDE
%token OPERATOR_MODULO OPERATOR_AND OPERATOR_OR OPERATOR_XOR
%token OPERATOR_NOT OPERATOR_TILDE

%type <num> expression term factor

%%

expression:
    expression OPERATOR_PLUS term         { $$ = $1 + $3; result = $$; }
  | expression OPERATOR_MINUS term        { $$ = $1 - $3; result = $$; }
  | expression OPERATOR_AND term          { $$ = $1 & $3; result = $$; }
  | expression OPERATOR_OR term           { $$ = $1 | $3; result = $$; }
  | expression OPERATOR_XOR term          { $$ = $1 ^ $3; result = $$; }
  | term                                  { $$ = $1; }
  ;

term:
    term OPERATOR_MULTIPLY factor         { $$ = $1 * $3; result = $$; }
  | term OPERATOR_DIVIDE factor           { $$ = $1 / $3; result = $$; }
  | term OPERATOR_MODULO factor           { $$ = $1 % $3; result = $$; }
  | factor                                { $$ = $1; }
  ;

factor:
    OPERATOR_NOT factor                   { $$ = !$2; result = $$; }
  | OPERATOR_TILDE factor                 { $$ = ~$2; result = $$; }
  | NUMBER                                { $$ = $1; }
  ;


%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

void run_test(const char* test, const int real)
{
    yy_scan_string(test);
    yyparse();
    std::cout << "Result: " << (result == real ? "\033[32m" : "\033[31m") << result << " | " << real << "\033[0m"<< std::endl;
}

int main(void) {
    run_test("2 + 3 * 2 - 5 % 3", 6);
    run_test("4 + 5", 9);
    run_test("9 - 6", 3);
    run_test("3 * 3", 9);
    run_test("10 / 2", 5);
    run_test("10 % 3", 1);
    run_test("6 & 3", 2);
    run_test("4 | 1", 5);
    run_test("5 ^ 3", 6);
    run_test("!0", 1);
    run_test("~5", -6);

    return 0;
}
