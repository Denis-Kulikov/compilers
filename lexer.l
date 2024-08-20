%{
#include "parser.tab.h"
#include <ostream>
#include <stdlib.h>

// Переменные для хранения позиции
int current_line = 1;
int current_column = 1;
%}

%%

[0-9]+                  { yylval.num = atoi(yytext); current_column += yyleng; return NUMBER; }
[ \t]+                  { current_column += yyleng; /* игнорируем пробелы и табуляции */ }
[\n]                    { current_line++; current_column = 1; }
"="                     { current_column += yyleng; return ASSIGN; }
"+"                     { current_column += yyleng; return OPERATOR_PLUS; }
"-"                     { current_column += yyleng; return OPERATOR_MINUS; }
"*"                     { current_column += yyleng; return OPERATOR_MULTIPLY; }
"/"                     { current_column += yyleng; return OPERATOR_DIVIDE; }
"%"                     { current_column += yyleng; return OPERATOR_MODULO; }
"&"                     { current_column += yyleng; return OPERATOR_AND; }
"|"                     { current_column += yyleng; return OPERATOR_OR; }
"^"                     { current_column += yyleng; return OPERATOR_XOR; }
"!"                     { current_column += yyleng; return OPERATOR_NOT; }
"~"                     { current_column += yyleng; return OPERATOR_TILDE; }
";"                     { current_column += yyleng; return ';'; }

[_a-zA-Z][_a-zA-Z0-9]*  { yylval.id = strdup(yytext); current_column += yyleng; return IDENTIFIER; }

.                       { 
    fprintf(stderr, "Unexpected character '%s' at line %d, column %d\n", yytext, current_line, current_column);
    current_column += yyleng;
}

%%

int yywrap(void) {
    return 1;
}
