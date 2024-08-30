#include <iostream>

class tree_node {
public:
    tree_node(int t) : token(t) {}
    tree_node() {}

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
        CLASS,
        FUNCTION

        // ENUM
        // UNION
    };

    enum Tokens {
        ASSIGN = FUNCTION + 1,

        PLUS,
        MINUS,

        MULTIPLY,
        DIVIDE,

        NUMBER,
        IDENTIFIER,

        END
    };

    int token = VOID;

    tree_node *left = nullptr;
    tree_node *right = nullptr;
};
