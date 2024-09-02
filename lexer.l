%option noyywrap
%{
#include "parser.tab.h"
#include "parser.hpp"

int current_line = 1;
int current_column = 1;

extern Flags flags;

#define PLS_CL current_line++; current_column = 1
#define PLS_CC(X) current_column += X
%}

%%

[ \t\r]+                  { PLS_CC(yyleng); /* игнорируем пробелы и табуляции */ }
"//"[^\n]* {}
"/*"[^"*/"]*"*/"   {}

[0-9]+                  { yylval.strval = strdup(yytext); PLS_CC(yyleng); push_term(new Term_class(yylval.strval)); return NUMBER; }
[\n]                    { PLS_CL; }


"+"                     { PLS_CC(yyleng); return PLUS; }
"-"                     { PLS_CC(yyleng); return MINUS; }
"*"                     { PLS_CC(yyleng); return MULTIPLY; }
"/"                     { PLS_CC(yyleng); return DIVIDE; }

"=="                     { PLS_CC(yyleng); return EQ; }
"!="                     { PLS_CC(yyleng); return NEQ; }
"<"                      { PLS_CC(yyleng); return LT; }
"<="                     { PLS_CC(yyleng); return LE; }
">"                      { PLS_CC(yyleng); return GT; }
">="                     { PLS_CC(yyleng); return GE; }
"&&"                     { PLS_CC(yyleng); return AND; }
"||"                     { PLS_CC(yyleng); return OR; }
"++"                     { PLS_CC(yyleng); return INC; }
"--"                     { PLS_CC(yyleng); return DEC; }
"<<"                     { PLS_CC(yyleng); return SHL; }
">>"                     { PLS_CC(yyleng); return SHR; }
"&"                      { PLS_CC(yyleng); return BIT_AND; }
"|"                      { PLS_CC(yyleng); return BIT_OR; }
"^"                      { PLS_CC(yyleng); return BIT_XOR; }
"~"                      { PLS_CC(yyleng); return BIT_NOT; }

"="                      { PLS_CC(yyleng); return ASSIGN; } //
"\+="                    { PLS_CC(yyleng); return PLUSEQ; }
"-="                     { PLS_CC(yyleng); return MINUSEQ; }
"\*="                    { PLS_CC(yyleng); return MULTEQ; }
"/="                     { PLS_CC(yyleng); return DIVEQ; }
"%="                     { PLS_CC(yyleng); return MODEQ; }
"&="                     { PLS_CC(yyleng); return ANDEQ; }
"\|="                    { PLS_CC(yyleng); return OREQ; }
"\^="                    { PLS_CC(yyleng); return XOREQ; }
"<<="                    { PLS_CC(yyleng); return SHLEQ; }
">>="                    { PLS_CC(yyleng); return SHREQ; }



"("                     { PLS_CC(yyleng); parenthesis_open(); return '('; }
")"                     { PLS_CC(yyleng); parenthesis_close(); return ')'; }

"{"                     { PLS_CC(yyleng); return '{'; }
"}"                     { PLS_CC(yyleng); return '}'; }

","                     { PLS_CC(yyleng); return ','; }
";"                     { PLS_CC(yyleng); return ';'; }

"\?"                     { PLS_CC(yyleng); return '\?'; }
":"                      { PLS_CC(yyleng); return ':'; }



"if"                    { PLS_CC(yyleng); return IF; }
"for"                   { PLS_CC(yyleng); return FOR; }
"while"                 { PLS_CC(yyleng); return WHILE; }
"do"                    { PLS_CC(yyleng); return DO; }
"switch"                { PLS_CC(yyleng); return SWITCH; }

"else"                  { PLS_CC(yyleng); return ELSE; }
"break"                 { PLS_CC(yyleng); return BREAK; }
"continue"              { PLS_CC(yyleng); return CONTINUE; }
"goto"                  { PLS_CC(yyleng); return GOTO; }
"return"                { PLS_CC(yyleng); return RETURN; }

"case"                  { PLS_CC(yyleng); return CASE; }
"default"               { PLS_CC(yyleng); return DEFAULT; }

"const"                 { PLS_CC(yyleng); flags.const_ =    true; return CONST; }
"unsigned"              { PLS_CC(yyleng); flags.unsigned_ = true; return UNSIGNED; }
"long"                  { PLS_CC(yyleng); flags.long_ =     true; return LONG; }
"short"                 { PLS_CC(yyleng); flags.short_ =    true; return SHORT; }
"static"                { PLS_CC(yyleng); flags.static_ =   true; return STATIC; }
"inline"                { PLS_CC(yyleng); flags.inline_ =   true; return INLINE; }
"extern"                { PLS_CC(yyleng); flags.inline_ =   true; return EXTERN; }

"struct"                { PLS_CC(yyleng); return STRUCT; }
"union"                 { PLS_CC(yyleng); return UNION; }
"enum"                  { PLS_CC(yyleng); return ENUM; }

"typedef"               { PLS_CC(yyleng); return TYPEDEF; }



[_a-zA-Z][_a-zA-Z0-9]*  { yylval.strval = strdup(yytext); PLS_CC(yyleng);
                          if (!find_type(yylval.strval)) { push_term(new Term_class(yylval.strval)); }
                          return IDENTIFIER;
                        }

.                       { 
    std::cerr << "Unexpected character '" << yytext << "' at line " << current_line << ", column " << current_column << std::endl;
    PLS_CC(yyleng);
}

%%

