%{
#include "parser.hpp"
void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

extern std::list<tree_node*> expr_stack;
extern Term_class *tree_root;


%}

%union {
    char* strval;
    unsigned int type_index;
    union node *nodes;
    class list_node *list;
    class field *fields;
}

%token <strval> IDENTIFIER NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token EQ NEQ LT LE GT GE AND OR INC DEC SHL SHR BIT_AND BIT_OR BIT_XOR BIT_NOT AMPERSAND
%token ASSIGN PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ ANDEQ OREQ XOREQ SHLEQ SHREQ
%token IF FOR WHILE DO SWITCH
%token BREAK CONTINUE GOTO RETURN
%token CASE DEFAULT
%token CONST UNSIGNED LONG SHORT STATIC INLINE EXTERN
%token<type_index> STRUCT UNION ENUM
%token TYPEDEF
%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS
%type <nodes> term prefix_term factor lvalue lexpr expr
%type <nodes> program
%type <nodes> declaration declaration_list function_definition function_declaration variable_declaration type_declaration
%type <nodes> parameter_list parameter fun_call arg_list
%type <strval> function_header
%type <list> identifier_list_with_definition identifier_list_without_definition identifier_list
%type <nodes> optexpr;
%type <fields> struct_field union_field enum_field
%type <nodes> type;


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    declaration_list {}
    ;

declaration_list:
    declaration {}
    | declaration_list declaration {}
    ;

declaration:
    function_definition { pad(); std::cout << std::endl; }
    | function_declaration { pad(); std::cout << std::endl; }
    | variable_declaration ';' { pad(); std::cout << std::endl; }
    | type_declaration ';' { pad(); std::cout << std::endl; }
    ;


// <== function ==>
function_declaration:
    function_header ';' { pad(); std::cout << "function declaration: \033[33m" << $1 << "\033[0m" << std::endl;  }
    ;

function_definition:
    function_header compound_stmt { pad(); std::cout << "function: \033[33m" << $1 << "\033[0m" << std::endl;  }
    ;

function_header:
    type IDENTIFIER '(' parameter_list ')' { $$ = $2; }
    ;

parameter_list:
    /* empty */ {}
    | parameter_list_with_type {}
    ;

parameter_list_with_type:
    parameter {}
    | parameter ',' parameter_list_with_type {}
    ;

parameter:
    type IDENTIFIER { pad(); std::cout << "parameter: " << $2 << "" << std::endl; }
    ;

fun_call:
    IDENTIFIER '(' arg_list ')' { pad(); std::cout << "function: " << $1 << "" << std::endl; }
    ;

arg_list:
    /* empty */ {}
    | expr { pad(); std::cout << "arg: " << "" << std::endl; }
    | expr ',' arg_list { pad(); std::cout << "arg: " << "" << std::endl; }
    ;

// <== constructions ==>
constructions:
    selection_stmt
    | iteration_stmt
    | jump_stmt
    ;

selection_stmt:
    IF '(' expr ')' stmt %prec LOWER_THAN_ELSE
    | IF '(' expr ')' stmt ELSE stmt
    | SWITCH '(' expr ')' '{' case_list_with_empty '}'      { pad(); std::cout << "switch" << std::endl; }
    ;

iteration_stmt:
    WHILE '(' expr ')' stmt
    | DO stmt WHILE '(' expr ')' ';'
    | FOR '(' optexpr ';' optexpr ';' optexpr ')' stmt
    ;

