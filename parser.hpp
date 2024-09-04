
#include "cpp-tree.hpp"

typedef int my_type;

typedef struct {
    Elementary_type Bool    = AST::BOOL;
    Elementary_type Char    = AST::CHAR;
    Elementary_type Int     = AST::INT;
    Elementary_type Float   = AST::FLOAT;
    Elementary_type Double  = AST::DOUBLE;
    Elementary_type Void    = AST::VOID;

    // Примеры более сложных типов
    // AST::Pointer_type IntPointer = {&Int};
    // AST::Array_type IntArray = {&Int, 10};
    // AST::Function_type IntToInt = {&Int, {&Int}};
} Elementary_types;

typedef struct Tables__ {
    std::unordered_map<std::string, node*> symbols;

    Tables__ (const Elementary_types &elementary_types) {
        symbols["void"]->Elementary = new Elementary_type(AST::VOID);
        symbols["bool"]->Elementary = new Elementary_type(AST::BOOL);
        symbols["char"]->Elementary = new Elementary_type(AST::CHAR);
        symbols["int"]->Elementary = new Elementary_type(AST::INT);
        symbols["float"]->Elementary = new Elementary_type(AST::FLOAT);
        symbols["double"]->Elementary = new Elementary_type(AST::DOUBLE);
    };
} Tables;

typedef struct {
    std::stack<Term_class*> types;
    std::stack<int> reason; // причина открытия скобок
} Stacks;

typedef struct {
    bool const_     = false;
    bool unsigned_  = false;
    bool long_      = false;
    bool short_     = false;
    bool static_    = false;
    bool inline_    = false;
} Flags;

void init();

void serialize(tree_node* node, std::ofstream& out);

node *find_type(char *name);
void end_expr();
bool push_type(const std::string &name, node *type);

void parenthesis_close();
void parenthesis_open();


void push_unary_operator(const int op);
void push_operator(const int op);
void push_term(char *value, int t);


// void lift(); // когда записал Term_class
// void lift_perenthesis(); // когда встретился ')'

std::string print_token(int token);

void add_pad();
void remove_pad();
void pad();


void analysis(const std::string& filename);
