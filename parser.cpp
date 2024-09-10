#include "parser.hpp"

#define PAD for (int i = 0; i < depth; i++) std::cout << '\t';
#define CHECK_NULLPTRL(PTR) if (!PTR) { std::cerr << "Error: nullptr in " << __FUNCTION__ << std::endl; return; }

Tables tables;
tree *tree_root;
list_node program;


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

    case AST::DEFINITION_VAR:
        return std::string("def_var");
    case AST::DEFINITION_TYPEDEF:
        return std::string("def_type");
    case AST::DEFINITION_FUN:
        return std::string("def_fun");

    case AST::IF:
        return std::string("if");
    case AST::WHILE:
        return std::string("while");
    case AST::FOR:
        return std::string("for");

    case AST::NUMBER:
        return std::string("number");
    case AST::IDENTIFIER:
        return std::string("id");
    case AST::END:


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
    case AST::FUNCTION_CALL:
        return std::string("f_call");

    case AST::EXPRS:
        return std::string("EXPRS");
    case AST::STMT:
        return std::string("stmt");
    case AST::STMTS:
        return std::string("STMTS");

    default:
        return std::string("wrng_tkn_" + std::to_string(token));
    }
}

void print_table(const list_node *l) {
    for (const auto &it : l->symbols) { std::cout << it.first << " " << print_token(it.second->get_token()) << std::endl; }
}

Symbol *find_symbol(list_node *stmts, const std::string s) {
    if (stmts == nullptr) return nullptr;
    auto n = stmts->symbols.find(s);

    return n == stmts->symbols.end() ? find_symbol(stmts->parent, s) : (*n).second;
}

