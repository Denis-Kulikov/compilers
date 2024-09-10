%{
#include "parser.hpp"
void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

extern Term_class *tree_root;
extern list_node global_define;

extern Tables tables;
extern list_node program;

%}

%union {
    char* strval;
    unsigned int type_index;
    class node *node_;
    class list_node *list;
    class Type_info *type_;
    class Define_class *def;
    class field *fields;
    class parameter *parameters;
    class list_parameter *list_parameters;
    class Function_type *fun;
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

%type <node_> finish
%type <list> program
%type <list> compound_stmt stmt_list
%type <node_> term prefix_term factor lvalue lexpr expr optexpr stmt
%type <type_> type 
%type <node_> fun_call
%type <node_> constructions selection_stmt iteration_stmt jump_stmt
%type <def> variable_declaration function_header type_declaration typedef grouping_type
%type <list> identifier_list_with_definition identifier_list_without_definition identifier_list arg_list
%type <fields> struct_field union_field enum_field
%type <parameters> parameter
%type <list_parameters> parameter_list_with_name parameter_list


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

finish:
    program { program.nodes = $1->nodes; }
    ;

program:
    type_declaration ';'                        { $$ = new list_node(); $$->nodes.push_back($1); }
    | function_header ';'                       { $$ = new list_node(); $$->nodes.push_back($1); }
    | function_header compound_stmt             { $$ = new list_node(); $$->nodes.push_back($1); $1->exprs.fun->second.code = $2; }
    | variable_declaration ';'                  { $$ = new list_node(); $$->nodes.push_back($1); }
    | program type_declaration ';'              { $$->nodes.push_back($2); }
    | program function_header ';'               { $$->nodes.push_back($2); }
    | program function_header compound_stmt     { $$->nodes.push_back($2); $2->exprs.fun->second.code = $3; } 
    | program variable_declaration ';'          { $$->nodes.push_back($2); }
    ;


// <== function ==>
fun_call:
    IDENTIFIER '(' arg_list ')' { $$ = new Function_call($1, $3); }
    ;

arg_list:
    /* empty */ { $$ = nullptr; }
    | expr { $$ = new list_node(); $$->nodes.push_back($1); }
    | arg_list ',' expr { $1->nodes.push_back($3); }
    ;


function_header:
    type IDENTIFIER '(' parameter_list ')' { 
        // auto *node = new std::pair<std::string, Function_type>;
        auto *n = new std::pair<std::string, Function_type>(std::string($2), Function_type($4));
        // node->first = std::string($2);
        // node->second = Function_type($4);
        n->second.code = nullptr;
        $$ = new Define_class(AST::DEFINITION_FUN, $1, NODE(n));
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
    CASE expr ':' case_stmt_list    { std::cout << "case" << std::endl; }
    | DEFAULT ':' case_stmt_list    { std::cout << "default" << std::endl; }
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
    type identifier_list { $$ = new Define_class(AST::DEFINITION_VAR, $1, NODE($2)); }
    ;

// <== type ==>
type_declaration:
    typedef { $$ = $1; }
    | grouping_type { $$ = $1; }
    ;

typedef:
    TYPEDEF type IDENTIFIER ';' { $$ = new Define_class(AST::DEFINITION_TYPEDEF, $2, NODE($3)); } // LIST !
    ;

grouping_type:
    struct      { std::cout << "\033[34m""struct""\033[0m" << std::endl; }
    | union     { std::cout << "\033[34m""union""\033[0m" << std::endl; }
    | enum      { std::cout << "\033[34m""enum""\033[0m" << std::endl; }
    ;

struct:
    STRUCT '{' struct_field_list '}' 
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
    type IDENTIFIER ';' { $$ = new field($2, $1); }
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
    IDENTIFIER                  { std::cout << "enum field: " << $1 << std::endl; }
    | IDENTIFIER ASSIGN expr    { std::cout << "enum field: " << $1 << std::endl; }
    ;


identifier_list:
    identifier_list_with_definition { $$ = $1; }
    | identifier_list_without_definition { $$ = $1; }
    ;


identifier_list_with_definition:
    IDENTIFIER ASSIGN expr
    {
        $$ = new list_node;
        auto *operation = new Expression_class(AST::ASSIGN);
        operation->left = new Term_class($1);
        operation->right = $3;
        $$->nodes.push_back(reinterpret_cast<node*>(operation));
    }
    | identifier_list_with_definition ',' IDENTIFIER ASSIGN expr
    {
        auto *operation = new Expression_class(AST::ASSIGN);
        operation->left = new Term_class($3);
        operation->right = $5;
        $$->nodes.push_back(reinterpret_cast<node*>(operation));
    }
    ;

identifier_list_without_definition:
    IDENTIFIER
    {
        $$ = new list_node;
        $$->nodes.push_back(new Term_class($1));
    }
    | identifier_list_without_definition ',' IDENTIFIER { $$->nodes.push_back(new Term_class($3)); }
    ;


type:
    IDENTIFIER { $$ = new Type_info($1); } // массив из флагов [name | str | struct | union | enum | long | ptr ]
    | STRUCT IDENTIFIER { /* auto t = find_type($2); if (t != nullptr && t->token == AST::STRUCT) $$ = t; else $$ = nullptr; */ }
    | UNION IDENTIFIER  { /* auto t = find_type($2); if (t != nullptr && t->token == AST::UNION) $$ = t; else $$ = nullptr; */ }
    | ENUM IDENTIFIER   { /* auto t = find_type($2); if (t != nullptr && t->token == AST::ENUM) $$ = t; else $$ = nullptr; */ }
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
    stmt { $$ = new list_node(); if ($1 != nullptr) $$->nodes.push_back($1); }
    | stmt_list stmt { $$ = $1; if ($2 != nullptr) $$->nodes.push_back($2); }
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
    INC term   { auto rvalue = new Expression_class(AST::PLUS); rvalue->left = $2; rvalue->right = new Term_class("1", AST::NUMBER);
                 auto Expr = new Expression_class(AST::ASSIGN); Expr->left = $2; Expr->right = rvalue;
                 $$ = Expr; }
    | DEC term { auto rvalue = new Expression_class(AST::MINUS); rvalue->left = $2; rvalue->right = new Term_class("1", AST::NUMBER);
                 auto Expr = new Expression_class(AST::ASSIGN); Expr->left = $2; Expr->right = rvalue;
                 $$ = Expr; }
    ;


term:
    NUMBER {  std::cout << $1 << std::endl; $$ = new Term_class($1, AST::NUMBER); }
    | IDENTIFIER { $$ = new Term_class($1, AST::IDENTIFIER); }
    | fun_call { $$ = $1; }
    | '(' expr ')' { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    std::exit(1);
}

void analysis(const std::string& filename) {
    std::ifstream file(filename);
    if (!file) {
        std::cerr << "Error: Unable to open file " << filename << std::endl;
        return;
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string str = buffer.str();

    std::cout << "\033[32m" << str << "\033[0m" << std::endl;

    yy_scan_string(str.c_str());
    yyparse();
}
