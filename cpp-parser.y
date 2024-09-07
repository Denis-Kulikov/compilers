%{
#include "parser.hpp"
void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

extern std::list<tree_node*> expr_stack;
extern Term_class *tree_root;
extern list_stmt global_define;

extern Tables tables;

%}

%union {
    char* strval;
    unsigned int type_index;
    class node *nodes;
    class list_node *list;
    class field *fields;
    class parameter *parameters;
    class list_parameter *list_parameters;
    class list_stmt *stmts;
    class Function_type *fun;
}

%token <strval> IDENTIFIER NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token EQ NEQ LT LE GT GE AND OR INC DEC SHL SHR BIT_AND BIT_OR BIT_XOR BIT_NOT AMPERSAND
%token ASSIGN PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ ANDEQ OREQ XOREQ SHLEQ SHREQ
%token  IF FOR WHILE DO SWITCH
%token BREAK CONTINUE GOTO RETURN
%token CASE DEFAULT
%token CONST UNSIGNED LONG SHORT STATIC INLINE EXTERN
%token<type_index> STRUCT UNION ENUM
%token TYPEDEF
%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS

%type program
%type <stmts> compound_stmt stmt_list
%type <nodes> term prefix_term factor lvalue lexpr expr optexpr type stmt
%type <nodes> variable_declaration type_declaration
%type <nodes> fun_call arg_list
%type <nodes> constructions selection_stmt iteration_stmt jump_stmt
%type <fun> function_header
%type <list> identifier_list_with_definition identifier_list_without_definition identifier_list
%type <fields> struct_field union_field enum_field
%type <parameters> parameter
%type <list_parameters> parameter_list_with_name parameter_list


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    type_declaration ';' 
    | function_header ';'
    | function_header compound_stmt { $1->code = $2; }
    | variable_declaration ';' { global_define.push_back($1); }
    | program type_declaration ';' 
    | program function_header ';'
    | program function_header compound_stmt { $2->code = $3; } 
    | program variable_declaration ';' { global_define.push_back($2); }
    ;

// definition_list:
//     function_declaration,
//     | type_declaration ';' { $$ = $1; }

// declaration_list:
//     declaration { $$ = new list_stmt(); if (declaration != nullptr) $$->push_back($1); }
//     | declaration_list declaration { $$ = $1; if (declaration != nullptr) $1->push_back($2); }
//     ;

// definition:
//     function_declaration,
//     | type_declaration ';' { $$ = $1; }
//     ;

// declaration:
//     | function_definition { $$ = $1; }
//     | variable_declaration ';' { $$ = $1; }
//     ;


// <== function ==>
fun_call:
    IDENTIFIER '(' arg_list ')' { pad(); std::cout << "function: " << $1 << "" << std::endl; }
    ;

arg_list:
    /* empty */ {}
    | expr { pad(); std::cout << "arg: " << "" << std::endl; }
    | expr ',' arg_list { pad(); std::cout << "arg: " << "" << std::endl; }
    ;


function_header:
    type IDENTIFIER '(' parameter_list ')' { 
        // if () если уже существует объявление или определение функции
        auto *fh = new Function_type(TYPE($1), $4);
        print_type(fh->type);
        tables.symbols[$2] = fh;
        $$ = fh;
        pad(); std::cout << "function: \033[33m" << $2 << "\033[0m" << std::endl;
     }
    ;

parameter_list:
    /* empty */ { $$ = nullptr; }
    | parameter_list_with_name { $$ = $1; }
    ;

parameter_list_with_name:
    parameter { $$ = new list_parameter(); $$->push_back($1); }
    | parameter_list_with_name ',' parameter { $$->push_back($3); }
    ;

parameter:
    type IDENTIFIER { $$ = new parameter($2, TYPE($1)); }
    ;


// <== constructions ==>
constructions:
    selection_stmt      { $$ = $1; }
    | iteration_stmt    { $$ = $1; }
    | jump_stmt         { $$ = $1; }
    ;

selection_stmt:
    IF '(' expr ')' stmt %prec LOWER_THAN_ELSE          { $$ = NODE(new if_class(EXPR($3), STMTS($5))); }
    | IF '(' expr ')' stmt ELSE stmt                    { $$ = NODE(new if_class(EXPR($3), STMTS($5), STMTS($7))); }
    | SWITCH '(' expr ')' '{' case_list_with_empty '}'  { $$ = nullptr; } // !!!
    ;

iteration_stmt:
    WHILE '(' expr ')' stmt                             { $$ = NODE(new while_class(EXPR($3), STMTS($5))); }
    | DO stmt WHILE '(' expr ')' ';'                    { $$ = nullptr; } // !!!
    | FOR '(' optexpr ';' optexpr ';' optexpr ')' stmt  { $$ = nullptr; } // !!!
    ;

jump_stmt:
    BREAK ';'           { $$ = nullptr; } // !!!
    | CONTINUE ';'      { $$ = nullptr; } // !!!
    | goto ';'          { $$ = nullptr; } // !!!
    | goto_point        { $$ = nullptr; } // !!!
    | RETURN expr ';'   { $$ = nullptr; } // !!!
    ;