void serialize(tree* node, std::ofstream& out) {
    if (node == nullptr) {
        out << "# ";
        return;
    }
    if (node->token == AST::IDENTIFIER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else if (node->token == AST::NUMBER) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else {
        out << print_token(node->token) << " ";
    }

    if (node->token > AST::NUMBER) {
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

// void report() {
//     std::cout << "== == ==" << std::endl;
//     for (const auto &it : tables.symbols) {
//         std::cout << print_token(it.second->token) << " " << it.first << " ";
//         switch (it.second->token)
//         {
//         case AST::IDENTIFIER:
//             print_type(TERM(it.second)->type);
//             break;
        
//         case AST::FUNCTION:
//             print_type(FUN(it.second)->type);
//             if (FUN(it.second)->parameters != nullptr) {
//                 std::cout << "\n\t";
//                 for (const auto &it : *FUN(it.second)->parameters) {
//                     std::cout << "| ";
//                     print_type(it->second);
//                     std::cout << " " << it->first << " ";
//                 }
//             }
//             break;

//         default:
//             break;
//         }
//         std::cout << std::endl;
//     }
// }

class tree_ref {
public:
    tree_ref(Expression_class *n, tree_ref *p) : node(n), parent(p) {};
    tree_ref(Expression_class *n) : tree_ref(n, nullptr) {};
    Expression_class *node;
    tree_ref *parent;
} ;

void correct_order_expr(tree_ref *expr) {
    const unsigned int priority[AST::FUNCTION_CALL - AST::IDENTIFIER + 1] = {
        /* IDENTIFIER    */ 15,   // наивысший приоритет для идентификаторов и чисел
        /* NUMBER        */ 15,   // наивысший приоритет для чисел
        /* ASSIGN        */ 16,   // присваивание
        /* PLUS          */ 6,   // сложение
        /* MINUS         */ 6,   // вычитание
        /* MULTIPLY      */ 5,   // умножение
        /* DIVIDE        */ 5,   // деление
        /* PRE_INC       */ 3,   // префиксный инкремент
        /* PRE_DEC       */ 3,   // префиксный декремент
        /* INC_POST      */ 2,   // постфиксный инкремент
        /* DEC_POST      */ 2,   // постфиксный декремент
        /* BIT_AND       */ 0,   // побитовое И
        /* BIT_OR        */ 0,  // побитовое ИЛИ
        /* BIT_XOR       */ 0,   // побитовое исключающее ИЛИ
        /* SHL           */ 0,   // сдвиг влево
        /* SHR           */ 0,   // сдвиг вправо
        /* EQ            */ 0,  // равно
        /* NEQ           */ 0,  // не равно
        /* LT            */ 0,  // меньше
        /* LE            */ 0,  // меньше или равно
        /* GT            */ 0,  // больше
        /* GE            */ 0,  // больше или равно
        /* AND           */ 0,  // логическое И
        /* OR            */ 0,  // логическое ИЛИ
        /* FUNCTION_CALL */ 15    // вызов функции
    };

    if (expr->node->right == nullptr) return;
    // std::cout << "T = " << print_token(expr->node->get_token()) << std::endl;

    tree_ref right(EXPR(expr->node->right), expr);

    if (priority[expr->node->get_token() - AST::IDENTIFIER] < priority[right.node->get_token() - AST::IDENTIFIER]) {
            // std::cout << print_token(expr->node->get_token()) << " " << priority[expr->node->get_token() - AST::IDENTIFIER] << " "
            // << print_token(right.node->get_token()) << " " << priority[right.node->get_token() - AST::IDENTIFIER] << std::endl;
        if (expr->parent == nullptr) { return; }
        expr->parent->node->right = right.node;
        expr->node->right = right.node->left;
        right.node->left = expr->node;
        return;

        // if (expr->node->left->get_token() != AST::IDENTIFIER && expr->node->left->get_token() != AST::NUMBER && expr->node->left->get_token() != AST::FUNCTION_CALL) {
        //     tree_ref e(EXPR(expr->node->left), expr);
        //     correct_order_expr(&e);
        // }
        // if (expr->node->right->get_token() != AST::IDENTIFIER && expr->node->right->get_token() != AST::NUMBER && expr->node->right->get_token() != AST::FUNCTION_CALL) {
        //     tree_ref e(EXPR(expr->node->right), expr);
        //     correct_order_expr(&e);
        // }
    } 

    if (right.node->get_token() == AST::IDENTIFIER || right.node->get_token() == AST::NUMBER || right.node->get_token() == AST::FUNCTION_CALL)
        return;

    tree_ref e(EXPR(right.node), expr);
    correct_order_expr(&e);


    // if (right.node->get_token() == AST::IDENTIFIER || right.node->get_token() == AST::NUMBER || right.node->get_token() == AST::FUNCTION_CALL)
    //     return;

    // if (right.node->left->get_token() != AST::IDENTIFIER && right.node->left->get_token() != AST::NUMBER &&
    //     right.node->left->get_token() != AST::FUNCTION_CALL) {
    //     tree_ref e(EXPR(right.node->left), expr);
    //     correct_order_expr(&e);
    // }


    // if (right.node->right != nullptr &&
    //     right.node->right->get_token() != AST::IDENTIFIER && right.node->right->get_token() != AST::NUMBER && right.node->left->get_token() != AST::FUNCTION_CALL) {
    //     tree_ref e(EXPR(right.node->right), expr);
    //     correct_order_expr(&e);
    // }
}

void print_code(list_node *stmts, std::size_t depth);

void correct_order_expr(Expression_class *expr) {
    if (expr->get_token() == AST::IDENTIFIER || expr->get_token() == AST::NUMBER) return;
    tree_ref root(expr);
    tree_ref left(EXPR(expr->left), &root);
    correct_order_expr(&root);
    if (expr->left->get_token() == AST::IDENTIFIER || expr->left->get_token() == AST::NUMBER) return;
    correct_order_expr(&left);
}


void print_term(node *n, std::size_t depth) {
    PAD;
    std::cout << print_token(TERM(n)->get_token()) << ' ' << TERM(n)->value << std::endl;
}

void print_operation(node *n, std::size_t depth) {
    PAD;
    std::cout << print_token(EXPR(n)->get_token()) << ' ';

    if (EXPR(n)->get_token() == AST::ASSIGN) {
        tree *node = TREE(n);
        while (node->get_token() != AST::IDENTIFIER && node->left != nullptr) 
            node = node->left;
        std::cout <<  TERM(node)->value;
    }
    // {std::ofstream out("tree.txt");
    // serialize(TREE(it), out);
    // out.close();
    // getchar();}

    {correct_order_expr(EXPR(n));
    std::ofstream out("tree.txt");
    serialize(TREE(n), out);
    out.close();
    getchar();}
    // std::cout << std::endl;
}

void print_if(node *n, std::size_t depth)
{
    PAD;
    std::cout << print_token(IF(n)->get_token()) << ' ';
    if (IF(n)->if_true != nullptr) {
        std::cout << std::endl;
        if (OPERATORS(IF(n)->if_true->get_token()))
            print_operation(IF(n)->if_true, depth + 1);
        else
            print_code(IF(n)->if_true, depth + 1);
    }
    if (IF(n)->if_false != nullptr) {
        std::cout << std::endl;
        if (OPERATORS(IF(n)->if_true->get_token()))
            print_operation(IF(n)->if_false, depth + 1);
        else
            print_code(IF(n)->if_false, depth + 1);
    }
    std::cout << std::endl;
}

void print_function_call(node *n, std::size_t depth) {
    static std::string prev_function_name;
    PAD;
    // std::cout << print_token(n->get_token()) << ' ' << std::endl;
    // auto f = find_symbol(EXPRS(n), );
    // if (f == tables.symbols.end()) {
    //     std::cout << "Функция не объявлена" << std::endl;
    // } else {
    //     if (FUN(f->second)->code == nullptr) {
    //         std::cout << "Функция не определена" << std::endl;
    //     } else {
    //         std::cout << FUN_CALL(n)->value;
    //         std::cout << std::endl;
            // print_table(FUN(f->second)->code);
        //     if (prev_function_name != FUN_CALL(n)->value) {
        //         prev_function_name = FUN_CALL(n)->value;
        //         print_code(FUN(f->second)->code, depth + 1);
        //     }
        // }
    // }
}

void print_code(list_node *stmts, std::size_t depth = 0) {
    print_table(stmts);
    for (const auto &it : stmts->nodes) {
        const unsigned int t = it->get_token();

        if (t == AST::IDENTIFIER || t == AST::NUMBER) {
            // print_term(it, depth);
        } else if (t >= AST::ASSIGN && t <= AST::OR) {
            // print_operation(it, depth);
        } else if (t == AST::EXPRS) {
            // print_code(EXPRS(it), depth);
        } else if (t == AST::STMTS) {
        } else if (t == AST::IF) {
            // print_if(it, depth);
        } else if (t == AST::FUNCTION_CALL) {
            auto *f = SYM_FUN(find_symbol(stmts, FUN_CALL(it)->value));
            if (f == nullptr) {
                std::cout << "Функция не объявлена" << std::endl;
            } else {
                if (f->get_token() != AST::FUNCTION || f->fun->code == nullptr) {
                    std::cout << "Функция не определена" << std::endl;
                    return;
                } 
            }

            std::cout << GLD << FUN_CALL(it)->value << ": "<< COM << std::endl;
            print_code(f->fun->code, depth + 1);
            // print_function_call(f->fun->code, depth);

            // std::cout << GLD << FUN_CALL(it)->value << COM << std::endl;
            // auto *f = find_symbol(stmts, TERM(it)->value);
            // if (f != nullptr) {
            //     print_code(SYM_FUN(f)->fun->code);
            // }
        } else {
            // std::cout << print_token(t) << std::endl;
        }
    }
}

void print_main() {
    auto *m = find_symbol(&program, "main");
    if (m == nullptr) {
        std::cout << "The 'main' function was not found" << std::endl;
        return;
    } else if (m->get_token() != AST::FUNCTION) {
        std::cout << "The 'main' function does not have a function type" << std::endl;
        return;
    }

    auto *code = SYM_FUN(m)->fun->code;

    if (code == nullptr) {
        std::cout << "The 'main' function is not defined" << std::endl;
        return;
    }

    std::cout << GLD << "main:" << COM << std::endl;
    print_code(code);
}



void create_symbol_tables(list_node *stmts) {
    for (auto &it : stmts->nodes) {
        const unsigned int t = it->get_token();

        std::cout << "T = " << print_token(t) << std::endl;

        if (t == AST::DEFINITION_FUN) {
            std::string &name = DEF(it)->exprs.fun->first;
            Function_type *fun = &DEF(it)->exprs.fun->second;
            auto n = find_symbol(stmts, name);
            if (n == nullptr) { // индификатор ещё не занят
                std::cout << DEF(it)->type->name << std::endl;
                auto type = find_symbol(stmts, DEF(it)->type->name);
                if (type == nullptr) { 
                    std::cout << "Возвращаемое значение имеет неизвестный тип: " << DEF(it)->type->name << std::endl;
                    abort();
                }
                if (!VARIABLES(type->get_token())) {
                    std::cout << "Неправильное возвращаемое значение: " << DEF(it)->type->name << " - " << print_token(type->get_token()) << std::endl;
                    abort();
                }
                stmts->symbols[name] = new Symbol_Fun(AST::FUNCTION, type->type, fun);

                if (fun->code) {
                    fun->code->parent = stmts;
                    create_symbol_tables(fun->code);
                }
            }
            // else {
            //     if (n->get_token() != AST::FUNCTION) {
            //         std::cout << "Это не функция: " << DEF(it)->type->name << std::endl;
            //         abort();
            //     }
            //     if (DEF(it)->exprs.fun->second.code == nullptr) {
            //         // проверка на схожесть и ошибки
            //         std::cout << "Переобъявление функции: " << DEF(it)->type->name << std::endl;
            //         abort();
            //     }
            //     if (FUN(n)->code != nullptr) {
            //         std::cout << "ХЗ вроде это ок: " << DEF(it)->type->name << std::endl; 
            //         abort();
            //     }
            //     FUN(n)->code = FUN(it)->code;
            //     FUN(n)->code->parent = stmts;
            //     create_symbol_tables(FUN(n)->code);
            //     // проверка на схожест с объявлением.
            // }
        } else if (t == AST::DEFINITION_VAR) {
            list_node &l = *EXPRS(DEF(it)->exprs.vars);

            auto type = find_symbol(stmts, DEF(it)->type->name);
            if (type == nullptr) { 
                std::cout << "тип не найден: var: " << std::endl;
                abort();
            }
            if (!VARIABLES(type->get_token())) {
                std::cout << "Неправильное тип : var: " << std::endl;
                abort();
            }

            for (auto &itt : l.nodes) {
                std::string *name;
                if (itt->get_token() == AST::IDENTIFIER) {
                    auto n = find_symbol(stmts, TERM(itt)->value);
                    if (n != nullptr) { // тип ещё не занят
                        std::cout << "Переопределение переменной " << std::endl;
                        abort();
                    }
                    name = &TERM(itt)->value;
                } else {
                    auto n = find_symbol(stmts, TERM(TREE_NODE(itt)->left)->value);
                    if (n != nullptr) { // тип ещё не занят
                        std::cout << "Переопределение переменной " << std::endl;
                        abort();
                    }
                    name = &TERM(TREE_NODE(itt)->left)->value;
                }
                stmts->symbols[*name] = new Symbol(AST::IDENTIFIER, type->type);
            }
        } else if (t == AST::DEFINITION_TYPEDEF) {
        } else {
            std::cout << "Wrong token: " << print_token(t) << std::endl;
        }
    }
}


int main(void) {
    analysis("test-file.c");

    program.symbols["void"]     = new Symbol(AST::VOID, new Elementary_type(AST::VOID));
    program.symbols["bool"]     = new Symbol(AST::BOOL, new Elementary_type(AST::BOOL));
    program.symbols["char"]     = new Symbol(AST::CHAR, new Elementary_type(AST::CHAR));
    program.symbols["int"]      = new Symbol(AST::INT, new Elementary_type(AST::INT));
    program.symbols["float"]    = new Symbol(AST::FLOAT, new Elementary_type(AST::FLOAT));
    program.symbols["double"]   = new Symbol(AST::DOUBLE, new Elementary_type(AST::DOUBLE));
    program.parent = nullptr;


    // report();
    std::cout << "=== === ===" << std::endl;
    create_symbol_tables(&program);
    std::cout << "=== === ===" << std::endl;
    print_table(&program);
    std::cout << "=== === ===" << std::endl;
    print_main();

    return 0;
}
