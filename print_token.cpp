#include "parser.hpp"

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
    case AST::FUNCTION:
        return std::string("function");

    case AST::FUNCTION_CALL:
        return std::string("f_call");

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

    case AST::SHL:
        return std::string("SHL");
    case AST::SHR:
        return std::string("SHR");
    case AST::EQ:
        return std::string("EQ");
    case AST::NEQ:
        return std::string("NEQ");
    case AST::LT:
        return std::string("LT");
    case AST::LE:
        return std::string("LE");
    case AST::GT:
        return std::string("GT");
    case AST::GE:
        return std::string("GE");

    case AST::AND:
        return std::string("AND");
    case AST::OR:
        return std::string("OR");

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