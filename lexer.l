%{
#include "parser.tab.h"
%}

%option noyywrap

COMMENT_SINGLELINE  "//"[^\n]*
COMMENT_MULTILINE   "/*"[^"*/"]*"*/"

INT_LIT  (0[bB][0-1]+([0-1]|\'[0-1])*|0[xX][0-9a-fA-F]+([0-9a-fA-F]|\'[0-9a-fA-F])*|0[0-8]+(\'[0-8]|[0-8])*|[0-9]+(\'[0-9]|[0-9])*)([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)

FLOAT_LIT    \d+\.\d*([eE][-+]?\d+)?[fFlL]?
STRING_LIT   "(\\.|[^\"\\])*"
CHAR_LIT     '(\\.|[^\'\\])'


ASSIGNMENT                      "="
ASSIGNMENT_ADDITION             "+="
ASSIGNMENT_SUBTRACTION          "-="
ASSIGNMENT_MULTIPLICATION       "*="
ASSIGNMENT_DIVISION             "/="
ASSIGNMENT_REMAINDER            "%="
ASSIGNMENT_BITWISE_AND          "&="
ASSIGNMENT_BITWISE_OR           "|="
ASSIGNMENT_BITWISE_XOR          "^="
ASSIGNMENT_LSHIFT               "<<="
ASSIGNMENT_RSHIFT               ">>="

COMPARISON_EQ                   "=="
COMPARISON_NEQ                  "!="
COMPARISON_LE                   "<="
COMPARISON_GE                   ">="
COMPARISON_LT                   "<"
COMPARISON_GT                   ">"

OPERATOR_PLUS                   "+"
OPERATOR_MINUS                  "-"
OPERATOR_MULTIPLY               "*"
OPERATOR_DIVIDE                 "/"
OPERATOR_MODULO                 "%"
OPERATOR_AND                    "&"
OPERATOR_OR                     "|"
OPERATOR_XOR                    "^"
OPERATOR_NOT                    "!"
OPERATOR_TILDE                  "~"

LOGICAL_NOT                     "!"
LOGICAL_AND                     "&&"
LOGICAL_OR                      "||" 
BITWISE_AND                     "&"
BITWISE_OR                      "|" 
BITWISE_XOR                     "^"
BITWISE_NOT                     "~"
BITWISE_LSHIFT                  "<<"
BITWISE_RSHIFT                  ">>"

KEYWORD_BOOL                    bool
KEYWORD_CHAR                    char
KEYWORD_INT                     int
KEYWORD_FLOAT                   float
KEYWORD_DOUBLE                  double
KEYWORD_ENUM                    enum

KEYWORD_NEW                     new
KEYWORD_DELETE                  delete
KEYWORD_NULLPTR                 nullptr
KEYWORD_AUTO                    auto
KEYWORD_CONST                   const
KEYWORD_UNSIGNED                unsigned
KEYWORD_INLINE                  inline
KEYWORD_LONG                    long
KEYWORD_MUTABLE                 mutable

KEYWORD_CLASS                   class
KEYWORD_STRUCT                  struct
KEYWORD_UNION                   union

KEYWORD_BREAK                   break
KEYWORD_CONTINUE                continue
KEYWORD_RETURN                  return
KEYWORD_GOTO                    goto
KEYWORD_SWITCH                  switch
KEYWORD_CASE                    case
KEYWORD_DEFAULT                 default
KEYWORD_TRY                     try
KEYWORD_CATCH                   catch
KEYWORD_THROW                   throw

KEYWORD_IF                      if 
KEYWORD_ELSE                    else
KEYWORD_FOR                     for
KEYWORD_DO                      do 
KEYWORD_WHILE                   while

KEYWORD_PRIVATE                 private
KEYWORD_PROTECTED               protected
KEYWORD_PUBLIC                  public

KEYWORD_NAMESPACE               namespace
KEYWORD_TYPEDEF                 typedef
KEYWORD_TYPEID                  typeid
KEYWORD_TYPENAME                typename
KEYWORD_USING                   using
KEYWORD_VIRTUAL                 virtual

KEYWORD_FINAL                   final
KEYWORD_EXPLICIT                explicit
KEYWORD_EXPORT                  export
KEYWORD_EXTERN                  extern
KEYWORD_FRIEND                  friend
KEYWORD_OPERATOR                operator
KEYWORD_REGISTER                register
KEYWORD_STATIC                  static
KEYWORD_NOEXCEPT                noexcept
KEYWORD_OVERRIDE                override
KEYWORD_VOLATILE                volatile
KEYWORD_CONSTEXPR               constexpr

KEYWORD_CONST_CAST              const_cast
KEYWORD_DYNAMIC_CAST            dynamic_cast
KEYWORD_REINTERPRET_CAST        reinterpret_cast
KEYWORD_STATIC_CAST             static_cast

KEYWORD_TRUE                    true
KEYWORD_FALSE                   false

IDENT    [_a-zA-Z][_a-zA-Z0-9]*

%%

{COMMENT_SINGLELINE}    { cout << "Single-line Comment: " << yytext << endl; }
{COMMENT_MULTILINE}     { cout << "Multi-line Comment: " << yytext << endl; }

{INT_LIT}        { cout << "Integer Literal: " << yytext << endl; }
{FLOAT_LIT}      { cout << "Floating Literal: " << yytext << endl; }
{STRING_LIT}     { cout << "String Literal: " << yytext << endl; }
{CHAR_LIT}       { cout << "Character Literal: " << yytext << endl; }

{ASSIGNMENT}                { cout << "ASSIGNMENT: " << yytext << endl; }
{ASSIGNMENT_ADDITION}       { cout << "ASSIGNMENT_ADDITION: " << yytext << endl; }
{ASSIGNMENT_SUBTRACTION}    { cout << "ASSIGNMENT_SUBTRACTION: " << yytext << endl; }
{ASSIGNMENT_MULTIPLICATION} { cout << "ASSIGNMENT_MULTIPLICATION: " << yytext << endl; }
{ASSIGNMENT_DIVISION}       { cout << "ASSIGNMENT_DIVISION: " << yytext << endl; }
{ASSIGNMENT_REMAINDER}      { cout << "ASSIGNMENT_REMAINDER: " << yytext << endl; }
{ASSIGNMENT_BITWISE_AND}    { cout << "ASSIGNMENT_BITWISE_AND: " << yytext << endl; }
{ASSIGNMENT_BITWISE_OR}     { cout << "ASSIGNMENT_BITWISE_OR: " << yytext << endl; }
{ASSIGNMENT_BITWISE_XOR}    { cout << "ASSIGNMENT_BITWISE_XOR: " << yytext << endl; }
{ASSIGNMENT_LSHIFT}         { cout << "ASSIGNMENT_LSHIFT: " << yytext << endl; }
{ASSIGNMENT_RSHIFT}         { cout << "ASSIGNMENT_RSHIFT: " << yytext << endl; }

{KEYWORD_BOOL}      { cout << "KEYWORD_BOOL" << endl; }
{KEYWORD_CHAR}      { cout << "KEYWORD_CHAR" << endl; }
{KEYWORD_INT}       { cout << "KEYWORD_INT" << endl; }
{KEYWORD_FLOAT}     { cout << "KEYWORD_FLOAT" << endl; }
{KEYWORD_DOUBLE}    { cout << "KEYWORD_DOUBLE" << endl; }
{KEYWORD_ENUM}      { cout << "KEYWORD_ENUM" << endl; }

{KEYWORD_NEW}       { cout << "KEYWORD_NEW" << endl; }
{KEYWORD_DELETE}    { cout << "KEYWORD_DELETE" << endl; }
{KEYWORD_NULLPTR}   { cout << "KEYWORD_NULLPTR" << endl; }
{KEYWORD_AUTO}      { cout << "KEYWORD_AUTO" << endl; }
{KEYWORD_CONST}     { cout << "KEYWORD_CONST" << endl; }
{KEYWORD_UNSIGNED}  { cout << "KEYWORD_UNSIGNED" << endl; }
{KEYWORD_INLINE}    { cout << "KEYWORD_INLINE" << endl; }
{KEYWORD_LONG}      { cout << "KEYWORD_LONG" << endl; }
{KEYWORD_MUTABLE}   { cout << "KEYWORD_MUTABLE" << endl; }

{KEYWORD_CLASS}     { cout << "KEYWORD_CLASS" << endl; }
{KEYWORD_STRUCT}    { cout << "KEYWORD_STRUCT" << endl; }
{KEYWORD_UNION}     { cout << "KEYWORD_UNION" << endl; }

{KEYWORD_BREAK}     { cout << "KEYWORD_BREAK" << endl; }
{KEYWORD_CONTINUE}  { cout << "KEYWORD_CONTINUE" << endl; }
{KEYWORD_RETURN}    { cout << "KEYWORD_RETURN" << endl; }
{KEYWORD_GOTO}      { cout << "KEYWORD_GOTO" << endl; }
{KEYWORD_SWITCH}    { cout << "KEYWORD_SWITCH" << endl; }
{KEYWORD_CASE}      { cout << "KEYWORD_CASE" << endl; }
{KEYWORD_DEFAULT}   { cout << "KEYWORD_DEFAULT" << endl; }
{KEYWORD_TRY}       { cout << "KEYWORD_TRY" << endl; }
{KEYWORD_CATCH}     { cout << "KEYWORD_CATCH" << endl; }
{KEYWORD_THROW}     { cout << "KEYWORD_THROW" << endl; }

{KEYWORD_IF}        { cout << "KEYWORD_IF" << endl; }
{KEYWORD_ELSE}      { cout << "KEYWORD_ELSE" << endl; }
{KEYWORD_FOR}       { cout << "KEYWORD_FOR" << endl; }
{KEYWORD_DO}        { cout << "KEYWORD_DO" << endl; }
{KEYWORD_WHILE}     { cout << "KEYWORD_WHILE" << endl; }

{KEYWORD_PRIVATE}   { cout << "KEYWORD_PRIVATE" << endl; }
{KEYWORD_PROTECTED} { cout << "KEYWORD_PROTECTED" << endl; }
{KEYWORD_PUBLIC}    { cout << "KEYWORD_PUBLIC" << endl; }

{KEYWORD_NAMESPACE} { cout << "KEYWORD_NAMESPACE" << endl; }
{KEYWORD_TYPEDEF}   { cout << "KEYWORD_TYPEDEF" << endl; }
{KEYWORD_TYPEID}    { cout << "KEYWORD_TYPEID" << endl; }
{KEYWORD_TYPENAME}  { cout << "KEYWORD_TYPENAME" << endl; }
{KEYWORD_USING}     { cout << "KEYWORD_USING" << endl; }
{KEYWORD_VIRTUAL}   { cout << "KEYWORD_VIRTUAL" << endl; }

{KEYWORD_FINAL}     { cout << "KEYWORD_FINAL" << endl; }
{KEYWORD_EXPLICIT}  { cout << "KEYWORD_EXPLICIT" << endl; }
{KEYWORD_EXPORT}    { cout << "KEYWORD_EXPORT" << endl; }
{KEYWORD_EXTERN}    { cout << "KEYWORD_EXTERN" << endl; }
{KEYWORD_FRIEND}    { cout << "KEYWORD_FRIEND" << endl; }
{KEYWORD_OPERATOR}  { cout << "KEYWORD_OPERATOR" << endl; }
{KEYWORD_REGISTER}  { cout << "KEYWORD_REGISTER" << endl; }
{KEYWORD_STATIC}    { cout << "KEYWORD_STATIC" << endl; }
{KEYWORD_NOEXCEPT}  { cout << "KEYWORD_NOEXCEPT" << endl; }
{KEYWORD_OVERRIDE}  { cout << "KEYWORD_OVERRIDE" << endl; }
{KEYWORD_VOLATILE}  { cout << "KEYWORD_VOLATILE" << endl; }
{KEYWORD_CONSTEXPR} { cout << "KEYWORD_CONSTEXPR" << endl; }

{KEYWORD_CONST_CAST}        { cout << "KEYWORD_CONST_CAST" << endl; }
{KEYWORD_DYNAMIC_CAST}      { cout << "KEYWORD_DYNAMIC_CAST" << endl; }
{KEYWORD_REINTERPRET_CAST}  { cout << "KEYWORD_REINTERPRET_CAST" << endl; }
{KEYWORD_STATIC_CAST}       { cout << "KEYWORD_STATIC_CAST" << endl; }

{KEYWORD_TRUE}      { cout << "KEYWORD_TRUE" << endl; }
{KEYWORD_FALSE}     { cout << "KEYWORD_FALSE" << endl; }

{IDENT}          { cout << "Identifier: " << yytext << endl; }


[(){};,]         { cout << "Punctuation: " << yytext << endl; }
[ \t\r\n]+       { /* Игнорируем пробелы и переносы строк */ }
.                { cout << "Unknown character: " << yytext << endl; }
%%
