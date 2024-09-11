#include "binary_tree.hpp"

#define NODE(X)         (reinterpret_cast<node*>(X))
#define TREE(X)         (reinterpret_cast<tree*>(X))
#define TREE_NODE(X)    (reinterpret_cast<tree_node*>(X))
#define TERM(X)         (reinterpret_cast<Term_class*>(X))
#define EXPR(X)         (reinterpret_cast<Expression_class*>(X))
#define EXPRS(X)        (reinterpret_cast<list_node*>(X))
#define STMTS(X)        (reinterpret_cast<list_node*>(X))

#define TYPE(X)         (reinterpret_cast<Elementary_type*>(X))
#define FUN(X)          (reinterpret_cast<Function_type*>(X))
#define FUN_CALL(X)     (reinterpret_cast<Function_call*>(X))

#define NODE_IF(X)           (reinterpret_cast<if_class*>(X))
#define NODE_WHILE(X)        (reinterpret_cast<while_class*>(X))
#define NODE_FOR(X)          (reinterpret_cast<for_class*>(X))

#define DEF(X)          (reinterpret_cast<Define_class*>(X))

#define SYM(X)          (reinterpret_cast<Symbol*>(X))
#define SYM_FUN(X)      (reinterpret_cast<Symbol_Fun*>(X))


#define OPERATORS(X)        ((X) >= AST::ASSIGN && (X) <= AST::OR)
#define VARIABLES(X)        ((X) >= AST::BOOL && (X) <= AST::ENUM)
#define CONSTRUCTIONS(X)    ((X) >= AST::IF && (X) <= AST::WHILE)

#define STMT(X) (OPERATORS(X) || CONSTRUCTIONS(X) || X == AST::IDENTIFIER || X == AST::NUMBER)

#define COM "\033[0m"
#define RED "\033[31m"
#define GRN "\033[32m"
#define GLD "\033[33m"
#define BLUE "\033[34m"
#define PRP "\033[35m"
#define LBL "\033[36m"

#define CLEAR "\033[2J\033[H"


typedef class Program_class *Program;
typedef class Expression_class *Expression;
typedef class Statement_class *Statement;

class parameter;
class list_parameter;
class list_node;


// <== Elementary_type ==>
class Elementary_type : public node {
public:
    Elementary_type(const unsigned int t) : node(t) {};
    Elementary_type() : Elementary_type(AST::VOID) {};
};

class Type_info : node {
public:
    Type_info(const std::string &n) : node(AST::TYPE), name(n) {};

    std::string name;
    unsigned int flags[AST::FUNCTION + 1] = {0};
};

// <== Expression_class ==>
class Expression_class : public tree_node {
public:
    Expression_class(const unsigned int t) : tree_node(t) {};
    Expression_class() : tree_node(AST::VOID) {};
};

class Term_class : public node {
public:
    Term_class(const std::string& v, Type_info *s, const unsigned int t) : node(t), type(s), value(v) {  };
    Term_class(const std::string& v, const unsigned int t) : Term_class(v, nullptr, t) {};
    Term_class(const std::string& v) : Term_class(v, AST::IDENTIFIER) {};

    Type_info *type;
    std::string value;
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
    Function_type(list_parameter *p, list_node *c) : Elementary_type(AST::FUNCTION), parameters(p), code(c) {};
    Function_type(list_parameter *p) : Function_type(p, nullptr) {};
    
    list_parameter *parameters;
    list_node *code;
};

class Function_call : public Term_class {
public:
    Function_call(const std::string& v, list_node *a, Type_info *s, const unsigned int t) : Term_class(v, s, t), args(a) {};
    Function_call(const std::string& v, list_node *a, const unsigned int t) : Term_class(v, nullptr, t), args(a) {};
    Function_call(const std::string& v, list_node *a) : Term_class(v, AST::FUNCTION_CALL), args(a) {};

    list_node *args;
};

// <== Constructions ==>
class if_class : public node {
public:
    if_class(Expression_class *c, list_node *True, list_node *False) : node(AST::IF), condition(c), if_true(True), if_false(False) {};
    if_class(Expression_class *c, list_node *True) : node(AST::IF), condition(c), if_true(True), if_false(nullptr) {};

    Expression_class *condition;
    list_node *if_true;
    list_node *if_false;
};

class while_class : public node {
public:
    while_class(Expression_class *c, list_node *s) : node(AST::WHILE), condition(c), stmts(s) {};

    Expression_class *condition;
    list_node *stmts;
};

class for_class : public node {
public:
    for_class(list_node *s, Expression_class* e1, Expression_class* e2, Expression_class* e3) : node(AST::FOR), stmts(s) {
        optexprs[0] = e1;
        optexprs[1] = e2;
        optexprs[2] = e3;
    };

    Expression_class* optexprs[3];
    list_node *stmts;
};

// <== Define ==>
class Define_class : public node {
public:
    Define_class(unsigned int tkn, Type_info *t, node *e) : node(tkn), type(t) { exprs.def = e; };

    Type_info *type;
    union {
        list_node *vars;
        list_node *typedef_list;
        std::pair<std::string, Function_type> *fun;
        node *def;
    } exprs;
};

class tree_ref {
public:
    tree_ref(Expression_class *n, tree_ref *p) : node(n), parent(p) {};
    tree_ref(Expression_class *n) : tree_ref(n, nullptr) {};
    Expression_class *node;
    tree_ref *parent;
} ;

// <== Other ==>

class Symbol : public node {
public:
    Symbol() : node(0), type(nullptr) {}
    Symbol(unsigned int tkn, Elementary_type *t) : node(tkn), type(t) {};
    Elementary_type *type;
};

class Symbol_Fun : public Symbol {
public:
    Symbol_Fun(unsigned int tkn, Elementary_type *t, Function_type *f) : Symbol(tkn, t), fun(f) {};
    Elementary_type *type;
    Function_type *fun;
};

class list_node : public node {
public:
    list_node(unsigned int t) : node(t) {};
    list_node() : list_node(AST::EXPRS) {};
    std::list<node*> nodes;
    std::unordered_map<std::string, Symbol*> symbols;
    list_node *parent;
};

class field : public std::pair<std::string, Type_info*> {
public:
    field (const std::string &name, Type_info *type) : std::pair<std::string, Type_info*>(name, type) {};
};

class parameter : public std::pair<std::string, Elementary_type*> {
public:
    parameter (const std::string &name, Elementary_type *type) : std::pair<std::string, Elementary_type*>(name, type) {};
};
class list_parameter : public std::list<parameter*> {};