case_list_with_empty:
    /* empty */
    | case_list
    ;

case_list:
    case
    | case case_list
    ;

case:
    CASE expr ':' case_stmt_list    { pad(); std::cout << "case" << std::endl; }
    | DEFAULT ':' case_stmt_list    { pad(); std::cout << "default" << std::endl; }
    ;

case_stmt_list:
    /* empty */
    | stmt case_stmt_list
    ;

goto:
    GOTO IDENTIFIER
    ;

goto_point:
    IDENTIFIER ':'
    ;


// <== variable ==>
variable_declaration:
    type identifier_list 
    {
        pad(); std::cout << "\033[31m";
        if ($2->empty()) std::cout << "Empty\033[0m" << std::endl;
        for (const auto &it : *$2) {
            node *n = TREE(it)->left != nullptr ? TREE(it)->left : n = it;
            TERM(n)->type = TYPE($1);
            if (tables.symbols.find(TERM(n)->value) == tables.symbols.end()) {
                tables.symbols[TERM(n)->value] = it;
            } else {
                // переобъявление переменной!
            }

            // std::cout << it-> ->value << ' ';
            tree_root = reinterpret_cast<Term_class*>(it);
        } 
        std::cout << "\033[0m" << std::endl;
    }
    ;

// <== type ==>
type_declaration:
    typedef { pad(); std::cout << "typedef" << std::endl; }
    | grouping_type {}
    ;

typedef:
    TYPEDEF type IDENTIFIER ';' { if (push_type($3, $2)) { pad(); std::cout << "\033[34msErrorL: typedef\033[0m" << std::endl; } }
    ;

grouping_type:
    struct      { pad(); std::cout << "\033[34m""struct""\033[0m" << std::endl; }
    | union     { pad(); std::cout << "\033[34m""union""\033[0m" << std::endl; }
    | enum      { pad(); std::cout << "\033[34m""enum""\033[0m" << std::endl; }
    ;

struct:
    STRUCT '{' struct_field_list '}' // нужно запушить тип, чтобы иметь возможность сразу создать экземпляры struct {...} s;
    | STRUCT identifier_list_without_definition '{' struct_field_list '}'
    ;
    
struct_field_list:
    struct_field 
    | struct_field struct_field_list
    ;

struct_field:
    type identifier_list_without_definition ';' {}
    ;

union:
    UNION '{' union_field_list '}'
    | UNION identifier_list_without_definition '{' union_field_list '}'
    ;

union_field_list:
    union_field 
    | union_field union_field_list
    ;

union_field:
    type IDENTIFIER ';' { pad(); std::cout << "union field: " << $2 << std::endl; 
        if ($1 == nullptr) { std::cout << "\033[31mWrong type: union field " << $2 << "\033[0m" << std::endl; }
        $$ = new field($2, $1);
    }
    ;


enum:
    ENUM '{' enum_field_list '}'
    | ENUM identifier_list_without_definition '{' enum_field_list '}' 
    ;

enum_field_list:
    enum_field {}
    | enum_field ',' enum_field_list {}
    ;

enum_field:
    IDENTIFIER                  { pad(); std::cout << "enum field: " << $1 << std::endl; }
    | IDENTIFIER ASSIGN expr    { pad(); std::cout << "enum field: " << $1 << std::endl; }
    ;


identifier_list:
    identifier_list_with_definition { $$ = $1; }
    | identifier_list_without_definition { $$ = $1; }
    ;


identifier_list_with_definition:
    IDENTIFIER ASSIGN expr
    {
        pad(); std::cout << "definition: \033[35m" << $1 << "\033[0m" << std::endl; 
        auto *expr = new list_node;
        auto *operation = new Expression_class(AST::ASSIGN);
        operation->left = new Term_class($1);
        operation->right = $3;
        expr->push_back(reinterpret_cast<node*>(operation->left));
        $$ = expr;
    }
    | identifier_list_with_definition ',' IDENTIFIER ASSIGN expr
    {
        pad(); std::cout << "definition: \033[35m" << $3 << "\033[0m" << std::endl; 
        auto *operation = new Expression_class(AST::ASSIGN);
        operation->left = new Term_class($3);
        operation->right = $5;
        $$->push_back(reinterpret_cast<node*>(operation->left));
    }
    ;

identifier_list_without_definition:
    IDENTIFIER
    {
        pad(); std::cout << "declaration: \033[35m" << $1 << "\033[0m" << std::endl;
        auto *expr = new list_node;
        auto *identifier = new Term_class($1);
        expr->push_back(identifier);
        $$ = expr;
    }
    | identifier_list_without_definition ',' IDENTIFIER
    {
        pad(); std::cout << "declaration: \033[35m" << $3 << "\033[0m" << std::endl;
        auto *identifier = new Term_class($3);
        $$->push_back(identifier);
    }
    ;


