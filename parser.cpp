#include "parser.hpp"

#define CHECK_NULLPTRL(PTR) if (!PTR) { std::cerr << "Error: nullptr in " << __FUNCTION__ << std::endl; return; } \
// std::ofstream out("tree.txt"); serialize(tree_root.right, out); out.close(); getchar(); 

// "void"                  { types.push(tables.symbols["void"]); }
// "bool"                  { types.push(tables.symbols["bool"]); }
// "char"                  { types.push(tables.symbols["char"]); }
// "int"                   { types.push(tables.symbols["int"]); }
// "float"                 { types.push(tables.symbols["float"]); }
// "double"                { types.push(tables.symbols["double"]); }

int test = 0;
int tab = 0;
int result;

std::stack<tree_node*> stack_perenthesis;

Tables tables;
Stacks stacks;
Flags flags;
tree_node offset;
tree *tree_root;

list_stmt global_define;

// tree_node *cur_expr = &offset;
// tree_node *cur_var = &tree_root;

std::stack<tree_node*> expr_stack;

void init()
{
    tables.symbols.find("name");

}


std::string print_token(const int token);

void end_expr() {}

node *find_type(char *s)
{
    auto t = tables.symbols.find(s);
    if (t == tables.symbols.end() || t->second->token > AST::FUNCTION) return nullptr;
    return t->second;
}

bool push_type(const std::string &s, node *n) {
    auto t = tables.symbols.find(s);
    if (t != tables.symbols.end() && t->second->token > AST::FUNCTION) return false;
    
    tables.symbols[s] = n;
    return true;
}

void parenthesis_close() {
    pad(); std::cout << "Close '()'" << std::endl;
}

void parenthesis_open() {
    pad(); std::cout << "Open '()'" << std::endl;
}

void push_unary_operator(const int op) {
    pad(); std::cout << "unary_operator: " << print_token(op) << std::endl; // Отладочное сообщение
}

void push_operator(const int op) {
    pad(); std::cout << "operator: " << print_token(op) << std::endl; // Отладочное сообщение
}

void push_term(char *value, int t) {
    Term_class *term = new Term_class(value, nullptr, t);
    pad(); std::cout << "term: " << term->token << std::endl;
}


void add_pad() {
    const int MAX_PAD = 20;
    tab = (tab + 1) % MAX_PAD;
}

void remove_pad() {
    tab = tab < 1 ? 0 : tab - 1;
}

void pad() {
    for (int i = 0 ; i < tab; i++) std::cout << "  ";
}

std::string print_token(int token) {
    switch (token) {
    case AST::BOOL:
        return std::string("bool");
    case AST::CHAR:
        return std::string("char");
    case AST::INT:
        return std::string("int");
    case AST::FLOAT:
        return std::string("float");
    case AST::DOUBLE:
        return std::string("double");
    case AST::VOID:
        return std::string("void");
    case AST::PTR:
        return std::string("ptr");
    case AST::ARRAY:
        return std::string("array");
    case AST::STRUCT:
        return std::string("struct");
    // case AST::CLASS:
    //     return std::string("class");
    case AST::FUNCTION:
        return std::string("function");
    case AST::ASSIGN:
        return std::string("assign");
    case AST::PLUS:
        return std::string("plus");
    case AST::MINUS:
        return std::string("minus");
    case AST::MULTIPLY:
        return std::string("multiply");
    case AST::DIVIDE:
        return std::string("divide");
    case AST::PRE_INC:
        return std::string("pre_inc");
    case AST::PRE_DEC:
        return std::string("pre_dec");
    case AST::INC_POST:
        return std::string("inc_post");
    case AST::DEC_POST:
        return std::string("dec_post");
    case AST::NUMBER:
        return std::string("number");
    case AST::IDENTIFIER:
        return std::string("id");
    case AST::END:
        return std::string("end");
    default:
        return std::string("wrng_tkn_" + std::to_string(token));
    }
}

void serialize(tree* node, std::ofstream& out) {
    if (node == nullptr) {
        out << "# ";
        return;
    }
    if (node->token == AST::IDENTIFIER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
        std::cout << "VAR: " << TERM(node)->value << " " << print_token(TERM(node)->type->token) << std::endl;
    } else if (node->token == AST::NUMBER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else {
        out << print_token(node->token) << " ";
    }

    if (node->token > AST::NUMBER) {
        std::cout << "TERM: " << print_token(TERM(node)->token) << std::endl;
        serialize(TREE(node->left), out);
        serialize(TREE(node->right), out);
    } else {
        out << "# # ";
    }
}

void print_type(const Elementary_type *t) {
    if (t == nullptr) {
        std::cout << "\033[31mWrong type: nullptr\033[0m";
        return;
    }
    do {
        if (t->token < AST::PTR) {
            std::cout << print_token(t->token) << " ";
        } else if (t->token < AST::STRUCT) {
            std::cout << print_token(t->token) << " ";
            return;
        } else { // FUNCTION
            std::cout << print_token(t->token) << " ";
            return;
        }
    } while (t->token > AST::DOUBLE);
}

void report() {
    std::cout << "== == ==" << std::endl;
    for (const auto &it : tables.symbols) {
        std::cout << print_token(it.second->token) << " " << it.first << " ";
        switch (it.second->token)
        {
        case AST::IDENTIFIER:
            print_type(TERM(it.second)->type);
            break;
        
        case AST::FUNCTION:
            print_type(FUN(it.second)->type);
            if (FUN(it.second)->parameters != nullptr) {
                std::cout << "\n\t";
                for (const auto &it : *FUN(it.second)->parameters) {
                    std::cout << "| ";
                    print_type(it->second);
                    std::cout << " " << it->first << " ";
                }
            }
            break;

        default:
            break;
        }
        std::cout << std::endl;
    }
}

int main(void) {
    try {
        analysis("test-file.c");
    } catch(void *e) {
        std::ofstream out("tree.txt");
        serialize(tree_root, out);
        out.close();
    }

    std::ofstream out("tree.txt");
    serialize(tree_root, out);
    out.close();

    report();

    return 0;
}
