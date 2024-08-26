%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>
#include <stack>

// Необходимо включить заголовочные файлы для Expression_class и Term_class
#include "parser.cpp"

void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

int result;

%}

%union {
    int intval;
    char* strval;
    class Expression_class* expr;
    class Term_class* term;
}

%token <strval> IDENTIFIER NUMBER
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE 
%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS
%type <expr> expr
%type <term> term
%type <expr> program

%%

program:
    expr ';' {
        push_operator(tree_node::END);
    }
    ;



expr:
    expr ASSIGN term {
        push_operator(tree_node::ASSIGN);
    }
    | expr PLUS term {
        push_operator(tree_node::PLUS);
    }
    | expr MINUS term {
        push_operator(tree_node::MINUS);
    }
    | expr MULTIPLY term {
        push_operator(tree_node::MULTIPLY);
    }
    | expr DIVIDE term {
        push_operator(tree_node::DIVIDE);
    }
    | term {
        $$ = $1;
    }
    ;

term:
    NUMBER {
        std::cout << "num: " << yylval.strval << std::endl; // тоже строка
        $$ = new Term_class(std::string("2"));
        push_term($$);
    }
    | IDENTIFIER {
        std::cout << "id: " << yylval.strval << std::endl;
        $$ = new Term_class(yylval.strval);
        push_term($$);
        free($1);
    }
    ;



%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    std::exit(1);
}

int main(void) {
    std::string str("x = 5 + 2 * 3;");
    std::cout << "\033[32m" << str << "\033[0m" << std::endl;
    yy_scan_string(str.c_str());
    yyparse();

    return 0;
}

