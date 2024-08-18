%{
#include "parser.tab.h"
#include <ostream>
#include <stdlib.h>
%}

%%

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
[ \t\n]+                { /* игнорировать пробелы и табуляции */ }
"+"                     { return OPERATOR_PLUS; }
"-"                     { return OPERATOR_MINUS; }
"*"                     { return OPERATOR_MULTIPLY; }
"/"                     { return OPERATOR_DIVIDE; }
"%"                     { return OPERATOR_MODULO; }
"&"                     { return OPERATOR_AND; }
"|"                     { return OPERATOR_OR; }
"^"                     { return OPERATOR_XOR; }
"!"                     { return OPERATOR_NOT; }
"~"                     { return OPERATOR_TILDE; }

%%

int yywrap(void) {
    return 1;
}
