#include "binary_tree.hpp"

typedef class Program_class *Program;
typedef class Expression_class *Expression;
typedef class Statement_class *Statement;


class Elementary_type {
public:
    const int type;
    Elementary_type(const int t) : type(t) {};
    Elementary_type() : Elementary_type(AST::VOID) {};
};

class Pointer_type : public Elementary_type {
public:
    const int target_type;
    Pointer_type(const int tt, const int t) : Elementary_type(t), target_type(tt) {};
    Pointer_type(const int tt) : Elementary_type(AST::PTR), target_type(tt) {};
};

class Array_type : public Pointer_type {
public:
    int lenght;
    Array_type(const int tt, int l) : Pointer_type(tt, AST::ARRAY), lenght(l) {};
};

class Function_type : public Elementary_type {
public:
    int result;
    std::list<Elementary_type*> args;
    // как-то нужно хранить код функици. список Program_class?
    Function_type(int r, std::list<Elementary_type*>& a) : Elementary_type(AST::FUNCTION), result(r), args(a) {};
};

class Struct_type : public Elementary_type {
public:
    std::list<std::pair<std::string, Elementary_type*>> fields;
    Struct_type(std::list<std::pair<std::string, Elementary_type*>>& f, const int t) : Elementary_type(t), fields(f) {};
    Struct_type(std::list<std::pair<std::string, Elementary_type*>>& f) : Struct_type(f, AST::STRUCT) {};
};

class Class_type : public Elementary_type {
public:
    std::list<Struct_type*> list_fields;
    std::list<Function_type*> methods;
    Class_type (std::list<Struct_type*>&& lf, std::list<Function_type*>&& m) : list_fields(lf), methods(m), Elementary_type(AST::CLASS) {};
};

class Enum_type : public Elementary_type {
public:
    std::list<Elementary_type*> list_types;
    std::list<Function_type*> methods;
    Enum_type (std::list<Elementary_type*>&& lt, std::list<Function_type*>&& m) : list_types(lt), methods(m), Elementary_type(AST::UNION) {};
};


class Union_type : public Elementary_type {
public:
    std::list<Elementary_type*> list_types;
    std::list<Function_type*> methods;
    Union_type (std::list<Elementary_type*>&& lt, std::list<Function_type*>&& m) : list_types(lt), methods(m), Elementary_type(AST::UNION) {};
};


class Expression_class : public tree_node {
public:
    Expression_class(const int t) : tree_node(t) {};
    Expression_class() : tree_node(AST::VOID) {};
};

class Term_class : public Expression_class {
public:
    const Elementary_type *structure;
    const std::string value;

    Term_class(const std::string& v, const Elementary_type *s, const int t) : Expression_class(t), structure(s), value(v) {  };
    Term_class(const std::string& v, const int t) : Term_class(v, nullptr, t) {};
    Term_class(const std::string& v) : Term_class(v, AST::IDENTIFIER) {};
};

class list_node : public std::list<tree_node*> {};
