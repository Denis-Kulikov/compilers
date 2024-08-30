#include <iostream>
#include <fstream>
#include <cstring>
#include <string>
#include <memory>
#include <stack>

#include "cpp-tree.hpp"

#define CHECK_NULLPTRL(PTR) if (!PTR) { std::cerr << "Error: nullptr in " << __FUNCTION__ << std::endl; return; }

std::stack<tree_node*> stack_factor;
std::stack<tree_node*> stack_perenthesis;

std::stack<tree_node*> stack_perenthesis_root;


tree_node offset;

tree_node tree_root;

tree_node *cur_expr = &offset;
tree_node *cur_var = &tree_root;

void init()
{
    offset.right = &tree_root;
}


std::string print_token(const int token);
void lift();

void serialize(tree_node* node, std::ofstream& out) {
    if (node == nullptr) {
        out << "# ";
        return;
    }
    if (node->token == tree_node::IDENTIFIER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else {
        out << print_token(node->token) << " ";
    }
    serialize(node->left, out);
    serialize(node->right, out);
}

void push_unary_operator(const int op) {
    std::cout << "Calling push_unary_operator with op: " << print_token(op) << std::endl; // Отладочное сообщение
    CHECK_NULLPTRL (cur_expr);

    Expression_class *unary_operator = new Expression_class;

    unary_operator->left = cur_expr->right->left;
    cur_expr->right->left = unary_operator;

    unary_operator->token = op;
}

void push_operator(const int op) {
    std::cout << "Calling push_operator with op: " << print_token(op) << std::endl; // Отладочное сообщение
    CHECK_NULLPTRL (cur_expr);

    cur_expr->token = op;
    // cur_expr = cur_expr->right; // right должен создать cur_var
}

// void push_factor(Expression_class *e) {
//     CHECK_NULLPTRL (cur_expr);
//     stack_factor.push(cur_expr);
//     cur_expr->left = new Expression_class;
//     cur_expr = cur_expr->left;
//     cur_expr = e;
// }

void push_term(Term_class *e) {
    CHECK_NULLPTRL (cur_var);
    cur_var->right = new Expression_class;
    cur_var = cur_var->right;
    cur_var->left = e;

    // lift(); // нужен так, как cur_expr мог сместиться из-за factor
    // cur_var = cur_expr;
    // if (cur_var->right != nullptr) cur_var = cur_var->right; // обгон cur_expr

    // cur_var = cur_var->right;
    cur_expr = cur_expr->right;
}


void lift() // когда записал Term_class
{
    while (!stack_factor.empty() && stack_factor.top()->left == cur_expr) { // если factor был предыдущим оператором, то значит factor.left - это cur_expr
        cur_expr = stack_factor.top();
        stack_factor.pop();
    }
}

void lift_perenthesis() // когда встретился ')'
{
    if (!stack_perenthesis.empty()) {
        cur_expr = stack_perenthesis.top();
        stack_perenthesis.pop();
    }
}


std::string print_token(int token) {
    switch (token) {
    case tree_node::BOOL:
        return std::string("bool");
    case tree_node::CHAR:
        return std::string("char");
    case tree_node::INT:
        return std::string("int");
    case tree_node::FLOAT:
        return std::string("float");
    case tree_node::DOUBLE:
        return std::string("double");
    case tree_node::VOID:
        return std::string("void");
    case tree_node::PTR:
        return std::string("ptr");
    case tree_node::ARRAY:
        return std::string("array");
    case tree_node::STRUCT:
        return std::string("struct");
    case tree_node::CLASS:
        return std::string("class");
    case tree_node::FUNCTION:
        return std::string("function");
    case tree_node::ASSIGN:
        return std::string("assign");
    case tree_node::PLUS:
        return std::string("plus");
    case tree_node::MINUS:
        return std::string("minus");
    case tree_node::MULTIPLY:
        return std::string("multiply");
    case tree_node::DIVIDE:
        return std::string("divide");
    case tree_node::NUMBER:
        return std::string("number");
    case tree_node::IDENTIFIER:
        return std::string("id");
    case tree_node::END:
        return std::string("end");
    default:
        return std::string("unknown_token");
    }
}
