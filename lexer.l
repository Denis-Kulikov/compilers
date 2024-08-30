%option noyywrap
%{
#include "parser.tab.h"
#include <iostream>
#include <stdlib.h>

// Переменные для хранения позиции
int current_line = 1;
int current_column = 1;

#define PLS_CL current_line++; current_column = 1
#define PLS_CC(X) current_column += X
%}

%%

[0-9]+                  { yylval.strval = strdup(yytext); PLS_CC(yyleng); return NUMBER; }
[ \t]+                  { PLS_CC(yyleng); /* игнорируем пробелы и табуляции */ }
[\n]                    { PLS_CL; }
"+"                     { PLS_CC(yyleng); return PLUS; }
"-"                     { PLS_CC(yyleng); return MINUS; }
"*"                     { PLS_CC(yyleng); return MULTIPLY; }
"/"                     { PLS_CC(yyleng); return DIVIDE; }
"="                     { PLS_CC(yyleng); return ASSIGN; }

"("                     { PLS_CC(yyleng); return '('; }
")"                     { PLS_CC(yyleng); return ')'; }

";"                     { PLS_CC(yyleng); return ';'; }

[_a-zA-Z][_a-zA-Z0-9]*  { yylval.strval = strdup(yytext); PLS_CC(yyleng); return IDENTIFIER; }

.                       { 
    std::cerr << "Unexpected character '" << yytext << "' at line " << current_line << ", column " << current_column << std::endl;
    PLS_CC(yyleng);
}

%%

