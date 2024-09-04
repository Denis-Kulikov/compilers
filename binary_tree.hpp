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
    class Elementary_type;

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

        END
    };
}


class tree_node {
public:
    tree_node(int t) : token(t) {}
    tree_node() {}

    int token = AST::VOID;

    tree_node *left = nullptr;
    tree_node *right = nullptr;
};