type:
    IDENTIFIER { $$ = find_type($1); }
    | STRUCT IDENTIFIER { auto t = find_type($2); if (t != nullptr && t->token == AST::STRUCT) $$ = t; else $$ = nullptr;  }
    | UNION IDENTIFIER  { auto t = find_type($2); if (t != nullptr && t->token == AST::UNION) $$ = t; else $$ = nullptr;  }
    | ENUM IDENTIFIER   { auto t = find_type($2); if (t != nullptr && t->token == AST::ENUM) $$ = t; else $$ = nullptr;  }
    | struct    {  }
    | union     {  }
    | enum      {  }
    ;

// <== operations ==>

// ternary:
//     expr '?' expr ':' expr
//     ;

compound_stmt:
    '{' stmt_list '}' { $$ = $2; }
    | '{' '}'         { $$ = nullptr; }
    ;

stmt_list:
    stmt { $$ = new list_stmt(); if ($1 != nullptr) $$->push_back($1); }
    | stmt_list stmt { $$ = $1; if ($2 != nullptr) $$->push_back($2); }
    ;

stmt:
    ';'                         { $$ = nullptr; }
    | compound_stmt             { $$ = NODE($1); }
    | expr ';'                  { $$ = $1; }
    | variable_declaration ';'  { $$ = $1; }
    | constructions             { $$ = $1; }
    ;


optexpr:
    /* empty */             { $$ = nullptr; }
    | expr                  { $$ = $1; }
    | variable_declaration  { $$ = $1; }
    ;

expr:
    lexpr                  { $$ = $1;  } 
    | lvalue ASSIGN expr   { auto Expr = new Expression_class(AST::ASSIGN);    Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr PLUS expr      { auto Expr = new Expression_class(AST::PLUS);      Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr MINUS expr     { auto Expr = new Expression_class(AST::MINUS);     Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr MULTIPLY expr  { auto Expr = new Expression_class(AST::MULTIPLY);  Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr DIVIDE expr    { auto Expr = new Expression_class(AST::DIVIDE);    Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr BIT_AND expr   { auto Expr = new Expression_class(AST::BIT_AND);   Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr BIT_OR expr    { auto Expr = new Expression_class(AST::BIT_OR);    Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr BIT_XOR expr   { auto Expr = new Expression_class(AST::BIT_XOR);   Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr SHL expr       { auto Expr = new Expression_class(AST::SHL);       Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr SHR expr       { auto Expr = new Expression_class(AST::SHR);       Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr EQ expr        { auto Expr = new Expression_class(AST::EQ);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr NEQ expr       { auto Expr = new Expression_class(AST::NEQ);       Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr LT expr        { auto Expr = new Expression_class(AST::LT);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr LE expr        { auto Expr = new Expression_class(AST::LE);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr GT expr        { auto Expr = new Expression_class(AST::GT);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr GE expr        { auto Expr = new Expression_class(AST::GE);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr AND expr       { auto Expr = new Expression_class(AST::AND);       Expr->left = $1; Expr->right = $3; $$ = Expr; }
    | lexpr OR expr        { auto Expr = new Expression_class(AST::OR);        Expr->left = $1; Expr->right = $3; $$ = Expr; }
    ;

lexpr:
    lvalue      { $$ = $1; }
    | factor    { $$ = $1; }
    ;

lvalue:
    term            { $$ = $1; }
    | prefix_term   { $$ = $1; }
    ;

factor:
    MINUS term { auto Expr = new Expression_class(AST::MINUS); Expr->left = $2; $$ = Expr; }
    | term INC { /* Нужно создание новой переменной */ }
    | term DEC { /* Нужно создание новой переменной */ }
    ;


prefix_term:
    INC term   { if (false /* если нет в таблице символов */) return 0;
                 auto Expr = new Expression_class(AST::ASSIGN); Expr->left = $2; Expr->right = NODE(new Expression_class(AST::PLUS)); 
                 TREE(Expr)->right->left = $2; TREE(Expr)->right->right = new Term_class("1", AST::NUMBER); $$ = Expr; }
    | DEC term { if (false /* если нет в таблице символов */) return 0;
                 auto Expr = new Expression_class(AST::ASSIGN); Expr->left = $2; Expr->right = NODE(new Expression_class(AST::MINUS)); 
                 TREE(Expr)->right->left = $2; TREE(Expr)->right->right = new Term_class("1", AST::NUMBER); $$ = Expr;  }
    ;


term:
    NUMBER { /* push_term(yylval.strval, AST::NUMBER); */ pad(); std::cout << $1 << std::endl; $$ = new Term_class($1, AST::NUMBER); }
    | IDENTIFIER { pad(); std::cout << "term" << std::endl; if (tables.symbols.find($1) != tables.symbols.end()) $$ = tables.symbols[$1]; else $$ = nullptr; /* нужно создать таблицу символов*/}
    | fun_call { }
    | '(' expr ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    std::exit(1);
}

void analysis(const std::string& filename) {
    init();

    std::ifstream file(filename);
    if (!file) {
        std::cerr << "Error: Unable to open file " << filename << std::endl;
        return;
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string str = buffer.str();

    pad(); std::cout << "\033[32m" << str << "\033[0m" << std::endl;

    yy_scan_string(str.c_str());
    yyparse();
}
