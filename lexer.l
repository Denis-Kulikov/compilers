%{
#include "parser.tab.h"
#include <stdlib.h>
%}

%%

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
[ \t\n]+                { /* игнорировать пробелы и табуляции */ }
"+"                     { return PLUS; }
"-"                     { return MINUS; }

%%

int yywrap(void) {
    return 1;
}
