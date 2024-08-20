%option noyywrap
%{
#include "parser.tab.h"
#include <ostream>
#include <stdlib.h>

// Переменные для хранения позиции
int current_line = 1;
int current_column = 1;

#define PLS_CL current_line++; current_column = 1
#define PLS_CC(X) current_column += X
%}

%%

[0-9]+                  { yylval.num = atoi(yytext); PLS_CC(yyleng); return NUMBER; }
[ \t]+                  { PLS_CC(yyleng); /* игнорируем пробелы и табуляции */ }
[\n]                    { PLS_CL; }
"+"                     { PLS_CC(yyleng); return OPERATOR_PLUS; }
"-"                     { PLS_CC(yyleng); return OPERATOR_MINUS; }
"*"                     { PLS_CC(yyleng); return OPERATOR_MULTIPLY; }
"/"                     { PLS_CC(yyleng); return OPERATOR_DIVIDE; }
"%"                     { PLS_CC(yyleng); return OPERATOR_MODULO; }
"&"                     { PLS_CC(yyleng); return OPERATOR_AND; }
"|"                     { PLS_CC(yyleng); return OPERATOR_OR; }
"^"                     { PLS_CC(yyleng); return OPERATOR_XOR; }
"!"                     { PLS_CC(yyleng); return OPERATOR_NOT; }
"~"                     { PLS_CC(yyleng); return OPERATOR_TILDE; }
";"                     { PLS_CC(yyleng); return ';'; }

"="                     { PLS_CC(yyleng); return ASSIGN; }
"+="                    { PLS_CC(yyleng); return ASSIGNMENT_ADDITION; }
"-="                    { PLS_CC(yyleng); return ASSIGNMENT_SUBTRACTION; }
"*="                    { PLS_CC(yyleng); return ASSIGNMENT_MULTIPLICATION; }
"/="                    { PLS_CC(yyleng); return ASSIGNMENT_DIVISION; }
"%="                    { PLS_CC(yyleng); return ASSIGNMENT_REMAINDER; }
"&="                    { PLS_CC(yyleng); return ASSIGNMENT_BITWISE_AND; }
"|="                    { PLS_CC(yyleng); return ASSIGNMENT_BITWISE_OR; }
"^="                    { PLS_CC(yyleng); return ASSIGNMENT_BITWISE_XOR; }
"<<="                   { PLS_CC(yyleng); return ASSIGNMENT_LSHIFT; }
">>="                   { PLS_CC(yyleng); return ASSIGNMENT_RSHIFT; }

[_a-zA-Z][_a-zA-Z0-9]*  { yylval.id = strdup(yytext); current_column += yyleng; return IDENTIFIER; }

.                       { 
    fprintf(stderr, "Unexpected character '%s' at line %d, column %d\n", yytext, current_line, current_column);
    current_column += yyleng;
}

%%

