%{
#include "parser.hpp"

void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

%}

%union {
    char* strval;
    class Expression_class* expr;
    class Expression_class* factor;
    class Term_class* term;
}

%token <strval> IDENTIFIER NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token EQ NEQ LT LE GT GE AND OR INC DEC SHL SHR BIT_AND BIT_OR BIT_XOR BIT_NOT AMPERSAND
%token ASSIGN PLUSEQ MINUSEQ MULTEQ DIVEQ MODEQ ANDEQ OREQ XOREQ SHLEQ SHREQ
%token IF FOR WHILE DO SWITCH
%token BREAK CONTINUE GOTO RETURN
%token CASE DEFAULT
%token CONST UNSIGNED LONG SHORT STATIC INLINE EXTERN
%token STRUCT UNION ENUM
%token TYPEDEF
%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS
%type <expr> expr
%type <term> term
%type <expr> program

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    stmt_list { std::cout << "__  __  __" << std::endl; }
    ;

typedef:
    TYPEDEF IDENTIFIER IDENTIFIER

def:
    IDENTIFIER def_list { if (!find_type($1)) std::cout << "\033[31m" << "Wrong type: " << $1 << "\033[0m" << std::endl; }
    | STRUCT IDENTIFIER def_list { if (!find_type($2)) std::cout << "\033[31m" << "Wrong type: " << $2 << "\033[0m" << std::endl; }
    | struct def_list { }
    | fun_root
    ;

def_list:
    declaration
    | definition
    | declaration ',' def_list
    | definition ',' def_list
    ;

definition:
    declaration ASSIGN expr {}
    | declaration ternary {}
    ;

declaration:
    IDENTIFIER {}
    ;

fun:
    fun_root '{' stmt_list '}'
    | fun_root '{' '}'
    ;

fun_root:
    IDENTIFIER IDENTIFIER '(' parameter_list ')' { if (!find_type($1)) std::cout << "\033[31m" << "Wrong type: " << $1 << "\033[0m" << std::endl; }
    ;

parameter_list:
    /* empty */
    | parameter
    | parameter ',' parameter_list
    ;

parameter:
    IDENTIFIER IDENTIFIER { if (!find_type($1)) std::cout << "\033[31m" << "Wrong type: " << $1 << "\033[0m" << std::endl; }
    ;

fun_call:
    IDENTIFIER '(' arg_list ')' { /* код для вызова функции */ }
    ;

arg_list:
    /* empty */
    | expr
    | expr ',' arg_list
    ;

enum:
    ENUM '{' enum_field_list '}'
    | ENUM IDENTIFIER '{' enum_field_list '}'
    ;

enum_field_list:
    enum_field 
    | enum_field ',' enum_field_list
    ;

enum_field:
    IDENTIFIER
    ;

union:
    UNION '{' union_field_list '}'
    | UNION IDENTIFIER '{' union_field_list '}'
    ;

union_field_list:
    union_field 
    | union_field union_field_list
    ;

union_field:
    IDENTIFIER declaration ';'
    ;

struct:
    STRUCT '{' struct_field_list '}' // нужно запушить тип, чтобы иметь возможность сразу создать экземпляры struct {...} s;
    | STRUCT IDENTIFIER '{' struct_field_list '}'
    ;
    
struct_field_list:
    struct_field 
    | struct_field struct_field_list
    ;

struct_field:
    IDENTIFIER declaration ';'
    | IDENTIFIER definition ';'
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
    CASE expr ':' case_stmt_list    { std::cout << "case ';'\n" << std::endl; }
    | DEFAULT ':' case_stmt_list    { std::cout << "default ';'\n" << std::endl; }
    ;

case_stmt_list:
    /* empty */
    | stmt case_stmt_list


if_stmt:
    IF '(' expr ')' stmt %prec LOWER_THAN_ELSE
    | IF '(' expr ')' stmt ELSE stmt
    ;

goto:
    GOTO IDENTIFIER
    ;

goto_point:
    IDENTIFIER ':'
    ;



ternary:
    ASSIGN expr '?' expr ':' expr

stmt_list:
    stmt
    | stmt stmt_list
    ;

stmt:
    // expressions
    ';'
    | '{' stmt_list '}' { std::cout << "block ';'\n" << std::endl; }
    | expr ';'          { std::cout << "expr ';'\n" << std::endl; } // end_expr(); 
    // variables
    | def ';'           { std::cout << "def ';'\n" << std::endl; }
    | fun               { std::cout << "fun ';'\n" << std::endl; }
    | enum ';'          { std::cout << "enum ';'\n" << std::endl; }
    | union ';'         { std::cout << "union ';'\n" << std::endl; }
    | struct ';'        { std::cout << "struct ';'\n" << std::endl; }
    | typedef ';'       { std::cout << "typedef ';'\n" << std::endl; }
    // constructions
    | if_stmt {}
    // | IF '(' expr ')' stmt ELSE stmt                        { std::cout << "if-else" << std::endl; }
    // | FOR '(' optexpr ';' optexpr ';' optexpr ')' stmt      { std::cout << "for" << std::endl; }
    | WHILE '(' expr ')' stmt                               { std::cout << "while" << std::endl; }
    | DO stmt WHILE '(' expr ')' ';'
    | SWITCH '(' expr ')' '{' case_list_with_empty '}'      { std::cout << "switch" << std::endl; }
    | BREAK ';'        { std::cout << "break\n"; }
    | CONTINUE ';'     { std::cout << "continue\n"; }
    | goto ';'          { std::cout << "goto\n"; }
    | goto_point        { std::cout << "goto_point\n"; }
    | RETURN expr ';' { std::cout << "return\n"; }
    ;

expr_list:
    expr
    | expr expr_list
    ;

expr:
    expr ASSIGN term        { std::cout << "assing\n" << std::endl; }
    | expr PLUS term        { push_operator(AST::PLUS); }
    | expr MINUS term       { push_operator(AST::MINUS); }
    | expr MULTIPLY term    { push_operator(AST::MULTIPLY); }
    | expr DIVIDE term      { push_operator(AST::DIVIDE); }
    | expr BIT_AND term     { push_operator(AST::BIT_AND); }
    | expr BIT_OR term      { push_operator(AST::BIT_OR); }
    | expr BIT_XOR term     { push_operator(AST::BIT_XOR); }
    | expr SHL term         { push_operator(AST::SHL); }
    | expr SHR term         { push_operator(AST::SHR); }
    | expr EQ term          { push_operator(AST::EQ); }
    | expr NEQ term         { push_operator(AST::NEQ); }
    | expr LT term          { push_operator(AST::LT); }
    | expr LE term          { push_operator(AST::LE); }
    | expr GT term          { push_operator(AST::GT); }
    | expr GE term          { push_operator(AST::GE); }
    | expr AND term         { push_operator(AST::AND); }
    | expr OR term          { push_operator(AST::OR); }
    | term {}
    ;

term:
    NUMBER {}
    | IDENTIFIER { }
    | MINUS term { push_unary_operator(AST::MINUS);}
    | INC term { /* код для инкремента */ }
    | DEC term { /* код для декремента */ }
    | '(' expr ')' {}
    | fun_call {}
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

    std::cout << "\033[32m" << str << "\033[0m" << std::endl;

    yy_scan_string(str.c_str());
    yyparse();
}
