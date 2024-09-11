#include <cstring>
#include <fstream>
#include <iostream>
#include <list>
#include <memory>
#include <string>
#include <sstream>
#include <stack>
#include <utility>
#include <unordered_map>

namespace AST
{
    enum Basic_types {
        BOOL,
        CHAR,
        INT,
        FLOAT,
        DOUBLE,

        VOID,
        PTR,
        ARRAY,
        
        STRUCT,
        UNION,
        ENUM,

        FUNCTION
    };

    enum Tokens {
        TYPE = FUNCTION + 1,
        DEFINITION_VAR,
        DEFINITION_TYPEDEF,
        DEFINITION_FUN,

        IF,
        WHILE,
        FOR,

        IDENTIFIER,
        NUMBER,
        
        FUNCTION_CALL,

        ASSIGN,
        PLUS,
        MINUS,
        MULTIPLY,
        DIVIDE,

        PRE_INC,
        PRE_DEC,

        INC_POST,
        DEC_POST,

        BIT_AND,
        BIT_OR,
        BIT_XOR,
        
        SHL,
        SHR,
        EQ,
        NEQ,
        LT,
        LE,
        GT,
        GE,
        
        AND,
        OR,

        EXPRS,
        STMT,
        STMTS,

        END
    };
}

class node {
public:
    node() : token(AST::VOID) {};
    node(unsigned int t) : token(t) {};
    unsigned int get_token() const { return token; }
    unsigned int token;
};

class tree_node : public node {
public:
    tree_node(unsigned int t) : node(t) {};
    tree_node() : node(AST::VOID) {};

    node *left = nullptr;
    node *right = nullptr;
};

class tree : public node {
public:
    tree(unsigned int t) : node(t) {};
    tree() : node(AST::VOID) {};

    tree *left = nullptr;
    tree *right = nullptr;
};
