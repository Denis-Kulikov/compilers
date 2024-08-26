#include "ast.hpp"

typedef class Program_class *Program;
typedef class Expression_class *Expression;
typedef class Statement_class *Statement;





class Elementary_type {
public:

    int type;
    Elementary_type(int t) : type(t) {};
    Elementary_type() {};
};

class Pointer_type : public Elementary_type {
public:
    int target_type;
    Pointer_type(int tt, int t) : Elementary_type(t), target_type(tt) {};
    Pointer_type(int tt) : Elementary_type(tree_node::PTR), target_type(tt) {};
};

class Array_type : public Pointer_type {
public:
    int lenght;
    Array_type(int t, int l) : Pointer_type(t, tree_node::ARRAY), lenght(l) {};
};

class Struct_type : public Elementary_type {
public:
    List<Elementary_type*> fields;
    Struct_type(List<Elementary_type*>& f) : Elementary_type(tree_node::STRUCT), fields(f.hd(), f.tl()) {};
};

class Function_type : public Elementary_type {
public:
    int result;
    List<Elementary_type*> args;
    // как-то нужно хранить код функици. список Program_class?
    Function_type(int r, List<Elementary_type*>& a) : Elementary_type(tree_node::FUNCTION), result(r), args(a.hd(), a.tl()) {};
};

class Class_type : public Elementary_type {
public:
    List<Struct_type*> list_fields;
    List<Function_type*> methods;
    Class_type (List<Struct_type*>& lf, List<Function_type*>& m) : list_fields(lf), methods(m), Elementary_type(tree_node::CLASS) {};
};


class Expression_class : public tree_node {
public:
    Expression_class(int t) : tree_node(t) {};
    Expression_class() : tree_node(VOID) {};
};

class Term_class : public Expression_class {
public:
    Elementary_type *structure;
    std::string value;

    Term_class(const std::string& v) : Expression_class(IDENTIFIER), value(v) {};
};

//  virtual void dump() = 0;
// std::unordered_map<std::string, std::unordered_map<Type, Expression *>> operations;
