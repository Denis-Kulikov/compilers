%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *s);
int yylex(void);
%}

%union {
    int num;
}

%token <num> NUMBER
%token PLUS MINUS
%type <num> expression term

%%

expression:
    expression PLUS term      { $$ = $1 + $3; printf("%d\n", $$); }
  | expression MINUS term     { $$ = $1 - $3; printf("%d\n", $$); }
  | term                     { $$ = $1; printf("%d\n", $$); }
  ;

term:
    NUMBER                   { $$ = $1; }
  ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
