#include <cstring>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <sstream>
#include <stack>
#include <unordered_map>
#include "cpp-tree.hpp"

typedef struct {
    Elementary_type Bool    = AST::BOOL;
    Elementary_type Char    = AST::CHAR;
    Elementary_type Int     = AST::INT;
    Elementary_type Float   = AST::FLOAT;
    Elementary_type Double  = AST::DOUBLE;
    Elementary_type Void    = AST::VOID;

    // Примеры более сложных типов
    // AST::Pointer_type IntPointer = {&Int};
    // AST::Array_type IntArray = {&Int, 10};
    // AST::Function_type IntToInt = {&Int, {&Int}};
} Elementary_types;

typedef struct Tables__ {
    std::unordered_map<std::string, Term_class*> symbols;
    std::unordered_map<std::string, Term_class*> types;

    Tables__ (const Elementary_types &elementary_types) {
        types["void"] = new Term_class("void", &elementary_types.Int, AST::VOID);
        types["bool"] = new Term_class("bool", &elementary_types.Int, AST::BOOL);
        types["char"] = new Term_class("char", &elementary_types.Int, AST::CHAR);
        types["int"] = new Term_class("int", &elementary_types.Int, AST::INT);
        types["float"] = new Term_class("float", &elementary_types.Int, AST::FLOAT);
        types["double"] = new Term_class("double", &elementary_types.Int, AST::DOUBLE);
    };
} Tables;

typedef struct {
    std::stack<Term_class*> types;
    std::stack<int> reason; // причина открытия скобок
} Stacks;

typedef struct {
    bool const_     = false;
    bool unsigned_  = false;
    bool long_      = false;
    bool short_     = false;
    bool static_    = false;
    bool inline_    = false;
} Flags;

void init();

void serialize(tree_node* node, std::ofstream& out);

bool find_type(char *name);
void end_expr();
void push_type(const std::string &s);

void parenthesis_close();
void parenthesis_open();


void push_unary_operator(const int op);
void push_operator(const int op);
void push_term(Term_class *e);


// void lift(); // когда записал Term_class
// void lift_perenthesis(); // когда встретился ')'

std::string print_token(int token);


void analysis(const std::string& filename);
