#!/bin/bash

flex++ lexer.l
bison -d parser.y
g++ lex.yy.c parser.tab.c -o calc -lfl
