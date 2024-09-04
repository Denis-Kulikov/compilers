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

Elementary_types elementary_types;
Tables tables(elementary_types);
Stacks stacks;
Flags flags;
tree_node offset;
Term_class *tree_root;

// tree_node *cur_expr = &offset;
// tree_node *cur_var = &tree_root;

std::stack<tree_node*> expr_stack;

void init()
{
}


std::string print_token(const int token);

bool find_type(char *name)
{
    auto t = tables.types.find(name);
    return !(t == tables.types.end());
}

typedef struct
{
    /* data */ 
} xxx;


void end_expr() {
    // tree_node *trash = cur_expr->right; // мусорный узел
    // cur_expr->right = cur_expr->right->left; // замена на переменную
    // delete trash;
}

void push_type(const std::string &s) {
    stacks.types.push(tables.symbols[s]);


}

void parenthesis_close() {
    pad(); std::cout << "Close '()'" << std::endl;

    // tree_node *trash = cur_expr->right; // мусорный узел
    // cur_expr->right = cur_expr->right->left; // замена на переменную
    // delete trash;

    // cur_expr = stack_perenthesis.top(); // возврат на предыдущую ветку
    // stack_perenthesis.pop();
    // cur_var = cur_expr; // в node->right хранится cur_var

    // cur_expr->right->left = stack_perenthesis.top()->right->right; // ***
    // delete stack_perenthesis.top()->right; // ***
    // stack_perenthesis.pop();
}

void parenthesis_open() {
    pad(); std::cout << "Open '()'" << std::endl;

    // cur_expr продвигается и создаётся term
    // cur_expr = cur_expr->right;
    // cur_expr->right = new Expression_class;

    // tree_node *new_offset1 = new tree_node;
    // tree_node *new_offset2 = new tree_node;
    // new_offset2->right = new_offset1;
    // stack_perenthesis.push(new_offset2);        
    // stack_perenthesis.push(cur_expr);

    // // добавление смещения
    // cur_expr = new_offset2; 
    // cur_var = new_offset1;
}

void push_unary_operator(const int op) {
    pad(); std::cout << "unary_operator: " << print_token(op) << std::endl; // Отладочное сообщение
    // CHECK_NULLPTRL (cur_expr);

    // Expression_class *unary_operator = new Expression_class;

    // unary_operator->left = cur_expr->right->left;
    // cur_expr->right->left = unary_operator;

    // unary_operator->token = op;
}

void push_operator(const int op) {
    pad(); std::cout << "operator: " << print_token(op) << std::endl; // Отладочное сообщение
    // CHECK_NULLPTRL (cur_expr);

    // cur_expr->token = op;
    // // cur_expr = cur_expr->right; // right должен создать cur_var
}

void push_term(char *value, int t) {
    Term_class *term = new Term_class(value, nullptr, t);
    pad(); std::cout << "term: " << term->token << std::endl;
    // CHECK_NULLPTRL (cur_var);
    // cur_var->right = new Expression_class;
    // cur_var = cur_var->right;
    // cur_var->left = term;

    // cur_expr = cur_expr->right;
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
    case AST::CLASS:
        return std::string("class");
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

void serialize(tree_node* node, std::ofstream& out) {
    if (node == nullptr) {
        out << "# ";
        return;
    }
    if (node->token == AST::IDENTIFIER || node->token == AST::NUMBER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else {
        out << print_token(node->token) << " ";
    }
    serialize(node->left, out);
    serialize(node->right, out);
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

    return 0;
}
