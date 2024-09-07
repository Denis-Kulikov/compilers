
#include "cpp-tree.hpp"


typedef struct Tables__ {
    std::unordered_map<std::string, node*> symbols;

    Tables__ () {
        symbols["void"] = reinterpret_cast<node*>(new Elementary_type(AST::VOID));
        symbols["bool"] = reinterpret_cast<node*>(new Elementary_type(AST::BOOL));
        symbols["char"] = reinterpret_cast<node*>(new Elementary_type(AST::CHAR));
        symbols["int"] = reinterpret_cast<node*>(new Elementary_type(AST::INT));
        symbols["float"] = reinterpret_cast<node*>(new Elementary_type(AST::FLOAT));
        symbols["double"] = reinterpret_cast<node*>(new Elementary_type(AST::DOUBLE));
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

void serialize(tree* node, std::ofstream& out);

void print_type(const Elementary_type *t);
node *find_type(char *s);
void end_expr();
bool push_type(const std::string &s, node *t);

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
