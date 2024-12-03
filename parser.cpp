#include "print_token.cpp"

#define PAD for (int i = 0; i < depth; i++) std::cout << '\t';
#define PRINT_TOKEN std::cout << print_token(TERM(n)->get_token()) << ' ';
#define CHECK_NULLPTRL(PTR) if (!PTR) { std::cerr << "Error: nullptr in " << __FUNCTION__ << std::endl; return; }

Tables tables;
tree *tree_root;
list_node program;

std::ofstream tty_file;
tree* node_debug;

const unsigned int priority[AST::EXPRS - AST::IDENTIFIER + 1] = {
    /* IDENTIFIER    */ 0,   // наивысший приоритет для идентификаторов и чисел
    /* NUMBER        */ 0,   // наивысший приоритет для чисел
    /* FUNCTION_CALL */ 0,   // вызов функции
    /* ASSIGN        */ 16,   // присваивание
    /* PLUS          */ 6,    // сложение
    /* MINUS         */ 6,    // вычитание
    /* MULTIPLY      */ 5,    // умножение
    /* DIVIDE        */ 5,    // деление
    /* PRE_INC       */ 3,    // префиксный инкремент
    /* PRE_DEC       */ 3,    // префиксный декремент
    /* INC_POST      */ 2,    // постфиксный инкремент
    /* DEC_POST      */ 2,    // постфиксный декремент
    /* BIT_AND       */ 1,    // побитовое И
    /* BIT_OR        */ 1,    // побитовое ИЛИ
    /* BIT_XOR       */ 1,    // побитовое исключающее ИЛИ
    /* SHL           */ 1,    // сдвиг влево
    /* SHR           */ 1,    // сдвиг вправо
    /* EQ            */ 1,    // равно
    /* NEQ           */ 1,    // не равно
    /* LT            */ 1,    // меньше
    /* LE            */ 1,    // меньше или равно
    /* GT            */ 1,    // больше
    /* GE            */ 1,    // больше или равно
    /* AND           */ 1,    // логическое И
    /* OR            */ 1     // логическое ИЛИ
};


void send_message_to_tty(const std::string& message) {
    tty_file << message << std::endl;
}

void print_variable_scoping(const list_node *stmts) {
    if (stmts->parent != nullptr) print_variable_scoping(stmts->parent);
    if (!stmts->symbols.empty()) {
        for (const auto &it : stmts->symbols) {
            send_message_to_tty(it.first);
        }
        send_message_to_tty("");
    }
}

void print_table(const list_node *l) {
    for (const auto &it : l->symbols) { std::cout << it.first << " " << print_token(it.second->get_token()) << std::endl; }
}

