#include <iostream>

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

        FUNCTION,

        STRUCT,
        CLASS,

        ENUM,
        UNION
    };

    enum Tokens {
        TYPE = UNION + 1,

        IDENTIFIER,
        NUMBER,
        
        ASSIGN,
        PLUS,
        MINUS,
        MULTIPLY,
        DIVIDE,

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
