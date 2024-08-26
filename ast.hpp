#include <iostream>
#include "list.h"

extern int node_lineno;
const char *pad(int n);

class Term_class;
class Expression_class;


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


    tree_node *left = nullptr;
    tree_node *right = nullptr;

    void set_token(const int t) { token = t; }
    int get_token() const       { return token; }


protected:
    int token;
};

class ast_node {
protected:
    int line_number;
public:
    ast_node() {};

    List<Expression_class*> stmt;

    // virtual ast_node *copy() = 0;
    // virtual ~ast_node() { }
    // virtual void dump(std::ostream &stream, int n) = 0;
};