Symbol *find_symbol_local(list_node *stmts, const std::string s) {
    if (stmts == nullptr) return nullptr;
    auto n = stmts->symbols.find(s);

    return n == stmts->symbols.end() ? nullptr : (*n).second;
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
    const auto& t = node->token;
    if (t == AST::IDENTIFIER || t == AST::NUMBER || t == AST::FUNCTION_CALL) {
        out << (reinterpret_cast<Term_class*>(node))->value << " ";
    } else {
        out << print_token(node->token) << " ";
    }

    if (node->token > AST::FUNCTION_CALL) {
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

void print_code(list_node *stmts, std::size_t depth);

void correct_order_expr(tree_ref *expr, bool RIGHT) {
    if (expr->node->get_token() == AST::IDENTIFIER || expr->node->get_token() == AST::NUMBER || expr->node->get_token() == AST::FUNCTION_CALL
        || expr->node->right == nullptr) return; 

    tree_ref right(EXPR(expr->node->right), expr);

    if (priority[expr->node->get_token() - AST::IDENTIFIER] < priority[right.node->get_token() - AST::IDENTIFIER]) {
        if (RIGHT)
            expr->parent->node->right = right.node;
        else 
            expr->parent->node->left = right.node;

        expr->node->right = right.node->left;
        right.node->left = expr->node;

        tree_ref r(EXPR(right.node), expr->parent);
        correct_order_expr(&r, true);
    } 

    if (expr->node->right != nullptr) {
        tree_ref node(EXPR(expr->node->right), expr);
        correct_order_expr(&node, true);
    }

    if (expr->node->left != nullptr) {
        tree_ref node(EXPR(expr->node->left), expr);
        correct_order_expr(&node, false);
    }
}

void correct_order_expr(Expression_class *expr) {
    if (expr->get_token() == AST::IDENTIFIER || expr->get_token() == AST::NUMBER) return;
    node_debug = TREE(expr);
    tree_ref root(expr);
    tree_ref right(EXPR(expr->right), &root);
    tree_ref left(EXPR(expr->left), &root);
    correct_order_expr(&right, true);
    correct_order_expr(&left, false);
}


void print_term(node *n, std::size_t depth) {
    PAD; PRINT_TOKEN;
    std::cout << TERM(n)->value << std::endl;
}

void print_operation(node *n, std::size_t depth) {
    PAD; PRINT_TOKEN;

    if (EXPR(n)->get_token() == AST::ASSIGN) {
        tree *node = TREE(n);
        while (node->get_token() != AST::IDENTIFIER && node->left != nullptr) 
            node = node->left;
        std::cout <<  TERM(node)->value;
    }

    correct_order_expr(EXPR(n));
    std::ofstream out("tree.txt");
    serialize(TREE(n), out);
    out.close();
    getchar();
}

void print_if(node *n, std::size_t depth)
{
    PAD; 
    std::cout << LBL << print_token(n->get_token()) << ' ' << COM;
    print_operation(NODE(NODE_IF(n)->condition), depth);

    if (NODE_IF(n)->if_true != nullptr) {
        if (OPERATORS(NODE_IF(n)->if_true->get_token()))
            print_operation(NODE_IF(n)->if_true, depth + 1);
        else
            print_code(NODE_IF(n)->if_true, depth + 1);
    }
    if (NODE_IF(n)->if_false != nullptr) {
        PAD; std::cout << "else" << std::endl; 
        if (OPERATORS(NODE_IF(n)->if_true->get_token()))
            print_operation(NODE_IF(n)->if_false, depth + 1);
        else
            print_code(NODE_IF(n)->if_false, depth + 1);
    }
    // std::cout << std::endl;
}

void print_while(node *n, std::size_t depth)
{
    PAD; 
    std::cout << LBL << print_token(n->get_token()) << ' ' << COM;
    print_operation(NODE(NODE_WHILE(n)->condition), depth);

    if (NODE_WHILE(n)->stmts != nullptr) {
        if (OPERATORS(NODE_WHILE(n)->stmts->get_token()))
            print_operation(NODE_WHILE(n)->stmts, depth + 1);
        else
            print_code(NODE_WHILE(n)->stmts, depth + 1);
    }
}

void print_for(node *n, std::size_t depth)
{
    PAD; 
    std::cout << LBL << print_token(n->get_token()) << ' ' << COM << std::endl;
    if (NODE_FOR(n)->optexprs[0] != nullptr)
        for (auto &it : DEF(NODE_FOR(n)->optexprs[0])->exprs.vars->nodes) {
            print_operation(it, depth);
        }

    for (int i = 1; i < 3; i++) {
        if (NODE_FOR(n)->optexprs[i] != nullptr)
            print_operation(NODE(NODE_FOR(n)->optexprs[i]), depth);
    }

    print_code(NODE_FOR(n)->stmts, depth + 1);
}


void print_function_call(node *n, std::size_t depth) {
}

bool check_expr(list_node *stmt, node *n) { // true - если ошибка
    auto t = n->get_token();
    if (t == AST::IDENTIFIER || t == AST::FUNCTION_CALL) 
        return find_symbol(stmt, TERM(n)->value) == nullptr;
    if (t == AST::NUMBER)
        return false;

    return check_expr(stmt, TREE_NODE(n)->left) || check_expr(stmt, TREE_NODE(n)->right);
}

void print_code(list_node *stmts, std::size_t depth = 0) {
    static std::stack<list_node*> prev;
    send_message_to_tty("\n== == ==\n");
    send_message_to_tty(CLEAR);
    print_variable_scoping(stmts);
    for (const auto &it : stmts->nodes) {
        const unsigned int t = it->get_token();

        if (t == AST::IDENTIFIER || t == AST::NUMBER) {
            // std::cout << "print_term" << std::endl;
            print_term(it, depth);
        } else if (OPERATORS(t)) {
            print_operation(it, depth);
        } else if (t == AST::DEFINITION_VAR) {
            // std::cout << "DEFINITION_VAR" << std::endl;
            print_code(DEF(it)->exprs.vars, depth);
        } else if (t == AST::EXPRS) {
            // std::cout << "print_code" << std::endl;
            prev.push(stmts);
            print_code(EXPRS(it), depth);
            prev.pop();
        } else if (t == AST::STMTS) {
            std::cout << BLUE "compound stmt" COM << std::endl;
            // STMTS(it)->parent = stmts;
            // stmts->parent = prev.top();
            // prev.push(stmts);
            print_code(EXPRS(it), depth + 1);
            // prev.pop();
        } else if (t == AST::IF) {
            print_if(it, depth);
        } else if (t == AST::WHILE) {
            print_while(it, depth);
        } else if (t == AST::FOR) {
            print_for(it, depth);
        } else if (t == AST::FUNCTION_CALL) {
            // std::cout << "FUNCTION_CALL" << std::endl;
            auto *f = SYM_FUN(find_symbol(stmts, FUN_CALL(it)->value));
            if (f == nullptr) {
                std::cout << "Функция не объявлена" << std::endl;
            } else {
                if (f->get_token() != AST::FUNCTION || f->fun->code == nullptr) {
                    std::cout << "Функция не определена" << std::endl;
                    return;
                } 
            }

            PAD;
            std::cout << GLD << FUN_CALL(it)->value << ": "<< COM << std::endl;
            print_code(f->fun->code, depth + 1);
        } else {
            std::cout << print_token(t) << std::endl;
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

void create_variables(list_node *stmts, list_node *l, Elementary_type *type) {
    for (auto &it : l->nodes) {
        std::string *name;
        if (it->get_token() == AST::IDENTIFIER) {
            auto n = find_symbol_local(stmts, TERM(it)->value);
            if (n != nullptr) { // тип занят
                std::cout << "Переопределение переменной " << std::endl;
                abort();
            }
            name = &TERM(it)->value;
        } else {
            auto n = find_symbol_local(stmts, TERM(TREE_NODE(it)->left)->value);
            if (n != nullptr) { // тип ещё не занят
                std::cout << "Переопределение переменной " << std::endl;
                abort();
            }
            if (check_expr(stmts, TREE_NODE(it)->right)) {
                std::cout << "Ошибка в выражении" << std::endl;
                abort();
            } 
            name = &TERM(TREE_NODE(it)->left)->value;
        }
        stmts->symbols[*name] = new Symbol(AST::IDENTIFIER, type);
    }
}

void create_symbol_tables(list_node *stmts) {
    for (auto &it : stmts->nodes) {
        const unsigned int t = it->get_token();

        if (t == AST::DEFINITION_FUN) {
            std::string &name = DEF(it)->exprs.fun->first;
            Function_type *fun = &DEF(it)->exprs.fun->second;
            auto n = find_symbol_local(stmts, name);
            if (n == nullptr) { // индификатор ещё не занят
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
                    if (fun->parameters != nullptr) {
                        for (const auto &itt : *DEF(it)->exprs.fun->second.parameters) 
                            fun->code->symbols[itt->first] = new Symbol(AST::IDENTIFIER, itt->second);
                    }
                    fun->code->parent = stmts;
                    create_symbol_tables(fun->code);
                }
            } else {
                if (n->get_token() != AST::FUNCTION) {
                    std::cout << "Изначальное определение объекта - не функция: " << DEF(it)->type->name << std::endl;
                    abort();
                }
                if (fun->code == nullptr) {
                    // проверка на схожесть и ошибки
                    std::cout << "Переобъявление функции: " << DEF(it)->type->name << std::endl;
                    abort();
                }
                if (FUN(n)->code != nullptr) {
                    std::cout << "ХЗ вроде это ок: " << DEF(it)->type->name << std::endl; 
                    abort();
                }
                // if (fun->parameters != nullptr) {
                //     for (const auto &itt : *DEF(it)->exprs.fun->second.parameters) 
                //         fun->code->symbols[itt->first] = new Symbol(AST::IDENTIFIER, itt->second);
                // }

                SYM_FUN(n)->fun->code = fun->code;
                SYM_FUN(n)->fun->code->parent = stmts;
                create_symbol_tables(SYM_FUN(n)->fun->code);
                // проверка на схожест с объявлением.
            }
        } else if (t == AST::DEFINITION_VAR) {
            auto type = find_symbol(stmts, DEF(it)->type->name);
            if (type == nullptr) { 
                std::cout << "тип не найден: var: " << std::endl;
                abort();
            }
            if (!VARIABLES(type->get_token())) {
                std::cout << "Неправильное тип : var: " << std::endl;
                abort();
            }

            list_node *l = EXPRS(DEF(it)->exprs.vars);
            l->parent = stmts;
            create_variables(stmts, l, TYPE(type));
        } else if (t == AST::DEFINITION_TYPEDEF) {
        } else if (t == AST::EXPRS) {
        } else if (t == AST::STMTS) {
            STMTS(it)->parent = stmts;
            create_symbol_tables(STMTS(it));
        } else if (t == AST::IF) {
            if (NODE_IF(it)->condition == nullptr) {
                std::cout << "Ожидается условие" << std::endl;
                abort();
            }
            if (check_expr(stmts, NODE_IF(it)->condition)) {
                std::cout << "Ошибка в выраженииif" << std::endl;
                abort();
            }
            if (NODE_IF(it)->if_true != nullptr) {
                const auto tt =  NODE_IF(it)->if_true->get_token();
                if (STMT(tt)) {
                    if (check_expr(stmts, NODE_IF(it)->condition)) {
                        std::cout << "Ошибка в выражении" << std::endl;
                        abort();
                    }
                } else {
                    NODE_IF(it)->if_true->parent = stmts;
                    create_symbol_tables(NODE_IF(it)->if_true);
                }
            }
            if (NODE_IF(it)->if_false != nullptr) {
                const auto tt =  NODE_IF(it)->if_false->get_token();
                if (STMT(tt)) {
                    if (check_expr(stmts, NODE_IF(it)->condition)) {
                        std::cout << "Ошибка в выражении" << std::endl;
                        abort();
                    }
                } else {
                    NODE_IF(it)->if_false = stmts;
                    create_symbol_tables(NODE_IF(it)->if_false);
                }
            }
        } else if (t == AST::WHILE) {
            if (NODE_WHILE(it)->condition == nullptr) {
                std::cout << "Ожидается условие" << std::endl;
                abort();
            }
            if (check_expr(stmts, NODE_WHILE(it)->condition)) {
                std::cout << "Ошибка в выраженииif" << std::endl;
                abort();
            }
            const auto tt =  NODE_WHILE(it)->stmts->get_token();
            if (STMT(tt)) {
                if (check_expr(stmts, NODE_WHILE(it)->condition)) {
                    std::cout << "Ошибка в выражении" << std::endl;
                    abort();
                }
            } else {
                NODE_WHILE(it)->stmts->parent = stmts;
                create_symbol_tables(NODE_WHILE(it)->stmts);
            }
        } else if (t == AST::FOR) {
            int def = 0;
            if (NODE_FOR(it)->stmts == nullptr) {
                NODE_FOR(it)->stmts = new list_node;
            } else {
                if (STMT(NODE_FOR(it)->stmts->get_token())) {
                    if (check_expr(stmts, NODE_FOR(it)->stmts)) {
                        std::cout << "Ошибка в выражении" << std::endl;
                        abort();
                    }
                    auto s = new list_node;
                    s->nodes.push_back(NODE(NODE_FOR(it)->stmts)); 
                    NODE_FOR(it)->stmts = s;
                }
            }
            NODE_FOR(it)->stmts->parent = stmts;

            if (NODE_FOR(it)->optexprs[0] != nullptr && NODE_FOR(it)->optexprs[0]->get_token() == AST::DEFINITION_VAR) {
                auto type = find_symbol(stmts, DEF(NODE_FOR(it)->optexprs[0])->type->name);
                if (type == nullptr) { 
                    std::cout << "тип не найден: var: " << std::endl;
                    abort();
                }
                if (!VARIABLES(type->get_token())) {
                    std::cout << "Неправильное тип : var: " << std::endl;
                    abort();
                }

                list_node *l = DEF(NODE_FOR(it)->optexprs[0])->exprs.vars;
                create_variables(NODE_FOR(it)->stmts, l, TYPE(type));
                def = 1;
            }
            for (int i = def; i < 3; i ++) {
                if (NODE_FOR(it)->optexprs[i] == nullptr) {
                    if (check_expr(NODE_FOR(it)->stmts, NODE_FOR(it)->optexprs[i])) {
                        std::cout << "Ошибка в выражении while" << std::endl;
                        abort();
                    }
                }
            }

            create_symbol_tables(NODE_FOR(it)->stmts);
        } else {
            // std::cout << "Wrong token: " << print_token(t) << std::endl;
        }
    }
}


int main(int argc, char *argv[]) {
    tty_file.open(argv[1]);

    if (!tty_file.is_open()) {
        std::cout << RED "Терминал не открыт!" COM << std::endl;
    }

    analysis("test-file.c");

    program.symbols["void"]     = new Symbol(AST::VOID, new Elementary_type(AST::VOID));
    program.symbols["bool"]     = new Symbol(AST::BOOL, new Elementary_type(AST::BOOL));
    program.symbols["char"]     = new Symbol(AST::CHAR, new Elementary_type(AST::CHAR));
    program.symbols["int"]      = new Symbol(AST::INT, new Elementary_type(AST::INT));
    program.symbols["float"]    = new Symbol(AST::FLOAT, new Elementary_type(AST::FLOAT));
    program.symbols["double"]   = new Symbol(AST::DOUBLE, new Elementary_type(AST::DOUBLE));
    program.parent = nullptr;


    std::cout << "=== === ===\n" << std::endl;
    create_symbol_tables(&program);
    print_main();

    return 0;
}
