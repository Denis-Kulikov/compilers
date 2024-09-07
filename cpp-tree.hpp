#include "binary_tree.hpp"

#define NODE(X) (reinterpret_cast<node*>(X))
#define TREE(X) (reinterpret_cast<tree*>(X))
#define TERM(X) (reinterpret_cast<Term_class*>(X))
#define EXPR(X) (reinterpret_cast<Expression_class*>(X))
#define STMTS(X) (reinterpret_cast<list_stmt*>(X))

#define TYPE(X) (reinterpret_cast<Elementary_type*>(X))
#define FUN(X) (reinterpret_cast<Function_type*>(X))


typedef class Program_class *Program;
typedef class Expression_class *Expression;
typedef class Statement_class *Statement;

class parameter;
class list_parameter;
class list_stmt;


// <== Elementary_type ==>
class Elementary_type : public node {
public:
    Elementary_type(const unsigned int t) : node(t) {};
    Elementary_type() : Elementary_type(AST::VOID) {};
};


// <== Expression_class ==>
class Expression_class : public tree_node {
public:
    Expression_class(const unsigned int t) : tree_node(t) {};
    Expression_class() : tree_node(AST::VOID) {};
};

class Term_class : public Expression_class {
public:
    Term_class(const std::string& v, const Elementary_type *s, const unsigned int t) : Expression_class(t), type(s), value(v) {  };
    Term_class(const std::string& v, const unsigned int t) : Term_class(v, nullptr, t) {};
    Term_class(const std::string& v) : Term_class(v, AST::IDENTIFIER) {};

    const Elementary_type *type;
    const std::string value;
};


// <== Pointers ==>
class Pointer_type : public Elementary_type {
public:
    Pointer_type(const unsigned int tt, const unsigned int t) : Elementary_type(t), target_type(tt) {};
    Pointer_type(const unsigned int tt) : Elementary_type(AST::PTR), target_type(tt) {};
    const unsigned int target_type;
};

class Array_type : public Pointer_type {
public:
    Array_type(const unsigned int tt, unsigned int l) : Pointer_type(tt, AST::ARRAY), lenght(l) {};
    unsigned int lenght;
};


// <== Structs ==>
class Struct_type : public Elementary_type {
public:
    Struct_type(std::list<std::pair<std::string, Elementary_type*>>& f, const unsigned int t) : Elementary_type(t), fields(f) {};
    Struct_type(std::list<std::pair<std::string, Elementary_type*>>& f) : Struct_type(f, AST::STRUCT) {};
    std::list<std::pair<std::string, Elementary_type*>> fields;
};

class Enum_type : public Elementary_type {
public:
    Enum_type (std::list<Elementary_type*>&& lt) : type(lt), Elementary_type(AST::UNION) {};
    std::list<Elementary_type*> type;
};

class Union_type : public Elementary_type {
public:
    Union_type (std::list<Elementary_type*>&& lt) : type(lt), Elementary_type(AST::UNION) {};
    std::list<Elementary_type*> type;
};


// <== Function ==>
class Function_type : public Elementary_type {
public:
    Function_type(Elementary_type *t, list_parameter *p, list_stmt *c) : Elementary_type(AST::FUNCTION), type(t), parameters(p), code(c) {};
    Function_type(Elementary_type *t, list_parameter *p) : Function_type(t, p, nullptr) {};

    const Elementary_type *type;
    list_parameter *parameters;
    list_stmt *code;
};


// <== Constructions ==>
class if_class : public node {
public:
    if_class(Expression_class *c, list_stmt *True, list_stmt *False) : node(AST::IF), condition(c), if_true(True), if_false(False) {};
    if_class(Expression_class *c, list_stmt *True) : node(AST::IF), condition(c), if_true(True), if_false(nullptr) {};

    Expression_class *condition;
    list_stmt *if_true;
    list_stmt *if_false;
};

class while_class : public node {
public:
    while_class(Expression_class *c, list_stmt *s) : node(AST::WHILE), condition(c), stmts(s) {};

    Expression_class *condition;
    list_stmt *stmts;
};

class for_class : public node {
public:
    for_class(Expression_class *c, list_stmt *s) : node(AST::WHILE), condition(c), stmts(s) {};

    Expression_class *condition;
    std::array<Expression_class*, 3> *optexprs;
    list_stmt *stmts;
};


// class Function_type : public Elementary_type {
// public:
//     const Elementary_type *type;
//     const Elementary_type *result_type;

//     Function_type(Elementary_type *t) : Elementary_type(AST::FUNCTION), result_type(t) {};
// };

// class Function_class : public Elementary_type {
// public:
//     const Elementary_type *type;
//     list_parameter *parametr;
//     Expression_class *code;

//     Function_class(Elementary_type *t, list_parameter *p, Expression_class *c) : Elementary_type(AST::FUNCTION), type(t), parametr(p), code(c) {};
//     Function_class(Elementary_type *t, list_parameter *p) : Function_class(t, p, nullptr) {};
// };



// <== Other ==>
class list_node : public std::list<node*> {};
class list_stmt : public std::list<node*>, node {
public:
    list_stmt() : node(AST::STMTS) {};
    std::unordered_map<std::string, node*> symbols;
    list_stmt *parent;
};

class field : public std::pair<std::string, node*> {
public:
    field (const std::string &name, node *type) : std::pair<std::string, node*>(name, type) {};
};

class parameter : public std::pair<std::string, Elementary_type*> {
public:
    parameter (const std::string &name, Elementary_type *type) : std::pair<std::string, Elementary_type*>(name, type) {};
};
class list_parameter : public std::list<parameter*> {};


// == == ==

// class Class_type : public Elementary_type {
// public:
//     std::list<Struct_type*> list_fields;
//     std::list<Function_type*> methods;
//     Class_type (std::list<Struct_type*>&& lf, std::list<Function_type*>&& m) : list_fields(lf), methods(m), Elementary_type(AST::CLASS) {};
// };
