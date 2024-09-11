%option noyywrap
%{
#include "parser.tab.h"
#include "parser.hpp"

int current_line = 1;
int current_column = 1;

#define PLUS_L current_line++; current_column = 1
#define PLUS_C(X) current_column += X
%}

%%

[ \t\r]+                  { PLUS_C(yyleng); /* игнорируем пробелы и табуляции */ }
"//"[^\n]* {}
"/*"[^"*/"]*"*/"   {}
[\n]                    { PLUS_L; }


"+"                     { PLUS_C(yyleng); return PLUS; }
"-"                     { PLUS_C(yyleng); return MINUS; }
"*"                     { PLUS_C(yyleng); return MULTIPLY; }
"/"                     { PLUS_C(yyleng); return DIVIDE; }

"=="                     { PLUS_C(yyleng); return EQ; }
"!="                     { PLUS_C(yyleng); return NEQ; }
"<"                      { PLUS_C(yyleng); return LT; }
"<="                     { PLUS_C(yyleng); return LE; }
">"                      { PLUS_C(yyleng); return GT; }
">="                     { PLUS_C(yyleng); return GE; }
"&&"                     { PLUS_C(yyleng); return AND; }
"||"                     { PLUS_C(yyleng); return OR; }
"++"                     { PLUS_C(yyleng); return INC; }
"--"                     { PLUS_C(yyleng); return DEC; }
"<<"                     { PLUS_C(yyleng); return SHL; }
">>"                     { PLUS_C(yyleng); return SHR; }
"&"                      { PLUS_C(yyleng); return BIT_AND; }
"|"                      { PLUS_C(yyleng); return BIT_OR; }
"^"                      { PLUS_C(yyleng); return BIT_XOR; }
"~"                      { PLUS_C(yyleng); return BIT_NOT; }

"="                      { PLUS_C(yyleng); return ASSIGN; } //
"\+="                    { PLUS_C(yyleng); return PLUSEQ; }
"-="                     { PLUS_C(yyleng); return MINUSEQ; }
"\*="                    { PLUS_C(yyleng); return MULTEQ; }
"/="                     { PLUS_C(yyleng); return DIVEQ; }
"%="                     { PLUS_C(yyleng); return MODEQ; }
"&="                     { PLUS_C(yyleng); return ANDEQ; }
"\|="                    { PLUS_C(yyleng); return OREQ; }
"\^="                    { PLUS_C(yyleng); return XOREQ; }
"<<="                    { PLUS_C(yyleng); return SHLEQ; }
">>="                    { PLUS_C(yyleng); return SHREQ; }



"("                     { PLUS_C(yyleng); return '('; }
")"                     { PLUS_C(yyleng); return ')'; }

"{"                     { PLUS_C(yyleng); return '{'; }
"}"                     { PLUS_C(yyleng); return '}'; }

","                     { PLUS_C(yyleng); return ','; }
";"                     { PLUS_C(yyleng); return ';'; }

"\?"                     { PLUS_C(yyleng); return '\?'; }
":"                      { PLUS_C(yyleng); return ':'; }



"if"                    { PLUS_C(yyleng); return IF; }
"for"                   { PLUS_C(yyleng); return FOR; }
"while"                 { PLUS_C(yyleng); return WHILE; }
"do"                    { PLUS_C(yyleng); return DO; }
"switch"                { PLUS_C(yyleng); return SWITCH; }

"else"                  { PLUS_C(yyleng); return ELSE; }
"break"                 { PLUS_C(yyleng); return BREAK; }
"continue"              { PLUS_C(yyleng); return CONTINUE; }
"goto"                  { PLUS_C(yyleng); return GOTO; }
"return"                { PLUS_C(yyleng); return RETURN; }

"case"                  { PLUS_C(yyleng); return CASE; }
"default"               { PLUS_C(yyleng); return DEFAULT; }

"const"                 { PLUS_C(yyleng); return CONST; }
"unsigned"              { PLUS_C(yyleng); return UNSIGNED; }
"long"                  { PLUS_C(yyleng); return LONG; }
"short"                 { PLUS_C(yyleng); return SHORT; }
"static"                { PLUS_C(yyleng); return STATIC; }
"inline"                { PLUS_C(yyleng); return INLINE; }
"extern"                { PLUS_C(yyleng); return EXTERN; }

"struct"                { PLUS_C(yyleng); return STRUCT; }
"union"                 { PLUS_C(yyleng); return UNION; }
"enum"                  { PLUS_C(yyleng); return ENUM; }

"typedef"               { PLUS_C(yyleng); return TYPEDEF; }


[0-9]+                  { yylval.strval = strdup(yytext); PLUS_C(yyleng); return NUMBER; }
[_a-zA-Z][_a-zA-Z0-9]*  { yylval.strval = strdup(yytext); PLUS_C(yyleng); return IDENTIFIER; }

.                       { 
    std::cerr << "Unexpected character '" << yytext << "' at line " << current_line << ", column " << current_column << std::endl;
    PLUS_C(yyleng);
}

%%