jump_stmt:
    BREAK ';'
    | CONTINUE ';'
    | goto ';'          { pad(); std::cout << "goto" << std::endl;; }
    | goto_point        { pad(); std::cout << "goto_point" << std::endl;; }
    | RETURN expr ';'
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
            if (it->ast_node)
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
    struct      { pad(); std::cout << "\033[34mstruct\033[0m" << std::endl; }
    | union     { pad(); std::cout << "\033[34munion\033[0m" << std::endl; }
    | enum      { pad(); std::cout << "\033[34menum\033[0m" << std::endl; }
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
        auto *tree = new list_node;
        auto *identifier = new Expression_class(AST::ASSIGN);
        identifier->left = new Term_class($1);
        identifier->right = $3->expr;
        tree->push_back(reinterpret_cast<node*>(identifier));
        $$ = tree;
    }
    | identifier_list_with_definition ',' IDENTIFIER ASSIGN expr
    {
        pad(); std::cout << "definition: \033[35m" << $3 << "\033[0m" << std::endl; 
        auto *identifier = new Expression_class(AST::ASSIGN);
        identifier->left = new Term_class($3);
        identifier->right = $5->expr;
        $$->push_back(reinterpret_cast<node*>(identifier));
    }
    ;

identifier_list_without_definition:
    IDENTIFIER
    {
        pad(); std::cout << "declaration: \033[35m" << $1 << "\033[0m" << std::endl;
        auto *tree = new list_node;
        auto *identifier = new Term_class($1);
        tree->push_back(identifier);
        $$ = tree;
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
    | STRUCT IDENTIFIER { auto t = find_type($1); if (t != nullptr && t->type == AST::STRUCT) $$ = t; else $$ = nullptr;  }
    | UNION IDENTIFIER  { auto t = find_type($1); if (t != nullptr && t->type == AST::UNION) $$ = t; else $$ = nullptr;  }
    | ENUM IDENTIFIER   { auto t = find_type($1); if (t != nullptr && t->type == AST::ENUM) $$ = t; else $$ = nullptr;  }
    | struct    {  }
    | union     {  }
    | enum      {  }
    ;

// <== operations ==>

// ternary:
//     expr '?' expr ':' expr
//     ;

compound_stmt:
    '{' stmt_list '}'
    | '{' '}'
    ;

stmt_list:
    stmt
    | stmt stmt_list
    ;

stmt:
    ';'
    | compound_stmt { pad(); std::cout << "block" << std::endl; }
    | expr ';'          { pad(); std::cout << "expr" << std::endl; } // end_expr(); 
    | variable_declaration ';'
    | constructions
    ;


optexpr:
    /* empty */ { $$ = nullptr; }
    | expr { $$ = $1; }
    | variable_declaration { $$ = $1; }
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
    lvalue { $$ = $1; }
    | factor { $$ = $1; }
    ;

lvalue:
    term { $$ = $1; }
    | prefix_term { $$ = $1; }
    ;

factor:
    MINUS term { auto Expr = new Expression_class(AST::MINUS); Expr->left = $2; $$ = Expr; }
    | term INC { /* Нужно создание новой переменной */ }
    | term DEC { /* Нужно создание новой переменной */ }
    ;


prefix_term:
    INC term   { if (false /* если нет в таблице символов */) return 0;
                 auto Expr = new Expression_class(AST::ASSIGN); Expr->left = $2; Expr->right = new Expression_class(AST::PLUS); 
                 Expr->right->left = $2; Expr->right->right = new Term_class("1", AST::NUMBER); $$ = Expr; }
    | DEC term { if (false /* если нет в таблице символов */) return 0;
                 auto Expr = new Expression_class(AST::ASSIGN); node->left = $2; Expr->right = new Expression_class(AST::MINUS); 
                 Expr->right->left = $2; Expr->right->right = new Term_class("1", AST::NUMBER); $$ = Expr;  }
    ;


term:
    NUMBER { /* push_term(yylval.strval, AST::NUMBER); */ pad(); std::cout << $1 << std::endl; $$ = new Term_class($1, AST::NUMBER); }
    | IDENTIFIER { /* push_term(yylval.strval, AST::NUMBER);*/ pad(); std::cout << "term" << std::endl; $$ = new Term_class($1); /* нужно создать таблицу символов*/}
    | fun_call { }
    | '(' expr ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    // std::cerr << "Last token: " << yytext  << std::endl;
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
