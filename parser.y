%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string>

void yyerror(const char *s);
int yylex(void);
void yy_scan_string(const char *str);

extern int current_line;
extern int current_column;

std::map<std::string, int> symbol_table;
std::map<std::string, int> symbol_table;
int result;
%}

%union {
    int num;
    char* id;
}

%token <id> IDENTIFIER
%token <num> NUMBER
%token OPERATOR_PLUS OPERATOR_MINUS OPERATOR_MULTIPLY OPERATOR_DIVIDE
%token OPERATOR_MODULO OPERATOR_AND OPERATOR_OR OPERATOR_XOR
%token OPERATOR_NOT OPERATOR_TILDE

%token ASSIGN ASSIGNMENT_ADDITION ASSIGNMENT_SUBTRACTION ASSIGNMENT_MULTIPLICATION ASSIGNMENT_DIVISION ASSIGNMENT_REMAINDER ASSIGNMENT_BITWISE_AND ASSIGNMENT_BITWISE_OR ASSIGNMENT_BITWISE_XOR ASSIGNMENT_LSHIFT ASSIGNMENT_RSHIFT

%type <num> stmt expr term factor

%%

program:
    program stmt ';'   { /* пустое тело */ }
    |
    ;

stmt:
    IDENTIFIER ASSIGN expr {
        symbol_table[$1] = $3;
        std::cout << "Variable " << $1 << " assigned value: " << $3 << std::endl;
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_ADDITION expr {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] += $3;
            std::cout << "Variable " << $1 << " incremented by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_SUBTRACTION expr {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] -= $3;
            std::cout << "Variable " << $1 << " decremented by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_MULTIPLICATION expr {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] *= $3;
            std::cout << "Variable " << $1 << " multiplied by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    IDENTIFIER ASSIGNMENT_DIVISION expr {
        if (symbol_table.find($1) != symbol_table.end()) {
            symbol_table[$1] /= $3;
            std::cout << "Variable " << $1 << " divided by: " << $3 << std::endl;
        } else {
            yyerror("Undeclared variable");
        }
        free($1);
    }
    |
    expr {
        result = $1;
    }
    ;

expr:
    expr OPERATOR_PLUS term         { $$ = $1 + $3; }
  | expr OPERATOR_MINUS term        { $$ = $1 - $3; }
  | expr OPERATOR_AND term          { $$ = $1 & $3; }
  | expr OPERATOR_OR term           { $$ = $1 | $3; }
  | expr OPERATOR_XOR term          { $$ = $1 ^ $3; }
  | term                                 { $$ = $1; }
  ;

term:
    term OPERATOR_MULTIPLY factor         { $$ = $1 * $3; }
  | term OPERATOR_DIVIDE factor           { $$ = $1 / $3; }
  | term OPERATOR_MODULO factor           { $$ = $1 % $3; }
  | factor                                { $$ = $1; }
  ;

factor:
    "(" expr
  | expr ")"
  | OPERATOR_NOT factor                   { $$ = !$2; }
  | OPERATOR_TILDE factor                 { $$ = ~$2; }
  | NUMBER                                { $$ = $1; }
  | IDENTIFIER                            {
        if (symbol_table.find($1) != symbol_table.end()) {
            $$ = symbol_table[$1];
        } else {
            yyerror("Undeclared variable");
            $$ = 0;
        }
        free($1);
    }
    | "++" factor {}
    | factor "++" {}
    | "--" factor {}
    | factor "--" {}
  ;





enum_definition :
    "enum" ID '{' const_vals '}';

const_vals :
    ID num_lit
    | ID num_lit ',' const_vals;

struct_definition :
    "struct" ID '{' fields '}';

fields :
    field
    | field fields;

field :
    type ID ';';

class_definition :
    "class" ID '{' class_body '}';

class_body :
    class_member
    | class_member class_body;

class_member :
    access_specifier member;

access_specifier :
    "public:" | "private:" | "protected:";

member :
    field
    | function_definition;

function_definition :
    type ID '(' parameter_list ')' '{' program_list '}';

parameter_list :
    | parameter
    | parameter ',' parameter_list;

parameter :
    type ID;

program_list :
    program
    | program program_list;

program :
    expression
    | control_structure
    | struct_definition
    | class_definition
    | enum_definition;

expression :
    function_call
    | ID ASSIGN expression
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | '(' expression ')'
    | literal;

optexpr :
    expr
    |
    ;

literal :
    num_lit
    | string_lit
    | bool_lit;

control_structure :
    "if" '(' expression ')' '{' program_list '}'
    | "while" '(' expression ')' '{' program_list '}'
    | "for" '(' optexpr ';' optexpr ';' optexpr ')' '{' program_list '}';

function_call :
    ID '(' argument_list ')';

argument_list :
    | expression
    | expression ',' argument_list;


%%

void yyerror(const char *s) {
}

void yyerror(char *s)
{
    std::cerr << "Error: " << s << " at line " << current_line << ", column " << current_column << std::endl;
    // std::cerr << "Error: \"" << curr_filename << "\", line " << curr_lineno << ": " \ << s << " at or near ";
    print_cool_token(yychar);
    std::cerr << std::endl;
    parse_errors++;

    if (parse_errors > 50) {
        std::fprintf(stdout, "More than 50 parse errors\n");
        std::exit(1);
    }
}


void run_test(const char* test, const int real)
{
    yy_scan_string(test);
    yyparse();
    std::cout << "Result: " << (result == real ? "\033[32m" : "\033[31m") << result << " | " << real << "\033[0m" << std::endl;
}

int main(void) {
    run_test("2 + 3 * 2 - 5 % 3;", 6);
    run_test("4 + 5;", 9);
    run_test("9 - 6;", 3);
    run_test("3 * 3;", 9);
    run_test("10 / 2;", 5);
    run_test("10 % 3;", 1);
    run_test("6 & 3;", 2);
    run_test("4 | 1;", 5);
    run_test("5 ^ 3;", 6);
    run_test("!0;", 1);
    run_test("~5;", -6);

    // Пример теста с переменной
    yy_scan_string("x = 5 + 2 * 3; y = x - 4; x += 3;");
    yyparse();

    std::cout << "Final value of x: " << symbol_table["x"] << std::endl;
    std::cout << "Final value of y: " << symbol_table["y"] << std::endl;

    return 0;
}
