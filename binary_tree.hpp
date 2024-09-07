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
        VOID,

        BOOL,
        CHAR,
        INT,
        FLOAT,
        DOUBLE,

        PTR,
        ARRAY,
        
        STRUCT,
        UNION,
        ENUM,

        FUNCTION
    };

    enum Tokens {
        TYPE = FUNCTION + 1,

        IF,
        WHILE,
        FOR,

        IDENTIFIER,
        NUMBER,
        
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

        STMT,
        STMTS,

        END
    };
}

class node {
public:
    node(int t) : token(t) {};
    const unsigned int token;
};

class tree_node : public node {
public:
    tree_node(int t) : node(t) {};
    tree_node() : node(AST::VOID) {};

    node *left = nullptr;
    node *right = nullptr;
};

class tree : public node {
public:
    tree(int t) : node(t) {};
    tree() : node(AST::VOID) {};

    tree_node *left = nullptr;
    tree_node *right = nullptr;
};
