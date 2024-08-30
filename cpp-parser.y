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
    class Expression_class* factor;
    class Term_class* term;
}

%token <strval> IDENTIFIER NUMBER
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE 
%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS
%type <expr> expr
%type <expr> factor
%type <term> term
%type <expr> program

%%

program:
    expr ';' {
        tree_node *trash = cur_expr->right; // мусорный узел
        cur_expr->right = cur_expr->right->left; // замена на переменную
        delete trash;
    }
    ;



expr:
    lvalue ASSIGN rvalue {
        push_operator(tree_node::ASSIGN);
    }
    | lvalue PLUS rvalue {
        push_operator(tree_node::PLUS);
    }
    | lvalue MINUS rvalue {
        push_operator(tree_node::MINUS);
    }
    | lvalue MULTIPLY rvalue {
        push_operator(tree_node::MULTIPLY);
    }
    | lvalue DIVIDE rvalue {
        push_operator(tree_node::DIVIDE);
    }
    | term {
        $$ = $1;
    }
    ;

lvalue:
    expr
    ;

rvalue:
    term | factor {}
    ;


factor:
    MINUS term {
        push_unary_operator(tree_node::MINUS);
    }
    |
    MINUS factor {
        push_unary_operator(tree_node::MINUS);
    }
    ;

parenthesis_open:
    '(' { // +
        std::cout << "Open '()'" << std::endl;

        // создаётся term и cur_expr продвигается
        cur_expr = cur_expr->right;
        cur_expr->right = new Expression_class;

        stack_perenthesis.push(cur_expr);
        tree_node *new_offset1 = new tree_node;
        tree_node *new_offset2 = new tree_node;
        stack_perenthesis_root.push(new_offset2);        
        new_offset2->right = new_offset1;


        // cur_expr->right->left = new_node; // новая ветка
        cur_expr = new_offset2; 
        cur_var = new_offset1;
        // cur_expr = new_offset; // cur_expr c смещение на один узел. одна переменная уже есть 

        // new_node->right = cur_expr->right->right; // в new_node->right хранится cur_var
        // cur_var = new_node; // cur_var к основанию ветвки
    }
    ;

parenthesis_close:
    ')' { // +
        std::cout << "Close '()'" << std::endl;

        tree_node *trash = cur_expr->right; // мусорный узел
        cur_expr->right = cur_expr->right->left; // замена на переменную
        delete trash;

        cur_expr = stack_perenthesis.top(); // возврат на предыдущую ветку
        stack_perenthesis.pop();
        cur_var = cur_expr; // в node->right хранится cur_var

        cur_expr->right->left = stack_perenthesis_root.top()->right->right; // ***
        delete stack_perenthesis_root.top()->right; // ***
        stack_perenthesis_root.pop();

    }

term:
    NUMBER {
        std::cout << "num: " << yylval.strval << std::endl; // тоже строка
        $$ = new Term_class(yylval.strval);
        push_term($$);
    }
    | IDENTIFIER {
        std::cout << "id: " << yylval.strval << std::endl;
        $$ = new Term_class(yylval.strval);
        push_term($$);
    }
    | parenthesis_open expr parenthesis_close {}
    ;



%%



void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    std::exit(1);
}

int main(void) {
    init();
    std::string str("x = -- 5 + (2 * 3);");
    std::cout << "\033[32m" << str << "\033[0m" << std::endl;
    yy_scan_string(str.c_str());
    yyparse();

    std::ofstream out("tree.txt");
    serialize(tree_root.right, out);
    out.close();


    return 0;
}

