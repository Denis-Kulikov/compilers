#!/bin/bash

bison -Wcounterexamples -d parser.y
flex++ lexer.l
g++ lex.yy.c parser.tab.c -o calc -lfl
